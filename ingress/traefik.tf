resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart   = "traefik/traefik"
  version = "20.1.1"

  name      = "traefik"
  namespace = kubernetes_namespace_v1.traefik.metadata[0].name

  values = [
    file("values/traefik-values.yaml")
  ]
}

resource "kubernetes_manifest" "traefik_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`traefik.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              name = kubernetes_manifest.traefik_middleware_auth.manifest.metadata.name
            }
          ]
          services = [
            {
              name = "api@internal"
              kind = "TraefikService"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "traefik_middleware_auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-auth"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.traefik_auth_secret.metadata[0].name
      }
    }
  }
}

resource "kubernetes_secret_v1" "traefik_auth_secret" {
  metadata {
    name      = "auth-secret"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
  }

  data = {
    "users" = var.http_basic_auth
  }
}
