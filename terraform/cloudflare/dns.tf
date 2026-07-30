resource "cloudflare_record" "apps" {
  for_each = toset(local.app_hostnames)
  zone_id  = var.cloudflare_zone_id
  name     = each.value
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.home.id}.cfargotunnel.com"
  type     = "CNAME"
  proxied  = true
}
