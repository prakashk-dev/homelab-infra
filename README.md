# homelab-infra

The **platform**. Everything that makes the cluster exist and stay healthy lives here:
host provisioning, k3s, ingress + TLS, Pi-hole, the Cloudflare Tunnel, GitOps (ArgoCD),
and the Terraform that manages Cloudflare. Applications live in **separate repos** (e.g.
`hello-world`) and are registered with ArgoCD via `argocd/apps/*.yaml`.

Target node: bare-metal Ubuntu Server 24.04 LTS (amd64) on a 2014 Intel Mac mini, hostname `homelab`.

## Before you start
See **VARIABLES.md** for every placeholder. Most live in `ansible/group_vars/all.yml`.

## Bring-up order
1. OS install — `docs/os-install.md` (the one manual step).
2. `cd ansible && ansible-playbook playbook.yml` — k3s, drivers, helm, sops, ArgoCD.
3. Delegate `pkandel.com` nameservers VentraIP → Cloudflare (`docs/runbook.md`).
4. Create the age key; encrypt the two secrets under `secrets/` (`secrets/README.md`).
5. `cd terraform/cloudflare && terraform apply` — tunnel + DNS records.
6. Commit + push. ArgoCD reconciles `cluster/` and everything under `argocd/apps/`.
7. Point your router DNS at Pi-hole's LAN IP.

## Layout
```
ansible/     host provisioning + k3s + ArgoCD bootstrap
cluster/     addons ArgoCD watches (cert-manager, cloudflared, pihole, traefik)
argocd/      projects + app-of-apps roots + per-app Application manifests
terraform/   Cloudflare tunnel + DNS as code
secrets/     SOPS-encrypted secrets (only *.enc.yaml committed)
docs/        os-install, runbook, recovery, ADRs
```
