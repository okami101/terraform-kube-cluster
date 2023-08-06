resource "kubernetes_namespace_v1" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}

resource "helm_release" "rabbitmq" {
  chart      = "rabbitmq"
  version    = var.chart_rabbitmq_version
  repository = "https://charts.bitnami.com/bitnami"

  name      = "rabbitmq"
  namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name

  values = [
    file("${path.module}/values/rabbitmq-values.yaml")
  ]

  set {
    name  = "auth.username"
    value = var.rabbitmq_user
  }

  set {
    name  = "auth.password"
    value = var.rabbitmq_password
  }
}

resource "kubernetes_manifest" "rabbitmq_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "rabbitmq"
      namespace = kubernetes_namespace_v1.rabbitmq.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`rmq.${var.domain}`)"
          kind  = "Rule"
          middlewares = [for middleware in var.middlewares.rabbitmq : {
            namespace = "traefik"
            name      = "middleware-${middleware}"
          }]
          services = [
            {
              name = "rabbitmq"
              port = 15672
            }
          ]
        }
      ]
    }
  }
}
