locals {
  certificate_secret_name = "tls-cert"
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
                groupName  = "acme.scaleway.com"
                solverName = "scaleway"
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
        "*.${var.internal_domain}",
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
