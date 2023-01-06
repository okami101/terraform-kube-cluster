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
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "mongo"
      namespace = kubernetes_namespace_v1.mongo.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`me.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              name = kubernetes_manifest.mongo_middleware_auth.manifest.metadata.name
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

resource "kubernetes_manifest" "mongo_middleware_auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "middleware-auth"
      namespace = kubernetes_namespace_v1.mongo.metadata[0].name
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.mongo_auth_secret.metadata[0].name
      }
    }
  }
}

resource "kubernetes_secret_v1" "mongo_auth_secret" {
  metadata {
    name      = "auth-secret"
    namespace = kubernetes_namespace_v1.mongo.metadata[0].name
  }

  data = {
    "users" = var.http_basic_auth
  }
}


resource "helm_release" "mongodb_exporter" {
  chart   = "prometheus-community/prometheus-mongodb-exporter"
  version = "3.1.2"

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
}
