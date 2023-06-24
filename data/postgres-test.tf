resource "kubernetes_namespace_v1" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_stateful_set_v1" "postgres_test" {
  metadata {
    name      = "postgresql"
    namespace = kubernetes_namespace_v1.test.metadata[0].name
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
          app = "postgresql"
        }
      }
      spec {
        container {
          name              = "postgres"
          image             = "postgres:15"
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
            name       = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/runner"
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
        storage_class_name = "local-path"
        resources {
          requests = {
            storage = "8Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres_test" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.test.metadata[0].name
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
