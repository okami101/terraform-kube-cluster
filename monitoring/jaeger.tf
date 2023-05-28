resource "kubernetes_namespace_v1" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "jaeger" {
  chart      = "jaeger"
  version    = "0.71.2"
  repository = "https://jaegertracing.github.io/helm-charts"

  name      = "jaeger"
  namespace = kubernetes_namespace_v1.tracing.metadata[0].name

  values = [
    file("values/jaeger-values.yaml")
  ]
}

resource "kubernetes_manifest" "jaeger_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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
              namespace = "traefik"
              name      = "middleware-auth"
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
