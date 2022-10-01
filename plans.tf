resource "kubernetes_manifest" "server_plan" {
  manifest = {
    apiVersion = "upgrade.cattle.io/v1"
    kind       = "Plan"
    metadata = {
      name      = "server-plan"
      namespace = "system-upgrade"
    }
    spec = {
      concurrency = 1
      cordon      = true
      nodeSelector = {
        matchExpressions = [
          {
            key      = "node-role.kubernetes.io/master"
            operator = "Exists"
          }
        ]
      }
      tolerations = [
        {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
      serviceAccountName = "system-upgrade"
      upgrade = {
        image = "rancher/k3s-upgrade"
      }
      channel = "https://update.k3s.io/v1-release/channels/latest"
    }
  }
}

resource "kubernetes_manifest" "agent_plan" {
  manifest = {
    apiVersion = "upgrade.cattle.io/v1"
    kind       = "Plan"
    metadata = {
      name      = "agent-plan"
      namespace = "system-upgrade"
    }
    spec = {
      concurrency = 1
      cordon      = true
      nodeSelector = {
        matchExpressions = [
          {
            key      = "node-role.kubernetes.io/master"
            operator = "DoesNotExist"
          }
        ]
      }
      tolerations = [
        {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
      prepare = {
        args  = ["prepare", "server-plan"]
        image = "rancher/k3s-upgrade"
      }
      serviceAccountName = "system-upgrade"
      upgrade = {
        image = "rancher/k3s-upgrade"
      }
      channel = "https://update.k3s.io/v1-release/channels/latest"
    }
  }
}
