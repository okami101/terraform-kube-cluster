resource "kubernetes_config_map_v1" "postgres_backup_script" {
  metadata {
    name      = "backup-script"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }

  data = {
    "backup.sh" = file("scripts/postgres-backup.sh")
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres_backup" {
  metadata {
    name      = "postgres-backup"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_cron_job_v1" "postgres_backup" {
  metadata {
    name      = "backup"
    namespace = kubernetes_namespace_v1.postgres.metadata[0].name
  }
  spec {
    schedule = "0 * * * *"
    job_template {
      metadata {
        name = "backup"
      }
      spec {
        template {

          metadata {
            name = "backup"
          }
          spec {
            restart_policy = "OnFailure"
            container {
              name  = "backup"
              image = "postgres:15"

              env {
                name = "PG_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret_v1.postgres_secret.metadata[0].name
                    key  = "pgsql-password"
                  }
                }
              }

              env {
                name  = "PG_USER"
                value = var.pgsql_user
              }

              env {
                name  = "PG_HOST"
                value = kubernetes_service_v1.postgres.metadata[0].name
              }

              env {
                name  = "PG_DUMP_DIRECTORY"
                value = "/opt/backup"
              }

              command = ["/usr/local/bin/backup.sh"]

              volume_mount {
                name       = "backup"
                mount_path = "/opt/backup"
              }
              volume_mount {
                name       = "backup-script"
                mount_path = "/usr/local/bin"
              }
            }

            volume {
              name = "backup"
              persistent_volume_claim {
                claim_name = "postgres-backup"
              }
            }

            volume {
              name = "backup-script"
              config_map {
                name         = kubernetes_config_map_v1.postgres_backup_script.metadata[0].name
                default_mode = "0744"
              }
            }
          }
        }
      }
    }
  }
}
