locals {
  certificate_secret_name = "tls-cert"
}

resource "kubernetes_secret_v1" "hetzner_secret" {
  metadata {
    name      = "hetzner-secret"
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
  }

  data = {
    "api-key" = var.hetzner_dns_api_key
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
                  secretName = kubernetes_secret_v1.hetzner_secret.metadata[0].name
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

resource "kubernetes_manifest" "tls_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "default-certificate"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
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
      privateKey = {
        rotationPolicy = "Always"
      }
    }
  }
}
