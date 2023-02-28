resource "kubernetes_namespace_v1" "plausible" {
  metadata {
    name = "plausible"
  }
}

resource "kubernetes_secret_v1" "plausible_config" {
  metadata {
    name      = "plausible-config"
    namespace = kubernetes_namespace_v1.plausible.metadata[0].name
  }
  data = {
    BASE_URL        = "https://plausible.${var.domain}"
    SECRET_KEY_BASE = var.plausible_secret_key_base
  }
}

resource "kubernetes_secret_v1" "plausible_db_user" {
  metadata {
    name      = "plausible-db-user"
    namespace = kubernetes_namespace_v1.plausible.metadata[0].name
  }

  data = {
    username = "plausible"
    password = var.plausible_db_password
  }
}

resource "kubernetes_deployment_v1" "plausible" {
  metadata {
    name      = "plausible"
    namespace = kubernetes_namespace_v1.plausible.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "plausible"
      }
    }
    template {
      metadata {
        labels = {
          app = "plausible"
        }
      }
      spec {
        init_container {
          name  = "plausible-init"
          image = "plausible/analytics:latest"
          env_from {
            secret_ref {
              name = "plausible-config"
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "plausible-db-user"
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "plausible-db-user"
                key  = "password"
              }
            }
          }
          env {
            name  = "DATABASE_URL"
            value = "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@db.postgres/plausible"
          }
          command = ["sh", "-c"]
          args    = ["/entrypoint.sh db createdb && /entrypoint.sh db migrate"]
        }
        container {
          name  = "plausible"
          image = "plausible/analytics:latest"
          resources {
            requests = {
              cpu    = "500m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
          env_from {
            secret_ref {
              name = "plausible-config"
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "plausible-db-user"
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "plausible-db-user"
                key  = "password"
              }
            }
          }
          env {
            name  = "DATABASE_URL"
            value = "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@db.postgres/plausible"
          }
          port {
            container_port = 8000
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
        node_selector = {
          "node-role.kubernetes.io/master" = "true"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "plausible" {
  metadata {
    name      = "plausible"
    namespace = kubernetes_namespace_v1.plausible.metadata[0].name
  }
  spec {
    selector = {
      app = "plausible"
    }
    port {
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_manifest" "plausible_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "plausible"
      namespace = kubernetes_namespace_v1.plausible.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`plausible.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "plausible"
              kind = "Service"
              port = 8000
            }
          ]
        }
      ]
    }
  }
}
