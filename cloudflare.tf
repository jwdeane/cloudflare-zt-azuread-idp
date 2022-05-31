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

# Access Application Catch-all
resource "cloudflare_access_application" "catch_all" {
  zone_id = var.cloudflare_zone_id
  name = "Azure Test App"
  domain = var.cloudflare_zone
  type = "self_hosted"
  session_duration = "24h"
  allowed_idps = [ cloudflare_access_identity_provider.default.id ]
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "catch_all" {
  application_id = cloudflare_access_application.catch_all.id
  zone_id = cloudflare_access_application.catch_all.zone_id
  name = "Allow Azure AD Users"
  precedence = 1
  decision = "allow"

  include {
    login_method = [ cloudflare_access_identity_provider.default.id ] # allow all Azure AD Users
  }
}

# Access Application Managers
resource "cloudflare_access_application" "managers" {
  zone_id = var.cloudflare_zone_id
  name = "Azure Test App - Managers"
  domain = "${var.cloudflare_zone}/managers"
  type = "self_hosted"
  session_duration = "24h"
  allowed_idps = [ cloudflare_access_identity_provider.default.id ]
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "managers" {
  application_id = cloudflare_access_application.managers.id
  zone_id = cloudflare_access_application.managers.zone_id
  name = "Allow Azure AD Managers"
  precedence = 1
  decision = "allow"

  include {
    group = [ cloudflare_access_group.managers.id ]
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

# Worker Application
resource "cloudflare_record" "worker" {
  zone_id = var.cloudflare_zone_id
  type = "AAAA"
  name = "@"
  value = "100::"
  proxied = true
}

resource "cloudflare_worker_route" "default" {
  zone_id = var.cloudflare_zone_id
  pattern = "${cloudflare_record.worker.hostname}/*"
  script_name = cloudflare_worker_script.default.name
}

resource "cloudflare_worker_script" "default" {
  name = "azure-app"
  content = file("script.js")
}