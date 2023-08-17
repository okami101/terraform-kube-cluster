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
  chart      = "redis-cluster"
  version    = var.chart_redis_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "redis-cluster"
  namespace = kubernetes_namespace_v1.redis.metadata[0].name

  values = [
    templatefile("${path.module}/values/redis-values.yaml", {
      auth_secret = kubernetes_secret_v1.redis_auth.metadata[0].name
    })
  ]
}
