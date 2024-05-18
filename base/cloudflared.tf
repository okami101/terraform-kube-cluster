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
  version    = var.chart_cloudflared_version

  set {
    name  = "managed.token"
    value = var.cloudflared_managed_token
  }
}
