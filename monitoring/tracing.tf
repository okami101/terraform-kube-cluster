resource "kubernetes_namespace_v1" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "tempo" {
  chart      = "tempo"
  version    = var.chart_tempo_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "tempo"
  namespace = kubernetes_namespace_v1.tracing.metadata[0].name

  values = [
    templatefile("${path.module}/values/tempo-values.yaml", {
      retention_period = var.tempo_retention_period
      bucket           = var.s3_bucket
      endpoint         = var.s3_endpoint
      region           = var.s3_region
      access_key       = var.s3_access_key
      secret_key       = var.s3_secret_key
    })
  ]
}

resource "kubernetes_config_map_v1" "tempo_grafana_datasource" {
  metadata {
    name      = "tempo-grafana-datasource"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = <<EOF
apiVersion: 1
datasources:
- name: Tempo
  type: tempo
  uid: tempo
  url: http://tempo.tracing:3100/
  access: proxy
EOF
  }
}
