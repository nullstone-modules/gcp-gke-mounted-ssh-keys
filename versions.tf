terraform {
  required_providers {
    ns = {
      source = "nullstone-io/ns"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.14"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
