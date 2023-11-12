resource "kubernetes_namespace_v1" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  chart      = "longhorn"
  version    = var.chart_longhorn_version
  repository = "https://charts.longhorn.io"

  name      = "longhorn"
  namespace = kubernetes_namespace_v1.longhorn.metadata[0].name

  values = [
    file("${path.module}/values/longhorn-values.yaml")
  ]
}

resource "kubernetes_manifest" "longhorn_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "longhorn"
      namespace = kubernetes_namespace_v1.longhorn.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`longhorn.cp.${var.domain}`)"
          kind  = "Rule"
          middlewares = [for middleware in var.middlewares.longhorn : {
            namespace = "traefik"
            name      = "middleware-${middleware}"
          }]
          services = [
            {
              name = "longhorn-frontend"
              port = "http"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "longhorn_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "metrics"
      namespace = kubernetes_namespace_v1.longhorn.metadata[0].name
    }
    spec = {
      endpoints = [
        {
          port = "manager"
        }
      ]
      selector = {
        matchLabels = {
          app = "longhorn-manager"
        }
      }
    }
  }
}

resource "kubernetes_storage_class_v1" "longhorn_fast" {
  metadata {
    name = "longhorn-fast"
  }

  storage_provisioner    = "driver.longhorn.io"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    numberOfReplicas    = "1"
    staleReplicaTimeout = "30"
    fromBackup          = ""
    fsType              = "ext4"
    diskSelector        = "fast"
    dataLocality        = "strict-local"
  }
}

locals {
  job_backups = {
    daily = {
      cron   = "15 0 * * *"
      retain = 7
    },
    weekly = {
      cron   = "30 0 * * 1"
      retain = 4
    }
    monthly = {
      cron   = "45 0 1 * *"
      retain = 3
    }
  }
}

resource "kubernetes_manifest" "longhorn_jobs" {
  for_each = local.job_backups
  manifest = {
    apiVersion = "longhorn.io/v1beta2"
    kind       = "RecurringJob"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace_v1.longhorn.metadata[0].name
    }
    spec = {
      concurrency = 1
      cron        = each.value.cron
      groups      = ["backup"]
      name        = each.key
      retain      = each.value.retain
      task        = "backup"
    }
  }

  depends_on = [
    helm_release.longhorn
  ]
}
