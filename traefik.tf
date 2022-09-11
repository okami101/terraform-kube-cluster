resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart   = "traefik/traefik"
  version = "10.24.2"

  name      = "traefik"
  namespace = "traefik"

  values = [
    file("values/traefik-values.yaml")
  ]
}

resource "kubernetes_manifest" "traefik_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name : "metrics"
      namespace : "traefik"
    }
    spec = {
      endpoints = [
        {
          targetPort : 9100
        }
      ]
      selector = {
        matchLabels = {
          "app.kubernetes.io/name"     = "traefik"
          "app.kubernetes.io/instance" = "traefik"
        }
      }
    }
  }
}
