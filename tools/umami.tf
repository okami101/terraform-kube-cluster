resource "kubernetes_namespace_v1" "umami" {
  metadata {
    name = "umami"
  }
}

resource "kubernetes_secret_v1" "umami_secret" {
  metadata {
    name      = "umami-secret"
    namespace = kubernetes_namespace_v1.umami.metadata[0].name
  }

  data = {
    database-url = "postgresql://umami:${urlencode(var.umami_db_password)}@db.postgres/umami"
  }
}

resource "kubernetes_deployment_v1" "umami" {
  metadata {
    name      = "umami"
    namespace = kubernetes_namespace_v1.umami.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "umami"
      }
    }
    template {
      metadata {
        labels = {
          app = "umami"
        }
      }
      spec {
        container {
          name              = "umami"
          image             = "docker.umami.dev/umami-software/umami:postgresql-latest"
          image_pull_policy = "Always"
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = "umami-secret"
                key  = "database-url"
              }
            }
          }
          port {
            container_port = 3000
          }
        }
        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
        }
        node_selector = {
          "node-role.kubernetes.io/master" = "true"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "umami" {
  metadata {
    name      = "umami"
    namespace = kubernetes_namespace_v1.umami.metadata[0].name
  }
  spec {
    selector = {
      app = "umami"
    }
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_manifest" "umami_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "umami"
      namespace = kubernetes_namespace_v1.umami.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`umami.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "umami"
              kind = "Service"
              port = 3000
            }
          ]
        }
      ]
    }
  }
}
