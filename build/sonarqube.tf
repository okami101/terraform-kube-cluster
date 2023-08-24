resource "kubernetes_namespace_v1" "sonarqube" {
  metadata {
    name = "sonarqube"
  }
}

resource "helm_release" "sonarqube" {
  chart      = "sonarqube"
  version    = var.chart_sonarqube_version
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"

  name      = "sonarqube"
  namespace = kubernetes_namespace_v1.sonarqube.metadata[0].name

  values = [
    file("${path.module}/values/sonarqube-values.yaml")
  ]

  set {
    name  = "jdbcOverwrite.jdbcPassword"
    value = var.sonarqube_db_password
  }
}

resource "kubernetes_manifest" "sonarqube_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "sonarqube"
      namespace = kubernetes_namespace_v1.sonarqube.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`sonarqube.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "sonarqube-sonarqube"
              port = "http"
            }
          ]
        }
      ]
    }
  }
}
