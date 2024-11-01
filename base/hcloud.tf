resource "kubernetes_secret_v1" "hcloud" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"
  }

  data = {
    "token" = var.hcloud_token
  }
}

resource "helm_release" "hccm" {
  chart      = "hcloud-cloud-controller-manager"
  version    = var.chart_hccm_version
  repository = "https://charts.hetzner.cloud"

  name      = "hccm"
  namespace = "kube-system"

  set {
    name  = "env.HCLOUD_LOAD_BALANCERS_LOCATION"
    value = var.hcloud_lb_location
  }
}
