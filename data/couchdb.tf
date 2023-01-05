resource "kubernetes_namespace_v1" "couchdb" {
  metadata {
    name = "couchdb"
  }
}

resource "random_uuid" "couchdb" {
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
    name  = "couchdbConfig.couchdb.uuid"
    value = random_uuid.couchdb.result
  }
}
