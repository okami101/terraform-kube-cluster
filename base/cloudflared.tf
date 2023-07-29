resource "kubernetes_deployment_v1" "cloudflared" {
  metadata {
    name = "cloudflared"
  }

  spec {
    selector {
      match_labels = {
        app = "cloudflared"
      }
    }

    replicas = 2

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

          args = [
            "tunnel",
            "--config",
            "/etc/cloudflared/config/config.yaml",
            "run"
          ]

          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }

            failure_threshold     = 1
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/cloudflared/config"
            read_only  = true
          }

          volume_mount {
            name       = "creds"
            mount_path = "/etc/cloudflared/creds"
            read_only  = true
          }
        }

        volume {
          name = "creds"

          secret {
            secret_name = "tunnel-credentials"
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map_v1.cloudflared.metadata[0].name

            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map_v1" "cloudflared" {
  metadata {
    name = "cloudflared"
  }

  data = {
    "config.yaml" = <<EOF
tunnel: okami-cluster-tunnel
credentials-file: /etc/cloudflared/creds/credentials.json
metrics: 0.0.0.0:2000
no-autoupdate: true
ingress:
  - hostname: ssh.${var.domain}
    service: ssh://traefik.traefik
  - service: https://traefik.traefik
    originRequest:
      noTLSVerify: true
      http2Origin: true
EOF
  }
}
