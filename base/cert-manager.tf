resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  version    = var.chart_cert_manager_version
  repository = "https://charts.jetstack.io"

  name      = "cert-manager"
  namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name

  values = [
    file("${path.module}/values/cert-manager-values.yaml")
  ]
}
