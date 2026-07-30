# Day-2 runbook

## Prerequisites (control machine)
`git`, `ansible`, `kubectl`, `terraform`, `gettext` (envsubst), `openssl`.
Run everything from the machine you SSH *from* — Ansible/kubectl/terraform reach the node over
the network; you do not SSH into homelab yourself.

---

## First bring-up (DNS already delegated to Cloudflare)

### 1. Fill variables, push both repos (public)
Edit `ansible/group_vars/all.yml` and `ansible/inventory.ini`, then push. Make `homelab-infra`
and `hello-world` **public** so ArgoCD reads them without credentials (only secrets live in
`secrets/.env`, which is gitignored).
```
git init && git add -A && git commit -m "init" && git branch -M main
git remote add origin https://github.com/<you>/<repo>.git && git push -u origin main
```

### 2. Provision the node
```
cd ansible
ansible-playbook playbook.yml            # k3s + helm + cert-manager + ArgoCD
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes                        # homelab Ready
```

### 3. Fill .env, generate tunnel secret
```
cd ../secrets && cp .env.example .env
openssl rand -base64 32                  # -> TF_VAR_tunnel_secret in .env
# also fill CLOUDFLARE_API_TOKEN, account_id, zone_id; leave TUNNEL_TOKEN blank
```

### 4. Create the tunnel + DNS record
```
cd ../terraform/cloudflare
set -a; . ../../secrets/.env; set +a
terraform init && terraform apply
terraform output -raw tunnel_token       # paste into TUNNEL_TOKEN in secrets/.env
```

### 5. Turn on GitOps
```
cd ../../argocd
kubectl apply -f projects.yaml
kubectl apply -f root-cluster.yaml       # cloudflared, pihole, cert-manager CRs, traefik
kubectl apply -f root-apps.yaml          # -> hello-world
kubectl -n argocd get applications       # wait for Synced
```

### 6. Give cloudflared its token (last link)
```
cd ..
set -a; . secrets/.env; set +a
envsubst < secrets/tunnel-token.tmpl.yaml | kubectl apply -f -
kubectl -n cloudflared get pods          # CrashLoop -> Running
```

### 7. Verify
```
curl -I https://www.pkandel.com
```

### Optional: enable origin certs (unblocks the wildcard Certificate + Pi-hole HTTPS)
```
set -a; . secrets/.env; set +a
envsubst < secrets/cloudflare-api-token.tmpl.yaml | kubectl apply -f -
```

---

## Managing deployments AFTER the first bring-up

Once ArgoCD is running, **git is the control plane**. You almost never touch `kubectl apply`
again. The mental model: change YAML → commit → push → ArgoCD reconciles within ~3 minutes
(or instantly if you nudge it).

### Change an existing app (e.g. edit the hello-world page)
```
# in the hello-world repo
vim k8s/configmap.yaml            # edit content / image tag / replicas
git commit -am "update page" && git push
```
ArgoCD notices and syncs. Watch it:
```
kubectl -n argocd get applications
argocd app get hello-world        # if you installed the argocd CLI
```
Force an immediate sync instead of waiting for the poll:
```
argocd app sync hello-world
# or, no CLI:
kubectl -n argocd annotate app hello-world argocd.argoproj.io/refresh=hard --overwrite
```

### Change a platform addon (pihole, cloudflared, traefik, issuers)
Edit under `homelab-infra/cluster/`, commit, push. The `cluster` root app reconciles it.

### Add a brand-new app
1. New repo with a `k8s/` dir (copy hello-world's shape).
2. In `homelab-infra/argocd/apps/`, add `<newapp>.yaml` (copy `hello-world.yaml`, change name +
   repoURL + namespace).
3. Commit + push homelab-infra. The `apps` root app auto-registers it. Nothing else to run.

### Roll back a bad deploy
Because state = git, rollback = git:
```
git revert <bad-commit> && git push          # clean, auditable
```
Or from ArgoCD's history without touching git (temporary):
```
argocd app history hello-world
argocd app rollback hello-world <REVISION>
```
Note: with auto-sync + self-heal on, ArgoCD will re-apply git, so a CLI rollback is only a
stopgap — the durable fix is always a git commit.

### Real image-based apps (see the `webapp` repo for a working example)
The ConfigMap trick is test-only. The real pattern lives in the `webapp` repo:
1. Push a `src/**` change -> GitHub Actions builds and pushes `ghcr.io/<you>/webapp:<sha>`.
2. The same workflow writes that `<sha>` into `k8s/kustomization.yaml` and commits it back.
3. ArgoCD sees the manifest change and rolls out the new image.

CI builds; ArgoCD deploys; the git commit is the only interface between them. Tags are the
immutable git SHA (never `latest`) so ArgoCD always deploys exactly what a commit specifies.
The GHCR package must be public (or add an imagePullSecret). To add a NEW image-based app:
copy `webapp`'s shape, add an `argocd/apps/<app>.yaml`, and add its subdomain to
`terraform/cloudflare/locals.tf` -> `terraform apply`.

### Rotate a secret
Update `secrets/.env` -> re-run the matching `envsubst | kubectl apply`. These two secrets are
the only things applied by hand; everything else flows through git.

### Update the platform itself
- k3s / cert-manager / ArgoCD versions: bump the pins in `ansible/group_vars/all.yml`
  (and the cert_manager_version in the playbook) and re-run `ansible-playbook playbook.yml`.
- App/addon container images: change the tag in the relevant manifest and push.

---

## Handy checks

```
kubectl get pods -A                    # everything Running?
kubectl -n argocd get applications     # all Synced / Healthy?
kubectl -n cloudflared logs deploy/cloudflared   # tunnel connected?
dig NS pkandel.com +short              # Cloudflare authoritative?
vainfo                                 # (on node) Quick Sync H264 profiles present?
```

ArgoCD initial admin password:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## Common failures
- **DNS won't resolve** -> delegation not propagated.
- **Cloudflare 502** -> tunnel up but Traefik not routing: check hello-world pod Running and Ingress host = www.pkandel.com.
- **cloudflared CrashLoop** -> tunnel token secret missing/wrong (step 6).
- **ArgoCD app OutOfSync/Unknown** -> can't read repo: confirm repo public + repoURL correct.
- **Certificate not Ready** -> Cloudflare API token secret not applied (optional step); does not affect the tunnel.
