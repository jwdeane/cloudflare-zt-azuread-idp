# Subdomain for testing Azure AD
resource "cloudflare_zone" "azure_cflr_win" {
  zone = "${var.cloudflare_domain}"
}

resource "cloudflare_record" "azure_custom_domain" {
  zone_id = cloudflare_zone.azure_cflr_win.id
  type = "TXT"
  name = "@"
  value = var.azure_custom_domain_txt
}
