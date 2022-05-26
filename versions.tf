terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.22.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}