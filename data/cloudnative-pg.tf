locals {
  barman_object_store = {
    endpointURL     = "https://${var.s3_endpoint}"
    destinationPath = "s3://${var.s3_bucket}"
    serverName      = "pgbackup"
    data = {
      compression = "bzip2"
    }
    wal = {
      compression = "bzip2"
    }
    s3Credentials = {
      accessKeyId = {
        name = kubernetes_secret_v1.cluster_s3.metadata[0].name
        key  = "ACCESS_KEY_ID"
      }
      secretAccessKey = {
        name = kubernetes_secret_v1.cluster_s3.metadata[0].name
        key  = "ACCESS_SECRET_KEY"
      }
      region = {
        name = kubernetes_secret_v1.cluster_s3.metadata[0].name
        key  = "REGION"
      }
    }
  }
}

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
    REGION            = var.s3_region
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
      postgresql = {
        parameters = {
          archive_mode               = "on"
          archive_timeout            = "5min"
          dynamic_shared_memory_type = "posix"
          log_destination            = "csvlog"
          log_directory              = "/controller/log"
          log_filename               = "postgres"
          log_rotation_age           = "0"
          log_rotation_size          = "0"
          log_truncate_on_rotation   = "false"
          logging_collector          = "on"
          max_connections            = "200"
          max_parallel_workers       = "32"
          max_replication_slots      = "32"
          max_worker_processes       = "32"
          shared_memory_type         = "mmap"
          shared_preload_libraries   = ""
          ssl_max_protocol_version   = "TLSv1.3"
          ssl_min_protocol_version   = "TLSv1.3"
          wal_keep_size              = "512MB"
          wal_level                  = "logical"
          wal_log_hints              = "on"
          wal_receiver_timeout       = "5s"
          wal_sender_timeout         = "5s"
        }
      }

      storage = {
        size         = "8Gi"
        storageClass = "longhorn-fast"
      }

      resources = {
        requests = {
          memory = "2Gi"
          cpu    = "500m"
        }
        limits = {
          memory = "2Gi"
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

      backup = {
        target            = "prefer-standby"
        retentionPolicy   = "30d"
        barmanObjectStore = local.barman_object_store
      }

      externalClusters = [
        {
          name              = "clusterBackup"
          barmanObjectStore = local.barman_object_store
        }
      ]
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
      schedule             = "0 0 0 * * *"
      backupOwnerReference = "self"
      immediate            = true
      cluster = {
        name = kubernetes_manifest.cnpg_cluster.manifest.metadata.name
      }
    }
  }
}

resource "kubernetes_manifest" "cnpg_pooler" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Pooler"
    metadata = {
      name      = "pooler-cluster-rw"
      namespace = kubernetes_namespace_v1.cnpg.metadata[0].name
    }
    spec = {
      cluster = {
        name = kubernetes_manifest.cnpg_cluster.manifest.metadata.name
      }
      instances = 2
      type      = "rw"
      monitoring = {
        enablePodMonitor = true
      }
      pgbouncer = {
        poolMode = "session"
        parameters = {
          max_client_conn   = "1000"
          default_pool_size = "10"
        }
      }
    }
  }
}
