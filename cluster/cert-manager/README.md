# cert-manager

Install cert-manager itself once (it's a prerequisite). This dir adds the ClusterIssuer
(Let's Encrypt DNS-01 via Cloudflare) and a wildcard `*.pkandel.com` cert. Apps reference the
shared `wildcard-pkandel-tls` secret, so new hostnames need no cert changes. The
`cloudflare-api-token` secret is applied out-of-band from `secrets/` (SOPS), never in plaintext.
