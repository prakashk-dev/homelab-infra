# secrets (env-file, never committed)

Only two secrets are applied by you (everything else is pure GitOps): the Cloudflare API token
(cert-manager) and the tunnel token (cloudflared). Both come from `secrets/.env`, which is
**gitignored** — it stays on your machine and is never pushed.

## Setup
```
cp .env.example .env      # then fill in real values
```

## Apply the secrets to the cluster
Plain k8s YAML does NOT expand env vars, so we substitute with `envsubst` (gettext;
`brew install gettext` on macOS, preinstalled on Ubuntu):
```
set -a; . secrets/.env; set +a
envsubst < secrets/cloudflare-api-token.tmpl.yaml | kubectl apply -f -
envsubst < secrets/tunnel-token.tmpl.yaml         | kubectl apply -f -
```

Terraform picks up the `TF_VAR_*` values from the same loaded env — no tfvars file needed.
Note: `TUNNEL_TOKEN` is a terraform *output*, so it stays blank until after `terraform apply`.
