resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

resource "kubernetes_stateful_set" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }

  spec {
    service_name = "redis"
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          name              = "redis"
          image             = "redis:7"
          image_pull_policy = "Always"
          port {
            container_port = 6379
          }
          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }
        }
        volume {
          name = "redis-data"
          empty_dir {}
        }
        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace.redis.metadata[0].name
  }
  spec {
    selector = {
      app = "redis"
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

resource "helm_release" "redis-exporter" {
  chart   = "prometheus-community/prometheus-redis-exporter"
  version = "5.1.0"

  name      = "redis-exporter"
  namespace = kubernetes_namespace.redis.metadata[0].name

  set {
    name  = "redisAddress"
    value = "redis://${kubernetes_service.redis.metadata[0].name}:6379"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}
