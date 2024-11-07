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

# Determine the architecture
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi

# Construct the download URL
WINGS_URL="https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$ARCH"

# Print the URL to verify
echo "Downloading Wings from: $WINGS_URL"

# Download and install Wings using wget with a progress bar
sudo wget --progress=dot:giga -O /usr/local/bin/wings "$WINGS_URL"
sudo chmod u+x /usr/local/bin/wings

# Verify the downloaded Wings binary
if file /usr/local/bin/wings | grep -q 'ELF'; then
    echo "Wings binary downloaded successfully."
else
    echo "Wings binary download failed, please check the URL or network connection."
    exit 1
fi

# Output completion message
echo "Wings installation complete. Please visit https://github.com/SleepyKittenn/Pelican-Installer/blob/master/README.md and read the 'AFTER WINGS INSTALLATION' section for further steps."
