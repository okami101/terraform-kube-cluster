resource "kubernetes_namespace_v1" "cloudflared" {
  metadata {
    name = "cloudflared"
  }
}

resource "kubernetes_deployment_v1" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = kubernetes_namespace_v1.cloudflared.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "cloudflared"
      }
    }

    template {
      metadata {
        labels = {
          app = "cloudflared"
        }
      }

      spec {
        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.cloudflared.metadata[0].name
            }
          }

          args = [
            "tunnel",
            "--no-autoupdate",
            "--token",
            "$(CF_MANAGED_TUNNEL_TOKEN)",
            "--metrics",
            "0.0.0.0:2000",
            "run"
          ]
        }
      }
    }
  }
}

resource "kubernetes_secret_v1" "cloudflared" {
  metadata {
    name      = "tunnel-credentials"
    namespace = kubernetes_namespace_v1.cloudflared.metadata[0].name
  }

  data = {
    CF_MANAGED_TUNNEL_TOKEN = var.cloudflared_managed_token
  }
}

resource "kubernetes_service_v1" "cloudflared" {
  metadata {
    name      = "cloudflared"
    namespace = kubernetes_namespace_v1.cloudflared.metadata[0].name
  }

  spec {
    selector = {
      app = "cloudflared"
    }

    port {
      name = "metrics"
      port = 2000
    }
  }
}

resource "kubernetes_manifest" "cloudflared_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "metrics"
      namespace = kubernetes_namespace_v1.cloudflared.metadata[0].name
    }
    spec = {
      endpoints = [
        {
          port = "metrics"
        }
      ]
      selector = {
        matchLabels = {
          app = "cloudflared"
        }
      }
    }
  }
}
