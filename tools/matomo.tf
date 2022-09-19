resource "kubernetes_namespace_v1" "matomo" {
  metadata {
    name = "matomo"
  }
}

resource "kubernetes_secret_v1" "matomo_secret" {
  metadata {
    name      = "matomo-secret"
    namespace = kubernetes_namespace_v1.matomo.metadata[0].name
  }

  data = {
    db-password = var.matomo_db_password
  }
}

resource "kubernetes_persistent_volume_claim_v1" "matomo_data" {
  metadata {
    name      = "matomo-data"
    namespace = kubernetes_namespace_v1.matomo.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "openebs-hostpath"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "matomo" {
  metadata {
    name      = "matomo"
    namespace = kubernetes_namespace_v1.matomo.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "matomo"
      }
    }
    template {
      metadata {
        labels = {
          app = "matomo"
        }
      }
      spec {
        container {
          name              = "matomo"
          image             = "matomo:latest"
          image_pull_policy = "Always"
          env {
            name  = "MATOMO_DATABASE_HOST"
            value = "db.mysql"
          }
          env {
            name  = "MATOMO_DATABASE_USERNAME"
            value = "matomo"
          }
          env {
            name = "MATOMO_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "matomo-secret"
                key  = "db-password"
              }
            }
          }
          env {
            name  = "MATOMO_DATABASE_DBNAME"
            value = "matomo"
          }
          port {
            container_port = 80
          }
          volume_mount {
            name       = "matomo-data"
            mount_path = "/var/www/html"
          }
        }
        volume {
          name = "matomo-data"
          persistent_volume_claim {
            claim_name = "matomo-data"
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/monitor"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "matomo" {
  metadata {
    name      = "matomo"
    namespace = kubernetes_namespace_v1.matomo.metadata[0].name
  }
  spec {
    selector = {
      app = "matomo"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_manifest" "matomo_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "matomo"
      namespace = kubernetes_namespace_v1.matomo.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`matomo.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "matomo"
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_cron_job_v1" "matomo_archive" {
  metadata {
    name      = "archive"
    namespace = kubernetes_namespace_v1.matomo.metadata[0].name
  }
  spec {
    schedule = "5 * * * *"
    job_template {
      metadata {
        name = "archive"
      }
      spec {
        template {
          metadata {
            name = "archive"
          }
          spec {
            container {
              name    = "archive"
              image   = "matomo:latest"
              command = ["php", "console", "--matomo-domain=matomo.${var.domain}", "core:archive"]
              volume_mount {
                name       = "matomo-data"
                mount_path = "/var/www/html"
              }
            }
            restart_policy = "Never"
            volume {
              name = "matomo-data"
              persistent_volume_claim {
                claim_name = "matomo-data"
              }
            }
            toleration {
              key      = "node-role.kubernetes.io/monitor"
              operator = "Exists"
            }
          }
        }
      }
    }
  }
}
