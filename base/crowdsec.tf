resource "kubernetes_namespace_v1" "crowdsec" {
  metadata {
    name = "crowdsec"
  }
}

resource "helm_release" "crowdsec" {
  chart      = "crowdsec"
  version    = var.chart_crowdsec_version
  repository = "https://crowdsecurity.github.io/helm-charts"

  name      = "crowdsec"
  namespace = kubernetes_namespace_v1.crowdsec.metadata[0].name

  values = [
    file("${path.module}/values/crowdsec-values.yaml")
  ]
}

resource "kubernetes_manifest" "traefik_middleware_bouncer" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-bouncer"
      namespace = kubernetes_namespace_v1.crowdsec.metadata[0].name
    }
    spec = {
      plugin = {
        bouncer = {
          enabled          = true
          crowdseclapikey  = var.bouncer_api_key
          crowdsecLapiHost = "crowdsec-service.crowdsec:8080"
        }
      }
    }
  }
}
