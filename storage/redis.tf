resource "kubernetes_namespace_v1" "redis" {
  metadata {
    name = "redis"
  }
}

resource "kubernetes_secret_v1" "redis_auth" {
  metadata {
    name      = "redis-auth"
    namespace = kubernetes_namespace_v1.redis.metadata[0].name
  }
  data = {
    "redis-password" = var.redis_password
  }
}

resource "helm_release" "redis" {
  chart      = "redis"
  version    = var.chart_redis_version
  repository = "https://registry-1.docker.io/bitnamicharts"

  name      = "redis"
  namespace = kubernetes_namespace_v1.redis.metadata[0].name

  values = [
    file("${path.module}/values/redis-values.yaml")
  ]

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret_v1.redis_auth.metadata[0].name
  }
}
