resource "kubernetes_namespace_v1" "gitea" {
  metadata {
    name = "gitea"
  }
}

resource "helm_release" "gitea" {
  chart      = "gitea"
  version    = var.chart_gitea_version
  repository = "https://dl.gitea.io/charts"

  name      = "gitea"
  namespace = kubernetes_namespace_v1.gitea.metadata[0].name

  values = [
    templatefile("${path.module}/values/gitea-values.yaml", {
      domain           = var.domain,
      db_password      = var.gitea_db_password,
      redis_connection = "redis+cluster://:${urlencode(var.redis_password)}@redis-cluster.redis:6379/0",
      smtp_host        = var.smtp_host,
      smtp_port        = var.smtp_port,
      smtp_user        = var.smtp_user,
      smtp_password    = var.smtp_password,
      pvc_name         = var.gitea_pvc_name,
    })
  ]

  set {
    name  = "gitea.admin.username"
    value = var.gitea_admin_username
  }

  set {
    name  = "gitea.admin.password"
    value = var.gitea_admin_password
  }

  set {
    name  = "gitea.admin.email"
    value = var.gitea_admin_email
  }
}

resource "kubernetes_manifest" "gitea_ingress" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "gitea-http"
      namespace = kubernetes_namespace_v1.gitea.metadata[0].name
    }
    spec = {
      entryPoints = [var.entry_point]
      routes = [
        {
          match = "Host(`gitea.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "gitea-http"
              port = 3000
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "gitea_ingress_ssh" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "gitea-ssh"
      namespace = kubernetes_namespace_v1.gitea.metadata[0].name
    }
    spec = {
      entryPoints = ["ssh"]
      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "gitea-ssh"
              port = 22
            }
          ]
        }
      ]
    }
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
        "gitea.${var.domain}" = {
          auth = base64encode("${var.gitea_admin_username}:${var.gitea_admin_password}")
        }
      }
    })
  }
}
