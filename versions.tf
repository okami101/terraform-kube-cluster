terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">2.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">2.6"
    }
    null = {
      source  = "hashicorp/null"
      version = ">3.1"
    }
  }

  backend "kubernetes" {
    secret_suffix = "state"
  }
}
