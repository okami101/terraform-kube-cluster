resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

resource "helm_release" "loki" {
  chart      = "loki"
  version    = var.chart_loki_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "loki"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("${path.module}/values/loki-values.yaml")
  ]

  set {
    name  = "loki.storage.bucketNames.chunks"
    value = var.s3_bucket
  }

  set {
    name  = "loki.storage.bucketNames.ruler"
    value = var.s3_bucket
  }

  set {
    name  = "loki.storage.bucketNames.admin"
    value = var.s3_bucket
  }

  set {
    name  = "loki.storage.s3.endpoint"
    value = var.s3_endpoint
  }

  set {
    name  = "loki.storage.s3.region"
    value = var.s3_region
  }

  set {
    name  = "loki.storage.s3.accessKeyId"
    value = var.s3_access_key
  }

  set {
    name  = "loki.storage.s3.secretAccessKey"
    value = var.s3_secret_key
  }

  set {
    name  = "loki.limits_config.retention_period"
    value = var.loki_retention_period
  }
}

resource "helm_release" "promtail" {
  chart      = "promtail"
  version    = var.chart_promtail_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "promtail"
  namespace = kubernetes_namespace_v1.logging.metadata[0].name

  values = [
    file("${path.module}/values/promtail-values.yaml")
  ]
}

resource "kubernetes_config_map_v1" "loki_grafana_datasource" {
  metadata {
    name      = "loki-grafana-datasource"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = <<EOF
apiVersion: 1
datasources:
- name: Loki
  type: loki
  uid: loki
  url: http://loki-gateway.logging
  access: proxy
  jsonData:
    derivedFields:
      - datasourceName: Tempo
        matcherRegex: "\\|(\\w+)\\|"
        name: TraceID
        url: "$$${__value.raw}"
        datasourceUid: tempo
EOF
  }
}
