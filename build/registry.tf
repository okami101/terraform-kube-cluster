resource "kubernetes_namespace_v1" "registry" {
  metadata {
    name = "registry"
  }
}

resource "kubernetes_config_map_v1" "registry_config" {
  metadata {
    name      = "registry-config"
    namespace = kubernetes_namespace_v1.registry.metadata[0].name
  }

  data = {
    "config.yml" = templatefile("configs/registry-config.tftpl", {
      endpoints = var.registry_endpoints
    })
  }
}

resource "kubernetes_deployment_v1" "registry" {
  metadata {
    name      = "registry"
    namespace = kubernetes_namespace_v1.registry.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "registry"
      }
    }
    template {
      metadata {
        labels = {
          app = "registry"
        }
      }
      spec {
        container {
          name              = "registry"
          image             = "registry:2"
          image_pull_policy = "Always"
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "128Mi"
            }
          }
          env {
            name  = "REGISTRY_STORAGE_DELETE_ENABLED"
            value = "true"
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "registry-data"
            mount_path = "/var/lib/registry"
          }
          volume_mount {
            name       = "registry-config"
            mount_path = "/etc/docker/registry"
          }
        }

        container {
          name              = "registry-ui"
          image             = "joxit/docker-registry-ui"
          image_pull_policy = "Always"
          env {
            name  = "DELETE_IMAGES"
            value = "true"
          }
          env {
            name  = "SINGLE_REGISTRY"
            value = "true"
          }
          port {
            container_port = 80
          }
        }
        volume {
          name = "registry-data"
          persistent_volume_claim {
            claim_name = "registry-data"
          }
        }
        volume {
          name = "registry-config"
          config_map {
            name = kubernetes_config_map_v1.registry_config.metadata[0].name
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "registry_data" {
  metadata {
    name      = "registry-data"
    namespace = kubernetes_namespace_v1.registry.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_service_v1" "registry" {
  metadata {
    name      = "hub"
    namespace = kubernetes_namespace_v1.registry.metadata[0].name
  }
  spec {
    selector = {
      app = "registry"
    }
    port {
      name        = "registry"
      port        = 5000
      target_port = 5000
    }
    port {
      name        = "registry-ui"
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "registry_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "registry"
      namespace = kubernetes_namespace_v1.registry.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`registry.${var.domain}`)  && PathPrefix(`/v2`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
          services = [
            {
              name = kubernetes_service_v1.registry.metadata[0].name
              kind = "Service"
              port = 5000
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "registry_ui_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "registry-ui"
      namespace = kubernetes_namespace_v1.registry.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`registry.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              namespace = "traefik"
              name      = "middleware-auth"
            }
          ]
          services = [
            {
              name = kubernetes_service_v1.registry.metadata[0].name
              kind = "Service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_namespace_v1" "image_pull_secret_namespaces" {
  for_each = toset(var.image_pull_secret_namespaces)
  metadata {
    name = each.value
  }
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  for_each = toset(var.image_pull_secret_namespaces)
  metadata {
    name      = "dockerconfigjson"
    namespace = each.value
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.${var.domain}" = {
          auth = base64encode("${var.http_basic_username}:${var.http_basic_password}")
        }
      }
    })
  }

  depends_on = [
    kubernetes_namespace_v1.image_pull_secret_namespaces
  ]
}
