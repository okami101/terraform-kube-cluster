resource "kubernetes_namespace_v1" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_deployment_v1" "postgres_test" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.test.metadata[0].name
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
        }

        toleration {
          key      = "node-role.kubernetes.io/runner"
          operator = "Exists"
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
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}
