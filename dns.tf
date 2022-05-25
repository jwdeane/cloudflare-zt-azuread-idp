# Subdomain for testing Azure AD
resource "cloudflare_zone" "default" {
  zone = var.cloudflare_domain
}

resource "cloudflare_record" "azure_custom_domain" {
  zone_id = cloudflare_zone.default.id
  type = "TXT"
  name = "@"
  value = var.azure_custom_domain_txt
}
