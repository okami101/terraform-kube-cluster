resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  data = {
    "pgsql-password"             = var.pgsql_password
    "pgsql-replication-password" = var.pgsql_replication_password
    "datasources"                = "postgresql://${var.pgsql_user}:${urlencode(var.pgsql_password)}@${kubernetes_service.postgres.metadata[0].name}?sslmode=disable,postgresql://${var.pgsql_user}:${urlencode(var.pgsql_password)}@${kubernetes_service.postgres_replica.metadata[0].name}?sslmode=disable"
  }
}

resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }

  data = {
    "postgres.conf"                      = file("configs/postgres.conf")
    "pg_hba.conf"                        = file("configs/pg_hba.conf")
    "primary_create_replication_role.sh" = file("scripts/primary_create_replication_role.sh")
    "copy_primary_data_to_replica.sh"    = file("scripts/copy_primary_data_to_replica.sh")
  }
}

resource "kubernetes_stateful_set" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    service_name = "postgresql"
    selector {
      match_labels = {
        app = "postgresql"
      }
    }
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "primary"
        }
      }
      spec {
        container {
          name              = "postgres"
          image             = "postgres:14"
          image_pull_policy = "Always"

          args = [
            "-c",
            "config_file=/etc/postgres.conf",
            "-c",
            "hba_file=/etc/pg_hba.conf",
          ]

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "pgsql-password"
              }
            }
          }

          env {
            name  = "POSTGRES_USER"
            value = var.pgsql_user
          }

          env {
            name  = "POSTGRES_DB"
            value = var.pgsql_user
          }

          env {
            name = "POSTGRES_REPLICATION_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "pgsql-replication-password"
              }
            }
          }

          port {
            container_port = 5432
          }

          liveness_probe {
            exec {
              command = [
                "pg_isready",
                "-U",
                var.pgsql_user,
              ]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          readiness_probe {
            exec {
              command = [
                "pg_isready",
                "-U",
                var.pgsql_user,
              ]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          volume_mount {
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/docker-entrypoint-initdb.d/primary_create_replication_role.sh"
            sub_path   = "primary_create_replication_role.sh"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/etc/postgres.conf"
            sub_path   = "postgres.conf"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/etc/pg_hba.conf"
            sub_path   = "pg_hba.conf"
          }
        }

        volume {
          name = "base-config"
          config_map {
            name         = "postgres-config"
            default_mode = "0755"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgresql-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "openebs-hostpath"
        resources {
          requests = {
            storage = "8Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgresql_replica" {
  metadata {
    name      = "postgresql-replica"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    service_name = "postgresql-replica"
    selector {
      match_labels = {
        app = "postgresql"
      }
    }
    template {
      metadata {
        labels = {
          app  = "postgresql"
          role = "replica"
        }
      }
      spec {
        init_container {
          name              = "setup-replica-data-directory"
          image             = "postgres:14"
          image_pull_policy = "Always"

          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "pgsql-replication-password"
              }
            }
          }

          env {
            name  = "PRIMARY_HOST_NAME"
            value = kubernetes_service.postgres.metadata[0].name
          }

          command = [
            "bash",
            "-c",
            "/tmp/copy_primary_data_to_replica.sh"
          ]

          volume_mount {
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/tmp/copy_primary_data_to_replica.sh"
            sub_path   = "copy_primary_data_to_replica.sh"
          }
        }
        container {
          name              = "postgres"
          image             = "postgres:14"
          image_pull_policy = "Always"

          args = [
            "-c",
            "config_file=/etc/postgres.conf",
            "-c",
            "hba_file=/etc/pg_hba.conf",
          ]

          port {
            container_port = 5432
          }

          liveness_probe {
            exec {
              command = [
                "pg_isready",
                "-U",
                var.pgsql_user,
              ]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          readiness_probe {
            exec {
              command = [
                "pg_isready",
                "-U",
                var.pgsql_user,
              ]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          volume_mount {
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/etc/postgres.conf"
            sub_path   = "postgres.conf"
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/etc/pg_hba.conf"
            sub_path   = "pg_hba.conf"
          }
        }

        volume {
          name = "base-config"
          config_map {
            name         = "postgres-config"
            default_mode = "0755"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgresql-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "openebs-hostpath"
        resources {
          requests = {
            storage = "8Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    selector = {
      role = "primary"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_service" "postgres_replica" {
  metadata {
    name      = "db-replica"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    selector = {
      role = "replica"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_service" "postgres_ro" {
  metadata {
    name      = "db-ro"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }
  spec {
    selector = {
      app = "postgresql"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}