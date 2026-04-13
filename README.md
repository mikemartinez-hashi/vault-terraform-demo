# Vault + Terraform: Ephemeral Secrets & State Leakage Demo

## Overview

This repository demonstrates a modern integration between **HCP Vault** and **HCP Terraform**, specifically addressing one of the most critical security pain points in Infrastructure as Code: **Secrets Leaking into the Terraform State File**.

# Tree
```bash
vault-tf-demo/
├── files
│   ├── role.json
│   ├── tfc-kv-policy.hcl
│   └── vault_oidc_setup.sh
├── main.tf
├── outputs.tf
├── README.md
├── user_data.sh
└── variables.tf

```

By provisioning an AWS EC2 instance and injecting API keys into the instance's user data, this demo compares two distinct methods of fetching Vault secrets:

1. **Legacy (`data "vault_kv_secret_v2"`)** - Will fetch the `premier_web_api` key and intentionally leak it into the Terraform JSON state file in plain text, demonstrating the standard operational hazard.
2. **Modern (`ephemeral "vault_kv_secret_v2"`)** - Available in Terraform v1.10+, this block fetches the `premier_backend_api` key perfectly memory-scoped. It injects the value securely without ever writing it to the Terraform state file.

## Prerequisites
- HCP Terraform configured mapping to this directory via VCS workflow.
- HCP Vault Cluster with KV engine enabled (Default: `admin/kv`).
- Terraform version `1.10` or higher to support the `ephemeral` block.

## Setup Instructions

### 1. Vault Authentication (Recommended OIDC Method)
To avoid hardcoding tokens, this demo uses OIDC / JWT authentication so HCP Terraform can mathematically prove its identity to HCP Vault. 
Run the bootstrap script locally while authenticated to your Vault cluster:
```bash
./vault_oidc_setup.sh
```

### 2. Configure HCP Terraform Workspace
Add the following Workspace Environment variables to HCP Terraform:
- `TFC_VAULT_PROVIDER_AUTH` = `true` 
- `TFC_VAULT_ADDR` = `https://<YOUR_VAULT_URL>`
- `TFC_VAULT_NAMESPACE` = `admin`
- `TFC_VAULT_RUN_ROLE` = `tfc-kv-demo`

### 3. Deploy
Trigger a standard Terraform run from HCP Terraform. 
- Expand your **State** file in the UI to manually verify `premier_backend_api` does **not** appear anywhere within the JSON.
- Visit the deployed EC2 public IP to observe the rendered HTML output immediately showcasing both secrets injected successfully on boot!
