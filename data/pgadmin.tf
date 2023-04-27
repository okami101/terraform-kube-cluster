resource "kubernetes_persistent_volume_claim_v1" "pgadmin" {
  metadata {
    name      = "pgadmin-data"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "128Mi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "pgadmin"
      }
    }
    template {
      metadata {
        labels = {
          app = "pgadmin"
        }
      }
      spec {
        security_context {
          run_as_user            = 5050
          run_as_group           = 5050
          fs_group               = 5050
          fs_group_change_policy = "OnRootMismatch"
        }
        container {
          name  = "pgadmin"
          image = "dpage/pgadmin4:latest"
          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
          env {
            name  = "PGADMIN_DEFAULT_EMAIL"
            value = var.pgadmin_default_email
          }
          env {
            name  = "PGADMIN_DEFAULT_PASSWORD"
            value = var.pgadmin_default_password
          }
          port {
            container_port = 80
          }
          volume_mount {
            name       = "pgadmin-data"
            mount_path = "/var/lib/pgadmin"
          }
        }

        volume {
          name = "pgadmin-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.pgadmin.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  spec {
    selector = {
      app = "pgadmin"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "pgadmin_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "pgadmin"
      namespace = kubernetes_namespace_v1.postgres.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`pga.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-ip"
            }
          ]
          services = [
            {
              name = kubernetes_service_v1.pgadmin.metadata[0].name
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}
