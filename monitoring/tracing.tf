resource "kubernetes_namespace_v1" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "tempo" {
  chart      = "tempo"
  version    = var.chart_tempo_version
  repository = "https://grafana.github.io/helm-charts"

  name        = "tempo"
  namespace   = kubernetes_namespace_v1.tracing.metadata[0].name
  max_history = 2

  values = [
    file("${path.module}/values/tempo-values.yaml")
  ]

  set {
    name  = "tempo.storage.trace.s3.bucket"
    value = var.s3_bucket
  }

  set {
    name  = "tempo.storage.trace.s3.endpoint"
    value = var.s3_endpoint
  }

  set {
    name  = "tempo.storage.trace.s3.region"
    value = var.s3_region
  }

  set {
    name  = "tempo.storage.trace.s3.access_key"
    value = var.s3_access_key
  }

  set {
    name  = "tempo.storage.trace.s3.secret_key"
    value = var.s3_secret_key
  }

  set {
    name  = "tempo.retention"
    value = var.tempo_retention_period
  }
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
