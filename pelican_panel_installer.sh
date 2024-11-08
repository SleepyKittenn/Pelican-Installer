#!/bin/bash

prompt() {
    local PROMPT_MESSAGE="$1"
    local VAR_NAME="$2"
    local DEFAULT_VALUE="$3"
    read -p "$PROMPT_MESSAGE [$DEFAULT_VALUE]: " input
    input=${input:-$DEFAULT_VALUE}
    eval "$VAR_NAME='$input'"
}

prompt "Enter your panel domain" DOMAIN "your-domain.com"
prompt "Enter your email for Let's Encrypt" ADMIN_EMAIL "admin@$DOMAIN"

sudo apt update
sudo apt upgrade -y
sudo apt install -y apache2 mariadb-server php libapache2-mod-php mariadb-client php-gd php-mysql php-mbstring php-bcmath php-xml php-curl php-zip php-intl php-sqlite3 php-fpm

sudo mkdir -p /var/www/pelican
cd /var/www/pelican

curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz | sudo tar -xzv

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

sudo COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

sudo apt install -y python3-certbot-apache

sudo certbot certonly --apache -d $DOMAIN -m $ADMIN_EMAIL --agree-tos --non-interactive

sudo a2dissite 000-default.conf

sudo bash -c "cat <<EOL > /etc/apache2/sites-available/pelican.conf
<VirtualHost *:80>
    ServerName $DOMAIN

    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot \"/var/www/pelican/public\"

    AllowEncodedSlashes On

    php_value upload_max_filesize 100M
    php_value post_max_size 100M

    <Directory \"/var/www/pelican/public\">
        Require all granted
        AllowOverride all
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN/privkey.pem
</VirtualHost>
EOL"

sudo ln -s /etc/apache2/sites-available/pelican.conf /etc/apache2/sites-enabled/pelican.conf
sudo a2enmod ssl
sudo a2enmod rewrite

sudo systemctl restart apache2

cd /var/www/pelican
sudo php artisan p:environment:setup

sudo chmod -R 755 storage/* bootstrap/cache/
sudo chown -R www-data:www-data /var/www/pelican

echo "Pelican Panel installation complete. Please visit http://$DOMAIN/installer to finish the setup."