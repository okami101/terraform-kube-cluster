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

resource "kubernetes_manifest" "cilium_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "hubble-ui"
      namespace = "kube-system"
    }
    spec = {
      entryPoints = ["private"]
      routes = [
        {
          match = "Host(`hubble.${var.internal_domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "hubble-ui"
              port = "http"
            }
          ]
        }
      ]
    }
  }
}
