resource "helm_release" "grafana" {
  chart   = "grafana/grafana"
  version = "6.37.2"

  name      = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  set {
    name  = "initChownData.enabled"
    value = false
  }

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "sidecar.dashboards.enabled"
    value = true
  }

  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/monitor"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

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
    value = var.smtp_host
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
    value = "db.postgres"
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

  set {
    name  = "env.GF_REMOTE_CACHE_TYPE"
    value = "redis"
  }

  set {
    name  = "env.GF_REMOTE_CACHE_CONNSTR"
    value = "addr=db.redis"
  }
}

resource "kubernetes_manifest" "grafana_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
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
