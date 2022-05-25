resource "cloudflare_zone" "azure_cflr_win" {
  zone = "azure.${var.cloudflare_domain}"
}