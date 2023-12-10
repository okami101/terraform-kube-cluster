resource "helm_release" "kured" {
  chart      = "kured"
  version    = var.chart_kured_version
  repository = "https://kubereboot.github.io/charts"

  name      = "kured"
  namespace = "kube-system"

  set {
    name  = "configuration.period"
    value = "1m"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "metrics.create"
    value = "true"
  }

  set {
    name  = "configuration.forceReboot"
    value = "true"
  }
}
