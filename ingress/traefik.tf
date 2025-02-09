resource "kubernetes_namespace_v1" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart      = "traefik"
  version    = var.chart_traefik_version
  repository = "https://traefik.github.io/charts"

  name        = "traefik"
  namespace   = kubernetes_namespace_v1.traefik.metadata[0].name
  max_history = 2

  values = [
    templatefile("${path.module}/values/traefik-values.yaml", {
      load_balancer_name = var.load_balancer_name
      load_balancer_type = var.load_balancer_type
    })
  ]

  set {
    name  = "ingressRoute.dashboard.matchRule"
    value = "Host(`traefik.${var.internal_domain}`)"
  }

  set_list {
    name  = "ports.ssh.forwardedHeaders.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.ssh.proxyProtocol.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.web.forwardedHeaders.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.web.proxyProtocol.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.websecure.forwardedHeaders.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.websecure.proxyProtocol.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.private.forwardedHeaders.trustedIPs"
    value = var.trusted_ips
  }

  set_list {
    name  = "ports.private.proxyProtocol.trustedIPs"
    value = var.trusted_ips
  }

  set {
    name  = "tlsStore.default.defaultCertificate.secretName"
    value = local.certificate_secret_name
  }

  set {
    name  = "experimental.plugins.bouncer.moduleName"
    value = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin"
  }

  set {
    name  = "experimental.plugins.bouncer.version"
    value = var.crowdsec_bouncer_traefik_plugin_version
  }
}
