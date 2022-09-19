resource "kubernetes_stateful_set_v1" "influxdb" {
  metadata {
    name      = "influxdb"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "influxdb"
      }
    }
    service_name = "influxdb"
    replicas     = 1
    template {
      metadata {
        labels = {
          app = "influxdb"
        }
      }
      spec {
        container {
          name              = "influxdb"
          image             = "influxdb:1.8"
          image_pull_policy = "Always"
          port {
            container_port = 8086
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

resource "kubernetes_service_v1" "influxdb" {
  metadata {
    name      = "influxdb"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }
  spec {
    selector = {
      app = "influxdb"
    }
    port {
      port        = 8086
      target_port = 8086
    }
  }
}
