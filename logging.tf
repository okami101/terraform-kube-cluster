resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart   = "grafana/loki"
  version = "3.0.3"

  name      = "loki"
  namespace = kubernetes_namespace.logging.metadata[0].name

  values = [
    file("values/loki-values.yaml")
  ]
}

resource "helm_release" "promtail" {
  chart   = "grafana/promtail"
  version = "6.3.1"

  name      = "promtail"
  namespace = kubernetes_namespace.logging.metadata[0].name

  values = [
    file("values/promtail-values.yaml")
  ]
}
