resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  version    = var.chart_cert_manager_version
  repository = "https://charts.jetstack.io"

  name        = "cert-manager"
  namespace   = kubernetes_namespace_v1.cert_manager.metadata[0].name
  max_history = 2

  values = [
    file("${path.module}/values/cert-manager-values.yaml")
  ]
}

resource "helm_release" "cert_manager_webhook_scaleway" {
  chart      = "scaleway-certmanager-webhook"
  version    = var.chart_cert_manager_webhook_scaleway_version
  repository = "https://helm.scw.cloud"

  name        = "scw"
  namespace   = kubernetes_namespace_v1.cert_manager.metadata[0].name
  max_history = 2

  values = [
    file("${path.module}/values/scw-values.yaml")
  ]

  set {
    name  = "secret.accessKey"
    value = var.scaleway_dns_access_key
  }

  set {
    name  = "secret.secretKey"
    value = var.scaleway_dns_secret_key
  }

  depends_on = [helm_release.cert_manager]
}
