resource "helm_release" "kured" {
  chart      = "kured"
  version    = var.chart_kured_version
  repository = "https://kubereboot.github.io/charts"

  name        = "kured"
  namespace   = "kube-system"
  max_history = 2

  values = [
    file("${path.module}/values/kured-values.yaml")
  ]
}
