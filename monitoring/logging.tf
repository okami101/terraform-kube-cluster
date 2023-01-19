resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart      = "loki"
  version    = "4.4.0"
  repository = "https://grafana.github.io/helm-charts"

  name      = "loki"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("values/loki-values.yaml")
  ]

  depends_on = [
    helm_release.kube_prometheus_stack,
  ]
}

resource "helm_release" "promtail" {
  chart      = "promtail"
  version    = "6.8.1"
  repository = "https://grafana.github.io/helm-charts"

  name      = "promtail"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("values/promtail-values.yaml")
  ]

  depends_on = [
    helm_release.loki,
  ]
}
