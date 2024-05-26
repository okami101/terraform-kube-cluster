resource "kubernetes_namespace_v1" "cnpg" {
  metadata {
    name = "cnpg"
  }
}

resource "helm_release" "cnpg" {
  chart      = "cnpg"
  version    = var.chart_cnpg_version
  repository = "https://cloudnative-pg.github.io/charts"

  name      = "cnpg"
  namespace = kubernetes_namespace_v1.cnpg.metadata[0].name

  set {
    name  = "monitoring.podMonitorEnabled"
    value = "true"
  }

  set {
    name  = "monitoring.grafanaDashboard.create"
    value = "true"
  }
}
