resource "kubernetes_namespace_v1" "couchdb" {
  metadata {
    name = "couchdb"
  }
}

resource "random_uuid" "couchdb" {
}

resource "random_string" "cookie" {
  length  = 20
  special = false
}

resource "kubernetes_secret_v1" "couchdb_secret" {
  metadata {
    name      = "couchdb-couchdb"
    namespace = kubernetes_namespace_v1.couchdb.metadata[0].name
  }
  data = {
    adminUsername    = "admin"
    adminPassword    = var.couchdb_password
    cookieAuthSecret = random_string.cookie.result
    erlangCookie     = random_string.cookie.result
  }
}

resource "helm_release" "couchdb" {
  chart   = "couchdb/couchdb"
  version = "3.6.1"

  name      = "couchdb"
  namespace = kubernetes_namespace_v1.couchdb.metadata[0].name

  values = [
    file("values/couchdb-values.yaml")
  ]

  set {
    name  = "createAdminSecret"
    value = "false"
  }

  set {
    name  = "couchdbConfig.couchdb.uuid"
    value = random_uuid.couchdb.result
  }

  depends_on = [
    kubernetes_secret_v1.couchdb_secret
  ]
}
