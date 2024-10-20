locals {
  barman_object_store = {
    endpointURL     = "https://${var.s3_endpoint}"
    destinationPath = "s3://${var.s3_bucket}"
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
