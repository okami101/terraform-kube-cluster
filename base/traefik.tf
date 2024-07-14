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

  set_list {
    name  = "ports.tunnel.forwardedHeaders.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.tunnel.proxyProtocol.trustedIPs"
    value = var.trusted_ips
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

resource "kubernetes_manifest" "traefik_middleware_internal_ip" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-internal-ip"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
    }
    spec = {
      ipAllowList = {
        sourceRange = var.internal_ip_whitelist
      }
    }
  }
}

resource "kubernetes_manifest" "traefik_middleware_noindex" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-noindex"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
    }
    spec = {
      headers = {
        customResponseHeaders = {
          "X-Robots-Tag" = "noindex"
        }
      }
    }
  }
}
