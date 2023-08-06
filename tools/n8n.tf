resource "kubernetes_namespace_v1" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "kubernetes_secret_v1" "n8n_secret" {
  metadata {
    name      = "n8n-secret"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
  }

  data = {
    db-password = var.n8n_db_password
  }
}

resource "kubernetes_deployment_v1" "n8n" {
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "n8n"
      }
    }
    template {
      metadata {
        labels = {
          app = "n8n"
        }
      }
      spec {
        container {
          name              = "n8n"
          image             = "n8nio/n8n"
          image_pull_policy = "Always"
          resources {
            requests = var.n8n_resources_requests
            limits   = var.n8n_resources_limits
          }
          env {
            name  = "N8N_PROTOCOL"
            value = "https"
          }
          env {
            name  = "N8N_HOST"
            value = "n8n.${var.domain}"
          }
          env {
            name  = "N8N_PORT"
            value = "5678"
          }
          env {
            name  = "NODE_ENV"
            value = "production"
          }
          env {
            name  = "WEBHOOK_URL"
            value = "https://n8n.${var.domain}/"
          }
          env {
            name  = "DB_TYPE"
            value = "postgresdb"
          }
          env {
            name  = "DB_POSTGRESDB_DATABASE"
            value = "n8n"
          }
          env {
            name  = "DB_POSTGRESDB_HOST"
            value = "postgresql-primary.postgres"
          }
          env {
            name  = "DB_POSTGRESDB_USER"
            value = "n8n"
          }
          env {
            name = "DB_POSTGRESDB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.n8n_secret.metadata[0].name
                key  = "db-password"
              }
            }
          }
          env {
            name  = "N8N_EMAIL_MODE"
            value = "smtp"
          }
          env {
            name  = "N8N_SMTP_HOST"
            value = var.smtp_host
          }
          env {
            name  = "N8N_SMTP_PORT"
            value = var.smtp_port
          }
          env {
            name  = "N8N_SMTP_USER"
            value = var.smtp_user
          }
          env {
            name  = "N8N_SMTP_PASS"
            value = var.smtp_password
          }
          env {
            name  = "N8N_SMTP_SENDER"
            value = "n8n@${var.domain}"
          }
          port {
            container_port = 5678
          }
          volume_mount {
            name       = "n8n-data"
            mount_path = "/home/node/.n8n"
          }
        }

        volume {
          name = "n8n-data"
          persistent_volume_claim {
            claim_name = var.n8n_pvc_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "n8n" {
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
  }
  spec {
    selector = {
      app = "n8n"
    }
    port {
      port        = 5678
      target_port = 5678
    }
  }
}

resource "kubernetes_manifest" "n8n_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "n8n"
      namespace = kubernetes_namespace_v1.n8n.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`n8n.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "n8n"
              port = 5678
            }
          ]
        }
      ]
    }
  }
}
