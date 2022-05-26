provider "cloudflare" {
  email = var.cloudflare_email
  api_key = var.cloudflare_api_key
  account_id = var.cloudflare_account_id
}

provider "azuread" {
  tenant_id = var.azure_arm_tenant_id
}

data "azuread_client_config" "current" {}
data "azuread_domains" "default" {
  only_default = true # restrict domain(s) to the custom domain you've set as primary
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users = csvdecode(file("${path.module}/users.csv"))
}

resource "random_password" "password" {
  length = 16
}