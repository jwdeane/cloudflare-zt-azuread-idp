# Azure Users 
resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    local.domain_name
  )

  password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )
  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department = each.value.department
  job_title = each.value.job_title
}

# Azure Groups
resource "azuread_group" "education" {
  display_name     = "Education Department"
  security_enabled = true
}

resource "azuread_group_member" "education" {
  for_each = { for u in azuread_user.users : u.mail_nickname => u if u.department == "Education" }

  group_object_id  = azuread_group.education.id
  member_object_id = each.value.id
}

resource "azuread_group" "managers" {
  display_name     = "Education - Managers"
  security_enabled = true
}

resource "azuread_group_member" "managers" {
  for_each = { for u in azuread_user.users : u.mail_nickname => u if u.job_title == "Manager" }

  group_object_id  = azuread_group.managers.id
  member_object_id = each.value.id
}

resource "azuread_group" "engineers" {
  display_name     = "Education - Engineers"
  security_enabled = true
}

resource "azuread_group_member" "engineers" {
  for_each = { for u in azuread_user.users : u.mail_nickname => u if u.job_title == "Engineer" }

  group_object_id  = azuread_group.engineers.id
  member_object_id = each.value.id
}

resource "azuread_group" "customer_success" {
  display_name     = "Education - Customer Success"
  security_enabled = true
}

resource "azuread_group_member" "customer_success" {
  for_each = { for u in azuread_user.users : u.mail_nickname => u if u.job_title == "Customer Success" }

  group_object_id  = azuread_group.customer_success.id
  member_object_id = each.value.id
}

# Azure AD Cloudflare Access Application
resource "azuread_application" "default" {
  display_name = "Cloudflare Access"
  owners = [ data.azuread_client_config.current.object_id ]

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
