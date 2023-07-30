resource "kubernetes_namespace_v1" "influxdb" {
  metadata {
    name = "influxdb"
  }
}

resource "helm_release" "influxdb" {
  chart      = "influxdb"
  version    = var.chart_influxdb_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "influxdb"
  namespace = kubernetes_namespace_v1.influxdb.metadata[0].name

  values = [
    file("${path.module}/values/influxdb-values.yaml")
  ]

  set {
    name  = "auth.admin.password"
    value = var.influxdb_admin_password
  }
}
