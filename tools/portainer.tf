resource "kubernetes_namespace_v1" "portainer" {
  metadata {
    name = "portainer"
  }
}

resource "helm_release" "portainer" {
  chart   = "portainer/portainer"
  version = "1.0.38"

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
    value = "longhorn"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "32Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "32Mi"
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
              namespace = "traefik"
              name      = "middleware-ip"
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
