#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projet IAC AWS GitHub Actions</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: #f5f5f5;
            color: #333;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        .logo {
            margin-bottom: 2rem;
        }
        .logo img {
            height: 80px;
            width: auto;
        }
        h1 {
            font-size: 2.5rem;
            font-weight: 300;
            letter-spacing: 0.05em;
            margin-bottom: 1rem;
        }
        .subtitle {
            font-size: 1rem;
            font-weight: 400;
            color: #666;
            letter-spacing: 0.1em;
            text-transform: uppercase;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <img src="https://www.heh.be/design/logo_HEH.png" alt="HEH Logo">
        </div>
        <p class="subtitle">Projet IAC AWS GitHub Actions</p>
    </div>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
