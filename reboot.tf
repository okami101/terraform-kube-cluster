resource "helm_release" "kubereboot" {
  chart      = "kured"
  version    = "4.5.1"
  repository = "https://kubereboot.github.io/charts"

  name = "kured"

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
}
