resource "kubernetes_namespace_v1" "mongo" {
  metadata {
    name = "mongo"
  }
}

locals {
  mongo_url = "mongodb://root:${urlencode(var.mongo_password)}@${kubernetes_service_v1.mongo.metadata[0].name}:27017"
}

resource "kubernetes_secret_v1" "mongo_secret" {
  metadata {
    name      = "mongo-secret"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }
  data = {
    "mongo-root-password" = var.mongo_password
  }
}

resource "kubernetes_stateful_set_v1" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }

  spec {
    service_name = "mongo"
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          name              = "mongo"
          image             = "mongo:4.2"
          image_pull_policy = "Always"
          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "root"
          }
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mongo_secret.metadata[0].name
                key  = "mongo-root-password"
              }
            }
          }

          port {
            container_port = 27017
          }

          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
        node_selector = {
          "node-role.kubernetes.io/data" = "true"
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "mongo-data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "local-path"
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "mongo_express" {
  metadata {
    name      = "mongo-express"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "mongo-express"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo-express"
        }
      }
      spec {
        container {
          name  = "mongo-express"
          image = "mongo-express:latest"
          env {
            name  = "ME_CONFIG_MONGODB_URL"
            value = local.mongo_url
          }
          env {
            name  = "ME_CONFIG_MONGODB_ADMINUSERNAME"
            value = "root"
          }
          env {
            name = "ME_CONFIG_MONGODB_ADMINPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.mongo_secret.metadata[0].name
                key  = "mongo-root-password"
              }
            }
          }

          port {
            container_port = 8081
          }
        }

        toleration {
          key      = "node-role.kubernetes.io/data"
          operator = "Exists"
        }
        node_selector = {
          "node-role.kubernetes.io/data" = "true"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mongo" {
  metadata {
    name      = "db"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }
  spec {
    selector = {
      app = "mongo"
    }
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

resource "kubernetes_service_v1" "mongo_express" {
  metadata {
    name      = "express"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }
  spec {
    selector = {
      app = "mongo-express"
    }
    port {
      port        = 8081
      target_port = 8081
    }
  }
}

resource "kubernetes_manifest" "mongo_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "mongo"
      namespace = kubernetes_namespace_v1.mongo.metadata[0].name
    }
    spec = {
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`me.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-ip"
            },
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
          services = [
            {
              name = kubernetes_service_v1.mongo_express.metadata[0].name
              kind = "Service"
              port = 8081
            }
          ]
        }
      ]
    }
  }
}

resource "helm_release" "mongodb_exporter" {
  chart      = "prometheus-mongodb-exporter"
  version    = "3.1.3"
  repository = "https://prometheus-community.github.io/helm-charts"

  name      = "mongodb-exporter"
  namespace = kubernetes_namespace_v1.mongo.metadata[0].name

  set {
    name  = "mongodb.uri"
    value = local.mongo_url
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/monitor"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }
}
