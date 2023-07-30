resource "kubernetes_namespace_v1" "mongodb" {
  metadata {
    name = "mongodb"
  }
}

resource "helm_release" "mongodb" {
  chart      = "mongodb"
  version    = var.chart_mongodb_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "mongodb"
  namespace = kubernetes_namespace_v1.mongodb.metadata[0].name

  values = [
    file("${path.module}/values/mongodb-values.yaml")
  ]

  set {
    name  = "auth.rootPassword"
    value = var.mongodb_password
  }
}
