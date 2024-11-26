resource "kubernetes_persistent_volume_claim_v1" "grafana" {
  metadata {
    name      = "grafana-data"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    volume_name        = "grafana"
    storage_class_name = "longhorn-static"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "helm_release" "grafana" {
  chart      = "grafana"
  version    = var.chart_grafana_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "grafana"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    file("${path.module}/values/grafana-values.yaml")
  ]

  set {
    name  = "persistence.existingClaim"
    value = "grafana-data"
  }

  set {
    name  = "env.GF_SERVER_DOMAIN"
    value = "grafana.${var.internal_domain}"
  }

  set {
    name  = "env.GF_SERVER_ROOT_URL"
    value = "https://grafana.${var.internal_domain}"
  }

  set {
    name  = "env.GF_SMTP_ENABLED"
    value = "true"
  }

  set {
    name  = "env.GF_SMTP_HOST"
    value = "${var.smtp_host}:${var.smtp_port}"
  }

  set {
    name  = "env.GF_SMTP_USER"
    value = var.smtp_user
  }

  set {
    name  = "env.GF_SMTP_PASSWORD"
    value = var.smtp_password
  }

  set {
    name  = "env.GF_SMTP_FROM_ADDRESS"
    value = "grafana@${var.internal_domain}"
  }

  set {
    name  = "sidecar.dashboards.searchNamespace"
    value = "ALL"
  }
}

resource "kubernetes_manifest" "grafana_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["private"]
      routes = [
        {
          match = "Host(`grafana.${var.internal_domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "grafana"
              port = "service"
            }
          ]
        }
      ]
    }
  }
}
