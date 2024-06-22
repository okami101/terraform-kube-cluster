resource "kubernetes_namespace_v1" "pgadmin" {
  metadata {
    name = "pgadmin"
  }
}

resource "helm_release" "pgadmin" {
  chart      = "pgadmin4"
  version    = "1.26.0"
  repository = "https://helm.runix.net"

  name      = "pgadmin"
  namespace = kubernetes_namespace_v1.pgadmin.metadata[0].name

  set {
    name  = "resources.requests.memory"
    value = "384Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "384Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "env.email"
    value = var.pgadmin_email
  }

  set {
    name  = "env.password"
    value = var.pgadmin_password
  }

  set {
    name  = "persistentVolume.storageClass"
    value = "longhorn"
  }
}

resource "kubernetes_manifest" "pgadmin_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "pgadmin"
      namespace = kubernetes_namespace_v1.pgadmin.metadata[0].name
    }
    spec = {
      entryPoints = ["internal"]
      routes = [
        {
          match = "Host(`pga.int.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "pgadmin"
              port = "http"
            }
          ]
        }
      ]
    }
  }
}
