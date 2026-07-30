# ADR 0002 — ArgoCD for GitOps

Context: want the homelab to mirror the work stack (ArgoCD). Decision: ArgoCD, app-of-apps,
apps in separate repos. Consequence: heaviest single component (~0.9GB) on an 8GB box; Flux is
the documented fallback (kustomize manifests unchanged) if the dual-core CPU strains.
