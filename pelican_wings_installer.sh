#!/bin/bash

# Function to prompt user for input
prompt() {
    local PROMPT_MESSAGE="$1"
    local VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    read -p "$PROMPT_MESSAGE [$DEFAULT_VALUE]: " input
    input=${input:-$DEFAULT_VALUE}
    eval "$VAR_NAME='$input'"
}

# Prompt for user input
prompt "Enter your domain" DOMAIN "your-domain.com"
prompt "Enter your email for Let's Encrypt" EMAIL "admin@$DOMAIN"
prompt "Enter the auto deploy command (Standalone)" AUTO_DEPLOY "your-auto-deploy-command"

# Install Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable sudo sh

# Enable Docker to start on boot
sudo systemctl enable --now docker

# Create necessary directories
sudo mkdir -p /etc/pelican /var/run/wings

# Download and install Wings
sudo curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ \"$(uname -m)\" == \"x86_64\" ]] && echo \"amd64\" || echo \"arm64\")"
sudo chmod u+x /usr/local/bin/wings

# Install Certbot
sudo apt install -y python3-certbot-apache

# Obtain SSL certificate
sudo certbot certonly --apache -d $DOMAIN -m $EMAIL --agree-tos --non-interactive

# Run the auto deploy command
$AUTO_DEPLOY

# Create systemd service file for Wings
sudo bash -c "cat <<EOL > /etc/systemd/system/wings.service
[Unit]
Description=Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pelican
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL"

# Enable and start the Wings service
sudo systemctl enable --now wings
sudo systemctl restart wings

# Output completion message
echo "Wings installation complete."
