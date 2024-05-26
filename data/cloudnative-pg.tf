resource "kubernetes_namespace_v1" "cnpg" {
  metadata {
    name = "cnpg"
  }
}

resource "helm_release" "cnpg" {
  chart      = "cloudnative-pg"
  version    = var.chart_cnpg_version
  repository = "https://cloudnative-pg.github.io/charts"

  name      = "cnpg"
  namespace = kubernetes_namespace_v1.cnpg.metadata[0].name

  set {
    name  = "monitoring.podMonitorEnabled"
    value = "true"
  }

  set {
    name  = "monitoring.grafanaDashboard.create"
    value = "true"
  }

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1000m"
  }
}

resource "kubernetes_secret_v1" "cluster_auth" {
  metadata {
    name      = "cluster-auth"
    namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
  }
  type = "kubernetes.io/basic-auth"
  data = {
    username = var.pgsql_user
    password = var.pgsql_password
  }
}

resource "kubernetes_secret_v1" "cluster_s3" {
  metadata {
    name      = "cluster-s3"
    namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
  }
  data = {
    ACCESS_KEY_ID     = var.s3_access_key
    ACCESS_SECRET_KEY = var.s3_secret_key
  }
}

resource "kubernetes_manifest" "cnpg_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "cluster"
      namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
    }
    spec = {
      imageName   = "ghcr.io/cloudnative-pg/postgresql:16"
      description = "PostgreSQL Okami101"
      instances   = 2

      bootstrap = {
        initdb = {
          database = var.pgsql_user
          owner    = var.pgsql_user
          secret = {
            name = kubernetes_secret_v1.cluster_auth.metadata[0].name
          }
        }
      }

      enableSuperuserAccess = true

      storage = {
        size         = "8Gi"
        storageClass = "longhorn-fast"
      }

      resources = {
        requests = {
          memory = "1Gi"
          cpu    = "500m"
        }
        limits = {
          memory = "1Gi"
          cpu    = "2"
        }
      }

      affinity = {
        tolerations = [
          {
            key      = "node-role.kubernetes.io/storage"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          "node-role.kubernetes.io/storage" = "true"
        }
      }

      monitoring = {
        enablePodMonitor = true
      }
    }

    backup = {
      barmanObjectStore = {
        destinationPath = "s3://${var.s3_bucket}@${var.s3_region}/"
        s3Credentials = {
          accessKeyId = {
            name = "cluster-s3"
            key  = "ACCESS_KEY_ID"
          }
          secretAccessKey = {
            name = "cluster-s3"
            key  = "ACCESS_SECRET_KEY"
          }
        }
      }
      retentionPolicy = "30d"
    }
  }

  depends_on = [
    helm_release.cnpg,
    kubernetes_secret_v1.cluster_auth
  ]
}

resource "kubernetes_manifest" "cnpg_scheduled_backup" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "backup-cluster"
      namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
    }
    spec = {
      schedule             = "0 0 22 * * *"
      backupOwnerReference = "self"
      cluster = {
        name = kubernetes_manifest.cnpg_cluster.metadata[0].name
      }
    }
  }
}
