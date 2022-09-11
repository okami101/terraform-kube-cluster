resource "kubernetes_namespace" "portainer" {
  metadata {
    name = "portainer"
  }
}

resource "helm_release" "portainer" {
  chart   = "portainer/portainer"
  version = "1.0.34"

  name      = "portainer"
  namespace = "portainer"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [
    helm_release.nfs_provisioner
  ]
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
