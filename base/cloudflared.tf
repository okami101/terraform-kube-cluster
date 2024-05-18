resource "kubernetes_namespace_v1" "cloudflared" {
  metadata {
    name = "cloudflared"
  }
}

resource "helm_release" "cloudflared" {
  name       = "cloudflared"
  repository = "https://charts.kubito.dev"
  chart      = "cloudflared"
  namespace  = kubernetes_namespace_v1.cloudflared.metadata[0].name
  version    = "1.3.0"

  set {
    name  = "cloudflared.ingress[0].hostname"
    value = "ssh.${var.domain}"
  }

  set {
    name  = "cloudflared.ingress[0].service"
    value = "ssh://traefik.traefik"
  }

  set {
    name  = "cloudflared.ingress[1].hostname"
    value = "*.${var.domain}"
  }

  set {
    name  = "cloudflared.ingress[1].service"
    value = "https://traefik.traefik"
  }

  set {
    name  = "cloudflared.ingress[1].originRequest.originServerName"
    value = var.domain
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }
}
