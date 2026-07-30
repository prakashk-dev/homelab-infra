variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
variable "cloudflare_account_id" {
  type = string
}
variable "cloudflare_zone_id" {
  type = string
}
variable "domain" {
  type    = string
  default = "pkandel.com"
}
variable "tunnel_secret" {
  type        = string
  sensitive   = true
  description = "32+ byte base64 secret (openssl rand -base64 32)"
}
