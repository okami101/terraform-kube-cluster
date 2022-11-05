resource "helm_release" "kubereboot" {
  chart   = "kubereboot/kured"
  version = "4.1.0"

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
