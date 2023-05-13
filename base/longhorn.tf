resource "kubernetes_namespace_v1" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  chart      = "longhorn"
  version    = "1.4.2"
  repository = "https://charts.longhorn.io"

  name      = "longhorn"
  namespace = kubernetes_namespace_v1.longhorn.metadata[0].name

  set {
    name  = "persistence.defaultClass"
    value = "false"
  }

  set {
    name  = "longhornDriver.tolerations[0].key"
    value = "node-role.kubernetes.io/data"
  }

  set {
    name  = "longhornDriver.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "longhornUI.tolerations[0].key"
    value = "node-role.kubernetes.io/data"
  }

  set {
    name  = "longhornUI.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "longhornRecoveryBackend.tolerations[0].key"
    value = "node-role.kubernetes.io/data"
  }

  set {
    name  = "longhornRecoveryBackend.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "longhornAdmissionWebhook.tolerations[0].key"
    value = "node-role.kubernetes.io/data"
  }

  set {
    name  = "longhornAdmissionWebhook.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "longhornConversionWebhook.tolerations[0].key"
    value = "node-role.kubernetes.io/data"
  }

  set {
    name  = "longhornConversionWebhook.tolerations[0].operator"
    value = "Exists"
  }
}

resource "kubernetes_manifest" "longhorn_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "longhorn"
      namespace = kubernetes_namespace_v1.longhorn.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`longhorn.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-ip"
            },
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
          services = [
            {
              name = "longhorn-frontend"
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "longhorn_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "metrics"
      namespace = kubernetes_namespace_v1.longhorn.metadata[0].name
    }
    spec = {
      endpoints = [
        {
          port = "manager"
        }
      ]
      selector = {
        matchLabels = {
          app = "longhorn-manager"
        }
      }
    }
  }
}
