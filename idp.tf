resource "azuread_application" "default" {
  display_name = "Cloudflare Access"
  owners = [ "xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx" ] # what is this magic number??

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    # it's not easy to find these oauthPermissionScopes ids
    # az ad sp list --filter "appId eq '00000003-0000-0000-c000-000000000000'"| jq '.[].oauth2PermissionScopes[] | select( .value == ("email", "openid", "profile", "offline_access", "User.Read", "Directory.Read.All", "Group.Read.All") ) | { id, value }'
    resource_access {
        id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
        type = "Scope"
    }
    resource_access {
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
        type = "Scope"
    }
    resource_access {
        id   = "5f8c59db-677d-491f-a6b8-5f174b11ec1d" # Group.Read.All
        type = "Scope"
    }
    resource_access {
        id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Directory.Read.All
        type = "Scope"
    }
    resource_access {
        id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
        type = "Scope"
    }
    resource_access {
        id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
        type = "Scope"
    }
    resource_access {
        id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
        type = "Scope"
    }
  }
  web {
    redirect_uris = [ "https://${var.cloudflare_zt_domain}/cdn-cgi/access/callback" ]
  }
}

resource "azuread_application_password" "default" {
  application_object_id = azuread_application.default.object_id
}

resource "cloudflare_access_identity_provider" "default" {
  account_id = var.cloudflare_account_id
  name = "Azure AD"
  type = "azureAD"
  config {
    client_id = azuread_application.default.application_id # application id
    client_secret = azuread_application_password.default.value # application secret
    directory_id = var.azure_arm_tenant_id
    support_groups = true
  }
}
