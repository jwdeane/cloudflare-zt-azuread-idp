variable "cloudflare_account_id" {}
variable "cloudflare_api_key" {}
variable "cloudflare_domain" {}
variable "cloudflare_email" {}
# variable "cloudflare_zone_id" {}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}

provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
  account_id = var.cloudflare_account_id
}
