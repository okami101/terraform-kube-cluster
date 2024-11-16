resource "helm_release" "cilium" {
  chart      = "cilium"
  version    = var.chart_cilium_version
  repository = "https://helm.cilium.io"

  name      = "cilium"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/values/cilium-values.yaml", {
      network_cluster_cidr = var.network_cluster_cidr
    })
  ]
}
