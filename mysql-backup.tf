resource "kubernetes_config_map" "mysql_backup_script" {
  metadata {
    name      = "backup-script"
    namespace = kubernetes_namespace.mysql.metadata[0].name
  }

  data = {
    "backup.sh" = file("scripts/mysql-backup.sh")
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_backup" {
  metadata {
    name      = "mysql-backup"
    namespace = kubernetes_namespace.mysql.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_cron_job" "mysql_backup" {
  metadata {
    name      = "backup"
    namespace = kubernetes_namespace.mysql.metadata[0].name
  }
  spec {
    schedule = "0 */1 * * *"
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            restart_policy = "OnFailure"
            container {
              name  = "backup"
              image = "mysql:8"

              env {
                name = "MYSQL_ROOT_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.mysql_secret.metadata[0].name
                    key  = "mysql-root-password"
                  }
                }
              }

              env {
                name  = "MYSQL_HOST"
                value = kubernetes_service.mysql.metadata[0].name
              }

              env {
                name  = "MYSQL_DUMP_DIRECTORY"
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
                claim_name = "mysql-backup"
              }
            }

            volume {
              name = "backup-script"
              config_map {
                name         = kubernetes_config_map.mysql_backup_script.metadata[0].name
                default_mode = "0744"
              }
            }
          }
        }
      }
    }
  }
}
