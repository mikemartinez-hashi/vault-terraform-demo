#!/bin/bash
export instance_type="${instance_type}"
export environment="${environment}"
export region="${region}"
export web_api_secret="${web_api_secret}"
export backend_api_secret="${backend_api_secret}"

# Update and install Apache (Ubuntu uses apt + apache2, not yum + httpd)
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl status apache2

sudo cat <<EOF > /var/www/html/index.html
<h1>Hello! This is a sales demo from the SE Team using the tf-demo-hashi repo</h1>
<p>Instance Type: $instance_type</p>
<p>Environment: $environment</p>
<p>Region: $region</p>
<hr>
<h2>Vault Secret Leakage Demo</h2>
<p><strong>Legacy Fetch (Leaked to State File):</strong> $web_api_secret</p>
EOF
