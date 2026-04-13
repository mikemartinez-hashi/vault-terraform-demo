#!/bin/bash
set -e

# NOTE: Since you provided VAULT_ADDR and VAULT_NAMESPACE, 
# just make sure you have a valid VAULT_TOKEN set in your terminal when running this.

export VAULT_ADDR="https://vault-demo-cluster-public-vault-b71960ee.491753e4.z1.hashicorp.cloud:8200"
export VAULT_NAMESPACE="admin"

echo "Configuring JWT Auth for HCP Terraform..."
# Enable JWT auth globally for the namespace
vault auth enable jwt || echo "JWT auth already enabled"

vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

echo "Creating the access policy for the exact secret paths..."
cat <<EOF > tfc-kv-policy.hcl
path "kv/data/premier_backend_api" {
  capabilities = ["read"]
}
path "kv/data/premier_web_api" {
  capabilities = ["read"]
}
EOF

vault policy write tfc-kv-policy tfc-kv-policy.hcl
rm tfc-kv-policy.hcl

echo "Creating the TFC OIDC role constraint..."
# Note: In a real environment, you would restrict `bound_claims` to your specific org and project
# e.g.: {"sub": "organization:my-org:project:my-project:workspace:*:run_phase:*"}

cat <<EOF > role.json
{
  "role_type": "jwt",
  "bound_audiences": ["vault.workload.identity"],
  "bound_claims_type": "glob",
  "bound_claims": {
    "sub": "organization:*:project:*:workspace:*:run_phase:*"
  },
  "user_claim": "terraform_workspace_id",
  "token_policies": ["tfc-kv-policy"],
  "token_ttl": 900
}
EOF

vault write auth/jwt/role/tfc-kv-demo @role.json
rm role.json

echo "Setup Complete! Vault is now configured natively for HCP Terraform dynamic auth."
