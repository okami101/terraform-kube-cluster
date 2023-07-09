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
  }
}
