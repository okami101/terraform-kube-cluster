locals {
  certificate_secret_name = "default-certificate"
}

resource "kubernetes_manifest" "default_tls_store" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "TLSStore"
    metadata = {
      name      = "default"
      namespace = "default"
    }
    spec = {
      defaultCertificate = {
        secretName = local.certificate_secret_name
      }
    }
  }
}

resource "kubernetes_secret" "hetzner_secret" {
  metadata {
    name      = "hetzner-secret"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    api-key = var.hetzner_dns_api_key
  }
}

resource "kubernetes_manifest" "letsencrypt_production_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }
    spec = {
      acme = {
        email = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-production"
        }
        server = "https://acme-v02.api.letsencrypt.org/directory"
        solvers = [
          {
            dns01 = {
              webhook = {
                config = {
                  apiUrl     = "https://dns.hetzner.com/api/v1"
                  secretName = kubernetes_secret.hetzner_secret.metadata[0].name
                  zoneName   = var.zone_name
                }
                groupName  = var.cert_group_name
                solverName = "hetzner"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "default_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "default-certificate"
      namespace = "default"
    }
    spec = {
      commonName = var.domain
      dnsNames = [
        var.domain,
        "*.${var.domain}",
      ]
      issuerRef = {
        kind = kubernetes_manifest.letsencrypt_production_issuer.manifest.kind
        name = kubernetes_manifest.letsencrypt_production_issuer.manifest.metadata.name
      }
      secretName = local.certificate_secret_name
    }
  }
}
