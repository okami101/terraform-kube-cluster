resource "kubernetes_namespace_v1" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}

resource "kubernetes_stateful_set_v1" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
    service_name = "rabbitmq"
    replicas     = 1
    template {
      metadata {
        labels = {
          app = "rabbitmq"
        }
      }
      spec {
        container {
          name              = "rabbitmq"
          image             = "rabbitmq:3-management"
          image_pull_policy = "Always"
          env {
            name  = "RABBITMQ_DEFAULT_USER"
            value = var.rabbitmq_default_user
          }
          env {
            name  = "RABBITMQ_DEFAULT_PASS"
            value = var.rabbitmq_default_password
          }
          port {
            container_port = 5672
          }
          port {
            container_port = 15672
          }
          volume_mount {
            name       = "rabbitmq-data"
            mount_path = "/var/lib/rabbitmq"
          }
        }
        volume {
          name = "rabbitmq-data"
          persistent_volume_claim {
            claim_name = "rabbitmq-data"
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "rabbitmq_data" {
  metadata {
    name      = "rabbitmq-data"
    namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
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

resource "kubernetes_service_v1" "rabbitmq" {
  metadata {
    name      = "queue"
    namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
    labels = {
      app = "rabbitmq"
    }
  }
  spec {
    selector = {
      app = "rabbitmq"
    }
    port {
      name        = "amqp"
      port        = 5672
      target_port = 5672
    }
    port {
      name        = "admin"
      port        = 15672
      target_port = 15672
    }
    port {
      name        = "metrics"
      port        = 15692
      target_port = 15692
    }
  }
}

resource "kubernetes_manifest" "rabbitmq_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "rabbitmq"
      namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`rmq.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service_v1.rabbitmq.metadata[0].name
              kind = "Service"
              port = 15672
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "rabbitmq_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "metrics"
      namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
    }
    spec = {
      endpoints = [
        {
          port = "metrics"
        }
      ]
      selector = {
        matchLabels = {
          app = "rabbitmq"
        }
      }
    }
  }
}
