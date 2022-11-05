resource "kubernetes_namespace_v1" "elastic" {
  metadata {
    name = "elastic"
  }
}

resource "kubernetes_stateful_set_v1" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace_v1.elastic.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }
    service_name = "elasticsearch"
    replicas     = 1
    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }
      spec {
        container {
          name              = "elasticsearch"
          image             = "elasticsearch:7.17.6"
          image_pull_policy = "Always"
          env {
            name  = "xpack.security.enabled"
            value = "false"
          }
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms768m -Xmx768m"
          }
          port {
            container_port = 9200
          }
          port {
            container_port = 9300
          }
          volume_mount {
            name       = "elasticsearch-data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "elasticsearch-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "local-path"
        resources {
          requests = {
            storage = "8Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "elasticsearch" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace_v1.elastic.metadata[0].name
  }
  spec {
    selector = {
      app = "elasticsearch"
    }
    port {
      name        = "api"
      port        = 9200
      target_port = 9200
    }
    port {
      name        = "cluster"
      port        = 9300
      target_port = 9300
    }
  }
}

resource "helm_release" "elasticsearch-exporter" {
  chart   = "prometheus-community/prometheus-elasticsearch-exporter"
  version = "4.15.1"

  name      = "elasticsearch-exporter"
  namespace = kubernetes_namespace_v1.elastic.metadata[0].name

  set {
    name  = "es.uri"
    value = "http://${kubernetes_service_v1.elasticsearch.metadata[0].name}:9200"
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }
}
