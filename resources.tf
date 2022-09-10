# helm repo add portainer https://portainer.github.io/k8s
resource "helm_release" "portainer" {
  chart   = "portainer/portainer"
  version = "1.0.34"

  name      = "portainer"
  namespace = "portainer"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

resource "kubernetes_manifest" "traefik_middleware_ip" {
  manifest = yamldecode(templatefile("manifests/middleware-ip.tftpl", {
    namespace       = "portainer"
    whitelisted_ips = var.whitelisted_ips
  }))
}

resource "kubernetes_manifest" "portainer_ingress" {
  manifest = yamldecode(templatefile("manifests/ir-portainer.tftpl", {
    domain = var.domain
  }))
}
