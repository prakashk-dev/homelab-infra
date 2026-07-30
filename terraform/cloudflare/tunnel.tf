resource "cloudflare_zero_trust_tunnel_cloudflared" "home" {
  account_id = var.cloudflare_account_id
  name       = "homelab-mini"
  secret     = var.tunnel_secret
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home.id
  config {
    dynamic "ingress_rule" {
      for_each = local.app_hostnames
      content {
        hostname = "${ingress_rule.value}.${var.domain}"
        service  = "http://traefik.kube-system:80"
      }
    }
    # required catch-all, must be last
    ingress_rule {
      service = "http_status:404"
    }
  }
}

output "tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.home.tunnel_token
  sensitive = true
}
