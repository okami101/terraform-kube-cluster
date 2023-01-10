resource "kubernetes_namespace_v1" "velero" {
  metadata {
    name = "velero"
  }
}

resource "helm_release" "velero" {
  chart   = "velero/velero"
  version = "3.1.0"

  name      = "velero"
  namespace = kubernetes_namespace_v1.velero.metadata[0].name

  values = [
    file("values/velero-values.yaml")
  ]

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.velero_bucket
  }

  set {
    name  = "credentials.existingSecret"
    value = "cloud-credentials"
  }
}

locals {
  schedules = [
    {
      name     = "hourly"
      schedule = "0 */1 * * *"
      ttl      = "24h0m0s"
    },
    {
      name     = "daily"
      schedule = "15 0 * * *"
      ttl      = "168h0m0s"
    },
    {
      name     = "weekly"
      schedule = "30 0 * * 1"
      ttl      = "720h0m0s"
    },
    {
      name     = "monthly"
      schedule = "45 0 1 * *"
      ttl      = "2160h0m0s"
    }
  ]
}

resource "kubernetes_manifest" "velero_schedules" {
  for_each = { for schedule in local.schedules : schedule.name => schedule }
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace_v1.velero.metadata[0].name
    }
    spec = {
      schedule = each.value.schedule
      template = {
        ttl = each.value.ttl
      }
    }
  }
  depends_on = [
    helm_release.velero,
  ]
}
