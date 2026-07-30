# ADR 0004 — Split infra and apps into separate repos

Context: platform changes slowly; apps churn fast. Decision: homelab-infra owns the platform +
the ArgoCD Application manifests that point at app repos; each app is its own repo with its own
k8s/ manifests. Consequence: clean blast radius, independent app lifecycles, infra stays stable.
