# ArgoCD wiring

Two app-of-apps roots, applied once by the Ansible bootstrap (after ArgoCD is installed):

- `root-cluster.yaml` → watches this repo's `cluster/` (platform addons).
- `root-apps.yaml`    → watches this repo's `argocd/apps/` (each file registers one app).

Apps live in **their own repos**. To add an app: drop an `Application` manifest in `apps/`
pointing at that repo, commit, push. ArgoCD picks it up automatically.

## First-time apply (run from your Mac with KUBECONFIG set)
```
kubectl apply -f argocd/projects.yaml
kubectl apply -f argocd/root-cluster.yaml
kubectl apply -f argocd/root-apps.yaml
```

## Note on secrets
The two bootstrap secrets (Cloudflare API token, tunnel token) are applied out-of-band by the
Ansible bootstrap from SOPS-decrypted files — ArgoCD does not manage them (keeps setup simple
by avoiding the ksops/avp plugin). Everything else is pure GitOps.
