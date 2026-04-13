terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "vault" {
  # OIDC Authentication and Vault Namespace are handled dynamically via TFC Workspace variables 
  # (TFC_VAULT_PROVIDER_AUTH, TFC_VAULT_NAMESPACE)
}

# LEAKY SECRET: Fetched conventionally. Will be stored in plain text inside the Terraform state file.
data "vault_kv_secret_v2" "web_api" {
  mount = "kv"
  name  = "premier_web_api"
}

# SECURE SECRET: Fetched ephemerally. Does NOT get recorded into the state file (TF 1.10+ required)
ephemeral "vault_kv_secret_v2" "backend_api" {
  mount = "kv"
  name  = "premier_backend_api"
}

# resource "terraform_data" "secret_consumed" {
#   # write_only accepts ephemeral values — never persisted to state
#   input = ephemeral.vault_kv_secret_v2.backend_api.data["backend_api_key"]
# }

# Create an EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.hc-base-ubuntu-2404["amd64"].id
  instance_type = var.instance_type

  key_name = var.key_name
  security_groups = [
    aws_security_group.allow_ssh_and_http.name
  ]

  # iam_instance_profile = aws_iam_instance_profile.web_profile.name

  tags = {
    Name        = "${var.server}-${var.environment}"
    Type        = var.demo
    Environment = var.environment
    Owner       = var.owner
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    environment        = var.environment
    region             = var.region
    instance_type      = var.instance_type
    web_api_secret     = data.vault_kv_secret_v2.web_api.data["web_api_key"]
    # backend_secret_id  = aws_secretsmanager_secret.demo.id
  })
}

# # --- EPHEMERAL SECRETS MANAGER INCORPORATION --- #
# resource "aws_secretsmanager_secret" "demo" {
#   name                    = "vault_backend_api_key_${var.environment}_${var.demo}"
#   recovery_window_in_days = 0 # Force deletion immediately for demo purposes
# }

# resource "aws_secretsmanager_secret_version" "demo" {
#   secret_id     = aws_secretsmanager_secret.demo.id
# }

# # IAM Role mapping so the EC2 Instance can fetch the secret natively at boot
# resource "aws_iam_role" "web_role" {
#   name = "web_role_ephemeral_${var.environment}"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "secrets_policy" {
#   name        = "secrets_policy_ephemeral_${var.environment}"
#   description = "Allows reading the demo ephemeral secret"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "secretsmanager:GetSecretValue"
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.demo.arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_secrets" {
#   role       = aws_iam_role.web_role.name
#   policy_arn = aws_iam_policy.secrets_policy.arn
# }

# resource "aws_iam_instance_profile" "web_profile" {
#   name = "web_profile_ephemeral_${var.environment}"
#   role = aws_iam_role.web_role.name
# }


# Get AMI ID
data "aws_ami" "hc-base-ubuntu-2404" {
  for_each = toset(["amd64", "arm64"])
  filter {
    name   = "name"
    values = [format("hc-base-ubuntu-2404-%s-*", each.value)]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  most_recent = true
  owners      = ["888995627335"] # ami-prod account
}

# Create a Security Group to allow SSH and HTTP traffic
resource "aws_security_group" "allow_ssh_and_http" {
  name = "allow_ssh_and_http-${var.environment}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere (for demonstration purposes, restrict this in production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere (for demonstration purposes, restrict this in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

}
