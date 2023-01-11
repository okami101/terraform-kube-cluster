resource "kubernetes_namespace_v1" "redis" {
  metadata {
    name = "redis"
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.redis.metadata[0].name
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
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.redis_secret.metadata[0].name
                key  = "redis-password"
              }
            }
          }
          port {
            container_port = 6379
          }
          args = [
            "redis-server",
            "--requirepass",
            "$(REDIS_PASSWORD)",
          ]
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

resource "kubernetes_secret_v1" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace_v1.redis.metadata[0].name
  }
  data = {
    "redis-password" = var.redis_password
  }
}

resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace_v1.redis.metadata[0].name
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

resource "helm_release" "redis_exporter" {
  chart   = "prometheus-community/prometheus-redis-exporter"
  version = "5.3.0"

  name      = "redis-exporter"
  namespace = kubernetes_namespace_v1.redis.metadata[0].name

  set {
    name  = "redisAddress"
    value = "redis://${kubernetes_service_v1.redis.metadata[0].name}:6379"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "auth.enabled"
    value = "true"
  }

  set {
    name  = "auth.secret.name"
    value = kubernetes_secret_v1.redis_secret.metadata[0].name
  }

  set {
    name  = "auth.secret.key"
    value = "redis-password"
  }

  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/monitor"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }
}
