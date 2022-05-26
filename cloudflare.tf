# Azure AD Custom Domain
resource "cloudflare_record" "azure_custom_domain" {
  zone_id = var.cloudflare_zone_id
  type = "TXT"
  name = "@"
  value = var.azure_custom_domain_txt
}

# Access IdP
resource "cloudflare_access_identity_provider" "default" {
  account_id = var.cloudflare_account_id
  name = "Azure AD"
  type = "azureAD"
  config {
    client_id = azuread_application.default.application_id # application id
    client_secret = azuread_application_password.default.value # application secret
    directory_id = var.azure_arm_tenant_id # tenant id
    support_groups = true
  }
}

# Access Application
resource "cloudflare_access_application" "default" {
  zone_id = var.cloudflare_zone_id
  name = "Azure Test Zone"
  domain = "${var.cloudflare_domain}/*"
  type = "self_hosted"
  session_duration = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "default" {
  application_id = cloudflare_access_application.default.id
  zone_id = cloudflare_access_application.default.zone_id
  name = "Allow Azure AD Users"
  precedence = 1
  decision = "allow"

  include {
    login_method = [ cloudflare_access_identity_provider.default.id ]
  }
}

# Access Groups
resource "cloudflare_access_group" "education" {
  account_id = var.cloudflare_account_id
  name = "Azure Education Department"
  include {
    azure {
      id = [ azuread_group.education.object_id ]
      identity_provider_id = cloudflare_access_identity_provider.default.id
    }
  }
}

resource "cloudflare_access_group" "managers" {
  account_id = var.cloudflare_account_id
  name = "Azure Education - Managers"
  include {
    azure {
      id = [ azuread_group.managers.object_id ]
      identity_provider_id = cloudflare_access_identity_provider.default.id
    }
  }
}

resource "cloudflare_access_group" "engineers" {
  account_id = var.cloudflare_account_id
  name = "Azure Education - Engineers"
  include {
    azure {
      id = [ azuread_group.engineers.object_id ]
      identity_provider_id = cloudflare_access_identity_provider.default.id
    }
  }
}

resource "cloudflare_access_group" "customer_success" {
  account_id = var.cloudflare_account_id
  name = "Azure Education - Customer Success"
  include {
    azure {
      id = [ azuread_group.customer_success.object_id ]
      identity_provider_id = cloudflare_access_identity_provider.default.id
    }
  }
}
