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

# Install Certbot
sudo apt install -y python3-certbot-apache

# Obtain SSL certificate
sudo certbot certonly --apache -d $DOMAIN -m $EMAIL --agree-tos --non-interactive

# Install Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable sudo sh

# Enable Docker to start on boot
sudo systemctl enable --now docker

# Create necessary directories for Wings
sudo mkdir -p /etc/pelican /var/run/wings

# Download and install Wings
sudo curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ \"$(uname -m)\" == \"x86_64\" ]] && echo \"amd64\" || echo \"arm64\")"
sudo chmod u+x /usr/local/bin/wings

# Output completion message
echo "Wings installation complete. Please visit https://github.com/SleepyKittenn/Pelican-Installer/blob/master/README.md and read the 'AFTER WINGS INSTALLATION' section for further steps."
