#!/bin/bash

# Function to download a script from GitHub
download_script() {
    local SCRIPT_URL="$1"
    local SCRIPT_NAME="$2"
    curl -s -O "$SCRIPT_URL/$SCRIPT_NAME"
    chmod +x "$SCRIPT_NAME"
}

# Function to prompt user for input
prompt() {
    local PROMPT_MESSAGE="$1"
    local VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    read -p "$PROMPT_MESSAGE [$DEFAULT_VALUE]: " input
    input=${input:-$DEFAULT_VALUE}
    eval "$VAR_NAME='$input'"
}

# GitHub repository URL
REPO_URL="https://raw.githubusercontent.com/SleepyKittenn/Pelican-Installer/master"

# Download the installer scripts
download_script "$REPO_URL" "pelican_panel_installer.sh"
download_script "$REPO_URL" "pelican_wings_installer.sh"

# Prompt user to choose the installer
echo "Choose an option:"
echo "1) Panel Installer"
echo "2) Wings Installer"
read -p "Enter your choice [1-2]: " choice

case $choice in
    1)
        echo "Running Panel Installer..."
        ./pelican_panel_installer.sh
        ;;
    2)
        echo "Running Wings Installer..."
        ./pelican_wings_installer.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac