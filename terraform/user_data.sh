#!/bin/bash
set -euxo pipefail

# Update package list
apt-get update -y

# Install nginx
apt-get install -y nginx

# Create index.html with deployment message
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Deployed by Terraform + GitHub Actions</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>OK - deployed by Terraform + GitHub Actions</h1>
    <p>Instance deployed successfully!</p>
</body>
</html>
EOF

# Enable and start nginx
systemctl enable nginx
systemctl restart nginx

