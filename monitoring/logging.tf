resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart      = "loki"
  version    = "5.2.0"
  repository = "https://grafana.github.io/helm-charts"

  name      = "loki"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("values/loki-values.yaml")
  ]
}

resource "helm_release" "promtail" {
  chart      = "promtail"
  version    = "6.11.0"
  repository = "https://grafana.github.io/helm-charts"

  name      = "promtail"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("values/promtail-values.yaml")
  ]
}
