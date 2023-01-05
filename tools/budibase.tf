resource "kubernetes_namespace_v1" "budibase" {
  metadata {
    name = "budibase"
  }
}

resource "helm_release" "budibase" {
  chart   = "budibase/budibase"
  version = "0.2.11"

  name      = "budibase"
  namespace = kubernetes_namespace_v1.budibase.metadata[0].name

  values = [
    templatefile("values/budibase-values.yaml", {
      domain           = var.domain
      redis_password   = var.redis_password
      couchdb_password = var.couchdb_password
      minio_user       = var.minio_user
      minio_password   = var.minio_password
      smtp_host        = var.smtp_host
      smtp_port        = var.smtp_port
      smtp_user        = var.smtp_user
      smtp_password    = var.smtp_password
    })
  ]
}

resource "kubernetes_manifest" "budibase_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "budibase"
      namespace = kubernetes_namespace_v1.budibase.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`budibase.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "proxy-service"
              kind = "Service"
              port = 10000
            }
          ]
        }
      ]
    }
  }
}
