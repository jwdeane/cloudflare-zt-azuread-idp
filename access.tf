resource "cloudflare_access_application" "default" {
  zone_id = var.cloudflare_zone_id
  name = "Azure Zone"
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