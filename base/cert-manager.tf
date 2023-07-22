resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  version    = "v1.12.2"
  repository = "https://charts.jetstack.io"

  name      = "cert-manager"
  namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name

  set {
    name  = "prometheus.servicemonitor.enabled"
    value = true
  }
}
