#!/bin/bash
export instance_type="${instance_type}"
export environment="${environment}"
export region="${region}"
export web_api_secret="${web_api_secret}"
export backend_secret_id="${backend_secret_id}"

# Update and install Apache + utilities
sudo apt-get update -y
sudo apt-get install -y apache2 awscli jq curl
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2

# Using the EC2 IAM Profile, fetch the ephemeral secret securely without ever touching the state file
SECRET_PAYLOAD=$(aws secretsmanager get-secret-value --region ${region} --secret-id "${backend_secret_id}" --query SecretString --output text)

sudo cat <<EOF > /var/www/html/index.html
<h1>Hello! This is a sales demo from the SE Team using the tf-demo-hashi repo</h1>
<p>Instance Type: $instance_type</p>
<p>Environment: $environment</p>
<p>Region: $region</p>
<hr>
<h2>Vault Secret Leakage Pattern Demo</h2>
<p><strong>Legacy Fetch (Leaked to State File):</strong> $web_api_secret</p>
<p><strong>Ephemeral Integration (Clean State):</strong> $SECRET_PAYLOAD</p>
EOF
