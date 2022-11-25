resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart   = "grafana/loki"
  version = "3.4.2"

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
  chart   = "grafana/promtail"
  version = "6.6.2"

  name      = "promtail"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("values/promtail-values.yaml")
  ]

  depends_on = [
    helm_release.loki,
  ]
}
