resource "kubernetes_secret_v1" "hcloud" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }
  data = {
    token   = var.hcloud_token
    network = var.hcloud_network_name
  }
}

resource "helm_release" "hccm" {
  chart      = "hcloud-cloud-controller-manager"
  version    = var.chart_hccm_version
  repository = "https://charts.hetzner.cloud"

  name      = "hccm"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/values/hccm-values.yaml", {
      load_balancers_location = var.load_balancers_location
      network_cluster_cidr    = var.network_cluster_cidr
    })
  ]
}
