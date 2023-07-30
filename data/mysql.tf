resource "kubernetes_namespace_v1" "mysql" {
  metadata {
    name = "mysql"
  }
}

resource "kubernetes_secret_v1" "mysql_auth" {
  metadata {
    name      = "mysql-auth"
    namespace = kubernetes_namespace_v1.mysql.metadata[0].name
  }
  data = {
    "mysql-root-password" = var.mysql_root_password
    "mysql-password"      = var.mysql_password
  }
}

resource "helm_release" "mysql" {
  chart      = "mysql"
  version    = var.chart_mysql_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "mysql"
  namespace = kubernetes_namespace_v1.mysql.metadata[0].name

  values = [
    file("${path.module}/values/mysql-values.yaml")
  ]

  set {
    name  = "auth.username"
    value = var.mysql_user
  }

  set {
    name  = "auth.database"
    value = var.mysql_user
  }
}
