resource "kubernetes_persistent_volume_claim" "pgadmin" {
  metadata {
    name      = "pgadmin-data"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "128Mi"
      }
    }
  }
}

resource "kubernetes_deployment" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
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
        container {
          name  = "pgadmin"
          image = "dpage/pgadmin4:latest"
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
            claim_name = kubernetes_persistent_volume_claim.pgadmin.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = kubernetes_namespace.postgres.metadata[0].name
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
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name : "pgadmin"
      namespace : kubernetes_namespace.postgres.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`pga.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.pgadmin.metadata[0].name
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}
