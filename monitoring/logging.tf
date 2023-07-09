resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart      = "loki"
  version    = var.chart_loki_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "loki"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("${path.module}/values/loki-values.yaml")
  ]
}

resource "helm_release" "promtail" {
  chart      = "promtail"
  version    = var.chart_promtail_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "promtail"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("${path.module}/values/promtail-values.yaml")
  ]
}
