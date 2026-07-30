# Variables to fill in

| Variable | Where | Notes |
|---|---|---|
| github_user | group_vars/all.yml, argocd/*.yaml | your GitHub username/org |
| letsencrypt_email | group_vars/all.yml, cert-manager/clusterissuer.yaml | real email |
| domain | group_vars/all.yml | pkandel.com |
| timezone | group_vars/all.yml, pihole/deployment.yaml | e.g. Australia/Melbourne |
| node_ip / node_gateway / node_interface | group_vars/all.yml, inventory.ini | static LAN IP, gateway, NIC (`ip -br link`) |
| hello-world hostname | hello-world repo k8s/ingress.yaml | e.g. hello.pkandel.com |
| cloudflare_account_id | terraform/.../terraform.tfvars | Cloudflare dashboard sidebar |
| cloudflare_zone_id | terraform/.../terraform.tfvars | domain Overview page |
| Cloudflare API token | secrets/cloudflare-api-token.enc.yaml | scoped DNS-edit token; SOPS-encrypt |
| Tunnel token | secrets/tunnel-token.enc.yaml | `terraform output`; SOPS-encrypt |
| age public key | .sops.yaml | `age-keygen` output |
