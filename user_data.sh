#!/bin/bash
export instance_type="${instance_type}"
export environment="${environment}"
export region="${region}"
export web_api_secret="${web_api_secret}"


# Update and install Apache + utilities
sudo apt-get update -y
sudo apt-get install -y apache2 awscli jq curl
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2

sudo cat <<EOF > /var/www/html/index.html
<h1>Hello! This is a sales demo from the SE Team using the tf-demo-hashi repo</h1>
<p>Instance Type: $instance_type</p>
<p>Environment: $environment</p>
<p>Region: $region</p>
<hr>
<h2>Vault Secret Leakage Pattern Demo</h2>
<p><strong>Web API Secret (Leaked to State File):</strong> $web_api_secret</p>
EOF
