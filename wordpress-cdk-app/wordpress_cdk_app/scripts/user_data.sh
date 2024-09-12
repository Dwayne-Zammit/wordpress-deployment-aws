#!/bin/bash
echo "running userdata script..."
# Update packages
apt-get update -y

# Install Apache, MySQL, PHP and required extensions
apt-get install -y apache2 mysql-server php php-mysql libapache2-mod-php

# Start and enable Apache and MySQL
systemctl start apache2
systemctl enable apache2
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation
mysql_secure_installation <<EOF

y
password
password
y
y
y
y
EOF

# Create WordPress database and user
mysql -u root -ppassword -e "CREATE DATABASE wordpress;"
mysql -u root -ppassword -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'wordpresspassword';"
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost';"
mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

# Download and set up WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Configure WordPress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sed -i "s/username_here/wordpressuser/" /var/www/html/wp-config.php
sed -i "s/password_here/wordpresspassword/" /var/www/html/wp-config.php

# Restart Apache to apply changes
systemctl restart apache2
sudo rm /var/www/html/index.html
