resource "kubernetes_namespace_v1" "nocodb" {
  metadata {
    name = "nocodb"
  }
}

resource "kubernetes_secret_v1" "nocodb_secret" {
  metadata {
    name      = "nocodb-secret"
    namespace = kubernetes_namespace_v1.nocodb.metadata[0].name
  }

  data = {
    database-url = "postgresql://nocodb:${urlencode(var.nocodb_db_password)}@db.postgres/nocodb"
    jwt-secret   = var.nocodb_jwt_secret
  }
}

resource "kubernetes_persistent_volume_claim_v1" "nocodb" {
  metadata {
    name      = "nocodb-data"
    namespace = kubernetes_namespace_v1.nocodb.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "128Mi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "nocodb" {
  metadata {
    name      = "nocodb"
    namespace = kubernetes_namespace_v1.nocodb.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "nocodb"
      }
    }
    template {
      metadata {
        labels = {
          app = "nocodb"
        }
      }
      spec {
        container {
          name              = "nocodb"
          image             = "nocodb/nocodb:latest"
          image_pull_policy = "Always"
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.nocodb_secret.metadata[0].name
                key  = "database-url"
              }
            }
          }
          env {
            name = "NC_AUTH_JWT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.nocodb_secret.metadata[0].name
                key  = "jwt-secret"
              }
            }
          }
          env {
            name  = "NC_SMTP_HOST"
            value = var.smtp_host
          }
          env {
            name  = "NC_SMTP_PORT"
            value = var.smtp_port
          }
          env {
            name  = "NC_SMTP_USERNAME"
            value = var.smtp_user
          }
          env {
            name  = "NC_SMTP_PASSWORD"
            value = var.smtp_password
          }
          env {
            name  = "NC_SMTP_FROM"
            value = "nocodb@${var.domain}"
          }
          env {
            name  = "NC_PUBLIC_URL"
            value = "https://n8n.${var.domain}/"
          }
          port {
            container_port = 8080
          }
          volume_mount {
            name       = "nocodb-data"
            mount_path = "/usr/app/data"
          }
        }
        volume {
          name = "nocodb-data"
          persistent_volume_claim {
            claim_name = "nocodb-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nocodb" {
  metadata {
    name      = "nocodb"
    namespace = kubernetes_namespace_v1.nocodb.metadata[0].name
  }
  spec {
    selector = {
      app = "nocodb"
    }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_manifest" "nocodb_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "nocodb"
      namespace = kubernetes_namespace_v1.nocodb.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`nocodb.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "nocodb"
              kind = "Service"
              port = 8080
            }
          ]
        }
      ]
    }
  }
}
