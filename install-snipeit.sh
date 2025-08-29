# 1. Download & Install VirtualBox and Ubuntu Server

# 2. Install LAMP (Apache, MySQL, PHP)
sudo apt update && sudo apt -y upgrade
sudo apt install -y apache2
sudo apt install -y mariadb-server mariadb-client
sudo apt install -y php
sudo apt install -y php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}

# 3. Install Snipe-IT on Ubuntu

# 3.1 Install Dependencies
sudo a2enmod rewrite
sudo apt install -y php-{opcache,pdo,bcmath,bz2,calendar,ctype,exif,ffi,fileinfo,ftp,gd,iconv,intl,json,mbstring,mysqli,phar,posix,readline,shmop,sockets,sysvmsg,sysvsem,sysvshm,tokenizer,zip,curl,ldap}
sudo systemctl restart apache2

# 3.2 Install PHP Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# 3.3 Create a Database
CREATE DATABASE snipeit;
CREATE USER 'snipeuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON snipeit.* TO 'snipeuser'@'localhost';
FLUSH PRIVILEGES;

# 3.4 Install Snipe-IT
cd /var/www/
sudo git clone https://github.com/snipe/snipe-it snipe-it
cd /var/www/snipe-it
sudo cp /var/www/snipe-it/.env.example /var/www/snipe-it/.env
sudo nano /var/www/snipe-it/.env
sudo chown -R www-data:www-data  /var/www/snipe-it
sudo chmod -R 755 /var/www/snipe-it
sudo apt-get install -y unzip
sudo composer update --no-plugins --no-scripts
sudo composer install --no-dev --prefer-source --no-plugins --no-scripts
sudo php artisan key:generate

# 3.5 Create a Virtual Host File
sudo a2dissite 000-default.conf
sudo nano /etc/apache2/sites-available/snipeit.conf
<VirtualHost *:80>
    ServerName 51.250.9.205
    DocumentRoot /var/www/snipe-it/public
    <Directory /var/www/snipe-it/public>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
sudo a2ensite snipeit.conf
sudo systemctl restart apache2
