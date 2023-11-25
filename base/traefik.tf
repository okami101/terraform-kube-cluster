resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart      = "traefik"
  version    = var.chart_traefik_version
  repository = "https://traefik.github.io/charts"

  name      = "traefik"
  namespace = kubernetes_namespace_v1.traefik.metadata[0].name

  values = [
    templatefile("${path.module}/values/traefik-values.yaml", {
      domain = var.domain
    })
  ]

  set {
    name  = "ports.websecure.forwardedHeaders.trustedIPs"
    value = "{${join(",", var.trusted_ips)}}"
  }

  set {
    name  = "ports.websecure.proxyProtocol.trustedIPs"
    value = "{${join(",", var.trusted_ips)}}"
  }

  set {
    name  = "tlsStore.default.defaultCertificate.secretName"
    value = local.certificate_secret_name
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

resource "kubernetes_manifest" "traefik_middleware_auth" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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
