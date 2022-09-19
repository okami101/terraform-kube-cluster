resource "kubernetes_namespace_v1" "mysql" {
  metadata {
    name = "mysql"
  }
}

resource "kubernetes_secret_v1" "mysql_secret" {
  metadata {
    name      = "mysql-secret"
    namespace = kubernetes_namespace_v1.mysql.metadata[0].name
  }
  data = {
    "mysql-root-password" = var.mysql_password
  }
}

resource "kubernetes_config_map_v1" "mysql_config" {
  metadata {
    name      = "mysql-config"
    namespace = kubernetes_namespace_v1.mysql.metadata[0].name
  }

  data = {
    "mysqld.cnf" = file("configs/mysqld.cnf")
  }
}

resource "kubernetes_stateful_set_v1" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace_v1.mysql.metadata[0].name
  }

  spec {
    service_name = "mysql"
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:8"

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mysql_secret.metadata[0].name
                key  = "mysql-root-password"
              }
            }
          }

          port {
            container_port = 3306
          }

          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }

          volume_mount {
            name       = "mysql-config"
            mount_path = "/etc/mysql/conf.d"
          }

          liveness_probe {
            exec {
              command = [
                "mysqladmin",
                "ping",
              ]
            }
            initial_delay_seconds = 30
            timeout_seconds       = 5
          }

          readiness_probe {
            exec {
              command = [
                "bash",
                "-c",
                "mysql -p$MYSQL_ROOT_PASSWORD -e 'SELECT 1'",
              ]
            }
            initial_delay_seconds = 5
            timeout_seconds       = 1
          }
        }

        volume {
          name = "mysql-config"
          config_map {
            name         = "mysql-config"
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
        name = "mysql-data"
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

resource "kubernetes_service_v1" "mysql" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace_v1.mysql.metadata[0].name
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "helm_release" "mysql-exporter" {
  chart   = "prometheus-community/prometheus-mysql-exporter"
  version = "1.9.0"

  name      = "mysql-exporter"
  namespace = kubernetes_namespace_v1.mysql.metadata[0].name

  set {
    name  = "mysql.host"
    value = kubernetes_service_v1.mysql.metadata[0].name
  }

  set {
    name  = "mysql.user"
    value = "exporter"
  }

  set {
    name  = "mysql.pass"
    value = var.mysql_exporter_password
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}
