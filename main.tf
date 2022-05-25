# Cloudflare vars
variable "cloudflare_account_id" {}
variable "cloudflare_api_key" {}
variable "cloudflare_domain" {}
variable "cloudflare_email" {}
variable "cloudflare_zone_id" {}
variable "cloudflare_zt_domain" {}
# Azure vars
variable "azure_arm_tenant_id" {}
variable "azure_custom_domain_txt" {}

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

provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
  account_id = var.cloudflare_account_id
}

provider "azuread" {
  tenant_id = var.azure_arm_tenant_id
}

data "azuread_domains" "default" {
  only_default = true
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users = csvdecode(file("${path.module}/users.csv"))
}
