resource "kubernetes_namespace_v1" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_secret_v1" "postgresql_auth" {
  metadata {
    name      = "postgresql-auth"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  data = {
    "postgres-password"    = var.pgsql_admin_password
    "password"             = var.pgsql_password
    "replication-password" = var.pgsql_replication_password
  }
}

resource "helm_release" "postgresql" {
  chart      = "postgresql"
  version    = var.chart_postgresql_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "postgresql"
  namespace = kubernetes_namespace_v1.postgres.metadata[0].name

  values = [
    file("${path.module}/values/postgresql-values.yaml")
  ]

  set {
    name  = "auth.username"
    value = var.pgsql_user
  }

  set {
    name  = "auth.database"
    value = var.pgsql_user
  }
}
