# ADR 0003 — Cloudflare Tunnel, not port-forwarding

Context: consumer router (Tenda MW6) can't codify port-forwards; want no open inbound ports.
Decision: cloudflared tunnel, Terraform-managed. Consequence: no static IP needed, home IP
hidden, DNS + routing as code. Pi-hole DNS stays LAN-only (never tunneled).
