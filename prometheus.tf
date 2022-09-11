resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  chart   = "prometheus-community/kube-prometheus-stack"
  version = "39.11.0"

  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("values/prometheus-stack-values.yaml")
  ]
}

resource "kubernetes_manifest" "prometheus_ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name : "prometheus"
      namespace : kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`prom.${var.domain}`)"
          kind  = "Rule"
          middlewares = [
            {
              name = kubernetes_manifest.prometheus_middleware_auth.manifest.metadata.name
            }
          ]
          services = [
            {
              name = "prometheus-operated"
              kind = "Service"
              port = 9090
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "prometheus_middleware_auth" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name : "middleware-auth"
      namespace : kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret.prometheus_auth_secret.metadata[0].name
      }
    }
  }
}

resource "kubernetes_secret" "prometheus_auth_secret" {
  metadata {
    name      = "auth-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    users = var.basic_http_auth
  }
}
