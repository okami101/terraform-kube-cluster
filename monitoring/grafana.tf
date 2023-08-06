resource "helm_release" "grafana" {
  chart      = "grafana"
  version    = var.chart_grafana_version
  repository = "https://grafana.github.io/helm-charts"

  name      = "grafana"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/values/grafana-values.yaml", {
      pvc_name = var.grafana_pvc_name,
    })
  ]

  set {
    name  = "env.GF_SERVER_DOMAIN"
    value = var.domain
  }

  set {
    name  = "env.GF_SERVER_ROOT_URL"
    value = "https://grafana.${var.domain}"
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
    value = "grafana@${var.domain}"
  }

  set {
    name  = "env.GF_DATABASE_TYPE"
    value = "postgres"
  }

  set {
    name  = "env.GF_DATABASE_HOST"
    value = "postgresql-primary.postgres"
  }

  set {
    name  = "env.GF_DATABASE_NAME"
    value = "grafana"
  }

  set {
    name  = "env.GF_DATABASE_USER"
    value = "grafana"
  }

  set {
    name  = "env.GF_DATABASE_PASSWORD"
    value = var.grafana_db_password
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
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`grafana.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "grafana"
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}
