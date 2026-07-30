# Recovery (disk died)

1. Reinstall Ubuntu (docs/os-install.md).
2. Restore the age key to ~/.config/sops/age/keys.txt.
3. `cd ansible && ansible-playbook playbook.yml`.
4. Re-apply the two bootstrap secrets (secrets/README.md).
5. `git push` (or it's already pushed) → ArgoCD rebuilds cluster/ and apps/.
6. Restore PVC data (Pi-hole config) from backup.
