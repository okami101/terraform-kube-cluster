resource "kubernetes_namespace_v1" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "tempo" {
  chart      = "tempo"
  version    = "1.3.1"
  repository = "https://grafana.github.io/helm-charts"

  name      = "tempo"
  namespace = kubernetes_namespace_v1.tracing.metadata[0].name

  values = [
    templatefile("${path.module}/values/tempo-values.yaml", {
      bucket : var.s3_bucket
      endpoint : var.s3_endpoint
      region : var.s3_region
      access_key : var.s3_access_key
      secret_key : var.s3_secret_key
    })
  ]
}