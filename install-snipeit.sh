#!/bin/bash 

# Installing Snipe-IT on Ubuntu Server

#System Update
sudo apt update && sudo apt upgrade -y

#Installing the LAMP-stack
sudo apt install -y apache2 mariadb-server php php-curl php-mbstring php-xml php-zip

#Configure DB
sudo mysql_secure_installation
sudo mysql -e "CREATE DATABASE snipeit;"
sudo mysql -e "CREATE USER 'snipeuser'@'localhost' IDENTIFIED BY 'ваш_пароль';"
sudo mysql -e "GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

#Snipe-IT Installation
cd /var/www/html
sudo git clone https://github.com/snipe/snipe-it
cd snipe-it
sudo cp .env.example .env
sudo chown -R www-data:www-data /var/www/html/snipe-it
sudo chmod -R 755 /var/www/html/snipe-it

echo "Installation is done! Open http://your-ip/snipe-it in browser."