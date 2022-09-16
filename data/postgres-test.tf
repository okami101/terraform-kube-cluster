resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_config_map" "postgres_test_config" {
  metadata {
    name      = "postgres-config"
    namespace = kubernetes_namespace.test.metadata[0].name
  }
  data = {
    "db-test-init.sh" = file("scripts/db-test-init.sh")
  }
}

resource "kubernetes_deployment" "postgres_test" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.test.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        container {
          name              = "postgres"
          image             = "postgres:14"
          image_pull_policy = "Always"
          env {
            name  = "POSTGRES_USER"
            value = "test"
          }
          env {
            name  = "POSTGRES_DB"
            value = "test"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "test"
          }
          port {
            container_port = 5432
          }

          volume_mount {
            name       = "base-config"
            mount_path = "/docker-entrypoint-initdb.d"
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
          key      = "node-role.kubernetes.io/runner"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres_test" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.test.metadata[0].name
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}
