resource "kubernetes_namespace_v1" "gitea" {
  metadata {
    name = "gitea"
  }
}

resource "helm_release" "gitea" {
  chart   = "gitea-charts/gitea"
  version = "7.0.0"

  name      = "gitea"
  namespace = kubernetes_namespace_v1.gitea.metadata[0].name

  values = [
    templatefile("values/gitea-values.yaml", {
      domain        = var.domain,
      db_password   = var.gitea_db_password,
      smtp_host     = var.smtp_host,
      smtp_port     = var.smtp_port,
      smtp_user     = var.smtp_user,
      smtp_password = var.smtp_password,
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
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "gitea-http"
      namespace = kubernetes_namespace_v1.gitea.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`gitea.${var.domain}`)"
          kind  = "Rule"
          services = [
            {
              name = "gitea-http"
              kind = "Service"
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
    apiVersion = "traefik.containo.us/v1alpha1"
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
