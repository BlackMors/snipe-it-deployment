#!/bin/bash

# System Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install LAMP Stack and Required PHP Extensions
sudo apt install -y apache2 mariadb-server php php-curl php-mbstring php-xml php-zip php-ldap php-bcmath php-gd php-dom php-fileinfo php-opcache php-tokenizer php-simplexml

# Secure MariaDB Installation
sudo mysql_secure_installation

# Create Database and User
read -s -p "Enter password for snipeuser: " snipepass
echo
sudo mysql -e "CREATE DATABASE snipeit;"
sudo mysql -e "CREATE USER 'snipeuser'@'localhost' IDENTIFIED BY '$snipepass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Clone Snipe-IT Repository
cd /var/www/html
sudo git clone https://github.com/snipe/snipe-it
cd snipe-it

# Install PHP Dependencies
sudo composer install --no-dev --prefer-source

# Configure Environment
sudo cp .env.example .env
sudo php artisan key:generate

# Set Permissions
sudo chown -R www-data:www-data /var/www/html/snipe-it
sudo chmod -R 755 /var/www/html/snipe-it/storage

# Configure Apache Virtual Host
sudo tee /etc/apache2/sites-available/snipeit.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName your_server_ip_or_domain
    DocumentRoot /var/www/html/snipe-it/public

    <Directory /var/www/html/snipe-it/public>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/snipeit_error.log
    CustomLog \${APACHE_LOG_DIR}/snipeit_access.log combined
</VirtualHost>
EOF

# Enable Site and Modules
sudo a2ensite snipeit.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Schedule Cron Job
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/snipe-it/artisan schedule:run >> /dev/null 2>&1") | crontab -

echo "Installation complete! Open http://your_server_ip_or_domain in your browser."