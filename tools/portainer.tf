resource "kubernetes_namespace_v1" "portainer" {
  metadata {
    name = "portainer"
  }
}

resource "helm_release" "portainer" {
  chart   = "portainer/portainer"
  version = "1.0.36"

  name      = "portainer"
  namespace = kubernetes_namespace_v1.portainer.metadata[0].name

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = "nfs-client"
  }
}

resource "kubernetes_manifest" "portainer_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "portainer"
      namespace = kubernetes_namespace_v1.portainer.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`portainer.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              name = kubernetes_manifest.portainer_middleware_ip.manifest.metadata.name
            }
          ]
          services = [
            {
              name = "portainer"
              kind = "Service"
              port = 9000
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "portainer_middleware_ip" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-ip"
      namespace = kubernetes_namespace_v1.portainer.metadata[0].name
    }
    spec = {
      ipWhiteList = {
        sourceRange = var.whitelisted_ips
      }
    }
  }
}
