locals {
  # Add a subdomain here to expose a new app through the tunnel, then `terraform apply`.
  # This is an explicit allowlist of what is reachable from the internet.
  # (Pi-hole is deliberately absent — it stays LAN-only.)
  app_hostnames = ["www", "app"]
}
