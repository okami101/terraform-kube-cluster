resource "kubernetes_namespace_v1" "redmine" {
  metadata {
    name = "redmine"
  }
}

resource "kubernetes_secret_v1" "redmine_secret" {
  metadata {
    name      = "redmine-secret"
    namespace = kubernetes_namespace_v1.redmine.metadata[0].name
  }

  data = {
    db-password     = var.redmine_db_password
    secret-key-base = var.redmine_secret_key_base
  }
}

resource "kubernetes_deployment_v1" "redmine" {
  metadata {
    name      = "redmine"
    namespace = kubernetes_namespace_v1.redmine.metadata[0].name
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "redmine"
      }
    }
    template {
      metadata {
        labels = {
          app = "redmine"
        }
      }
      spec {
        container {
          name              = "redmine"
          image             = "redmine:5"
          image_pull_policy = "Always"
          resources {
            requests = var.redmine_resources_requests
            limits   = var.redmine_resources_limits
          }
          env {
            name  = "REDMINE_DB_DATABASE"
            value = "redmine"
          }
          env {
            name  = "REDMINE_DB_USERNAME"
            value = "redmine"
          }
          env {
            name = "REDMINE_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "redmine-secret"
                key  = "db-password"
              }
            }
          }
          env {
            name  = "REDMINE_DB_POSTGRES"
            value = "db.postgres"
          }
          env {
            name = "REDMINE_SECRET_KEY_BASE"
            value_from {
              secret_key_ref {
                name = "redmine-secret"
                key  = "secret-key-base"
              }
            }
          }
          env {
            name  = "REDMINE_PLUGINS_MIGRATE"
            value = "1"
          }
          port {
            container_port = 3000
          }
          volume_mount {
            name       = "redmine-data"
            mount_path = "/usr/src/redmine/files"
            sub_path   = "files"
          }
          volume_mount {
            name       = "redmine-data"
            mount_path = "/usr/src/redmine/plugins"
            sub_path   = "plugins"
          }
          volume_mount {
            name       = "redmine-data"
            mount_path = "/usr/src/redmine/public/themes"
            sub_path   = "themes"
          }
        }
        volume {
          name = "redmine-data"
          persistent_volume_claim {
            claim_name = var.redmine_pvc_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "redmine" {
  metadata {
    name      = "redmine"
    namespace = kubernetes_namespace_v1.redmine.metadata[0].name
  }
  spec {
    selector = {
      app = "redmine"
    }
    port {
      port = 3000
    }
  }
}

resource "kubernetes_manifest" "redmine_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "redmine"
      namespace = kubernetes_namespace_v1.redmine.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`redmine.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "redmine"
              kind = "Service"
              port = 3000
            }
          ]
        }
      ]
    }
  }
}
