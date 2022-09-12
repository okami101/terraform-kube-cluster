resource "helm_release" "elasticsearch-exporter" {
  chart   = "prometheus-community/prometheus-elasticsearch-exporter"
  version = "4.14.0"

  name      = "elasticsearch-exporter"
  namespace = kubernetes_namespace.elastic.metadata[0].name

  set {
    name  = "es.uri"
    value = "http://db.elastic:9200"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}

resource "helm_release" "mysql-exporter" {
  chart   = "prometheus-community/prometheus-mysql-exporter"
  version = "1.9.0"

  name      = "mysql-exporter"
  namespace = kubernetes_namespace.mysql.metadata[0].name

  set {
    name  = "mysql.host"
    value = "db.mysql"
  }

  set {
    name  = "mysql.user"
    value = "exporter"
  }

  set {
    name  = "mysql.pass"
    value = var.mysql_exporter_password
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}

resource "helm_release" "postgres-exporter" {
  chart   = "prometheus-community/prometheus-postgres-exporter"
  version = "3.1.3"

  name      = "postgres-exporter"
  namespace = kubernetes_namespace.postgres.metadata[0].name

  set {
    name  = "config.datasourceSecret.name"
    value = "postgres-secret"
  }

  set {
    name  = "config.datasourceSecret.key"
    value = "datasources"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}

resource "helm_release" "redis-exporter" {
  chart   = "prometheus-community/prometheus-redis-exporter"
  version = "5.1.0"

  name      = "redis-exporter"
  namespace = kubernetes_namespace.redis.metadata[0].name

  set {
    name  = "redisAddress"
    value = "redis://db.redis:6379"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}
