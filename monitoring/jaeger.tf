resource "kubernetes_namespace_v1" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "jaeger" {
  chart   = "jaegertracing/jaeger"
  version = "0.62.0"

  name      = "jaeger"
  namespace = kubernetes_namespace_v1.tracing.metadata[0].name

  values = [
    file("values/jaeger-values.yaml")
  ]
}

resource "kubernetes_manifest" "jaeger_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "jaeger"
      namespace = kubernetes_namespace_v1.tracing.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`jaeger.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              name = kubernetes_manifest.jaeger_middleware_auth.manifest.metadata.name
            }
          ]
          services = [
            {
              name = "jaeger-query"
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "jaeger_middleware_auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-auth"
      namespace = kubernetes_namespace_v1.tracing.metadata[0].name
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.jaeger_auth_secret.metadata[0].name
      }
    }
  }
}

resource "kubernetes_secret_v1" "jaeger_auth_secret" {
  metadata {
    name      = "auth-secret"
    namespace = kubernetes_namespace_v1.tracing.metadata[0].name
  }

  data = {
    "users" = var.http_basic_auth
  }
}
