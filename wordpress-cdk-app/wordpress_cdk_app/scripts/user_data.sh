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
wordpress_username={{WORDPRESSUSERNAME}}
wordpress_password={{WORDPRESSPASSWORD}}
echo "username for wordpress user is: $wordpress_username"
echo "username for wordpress user is: $wordpress_password"
# Create WordPress database and user
mysql -u root -ppassword -e "CREATE DATABASE wordpress;"
mysql -u root -ppassword -e "CREATE USER $wordpress_username@'%' IDENTIFIED BY $wordpress_password;"
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON wordpress.* TO $wordpress_username@'%';"
mysql -u root -ppassword -e "GRANT PROCESS ON *.* TO $wordpress_username@'%';"
mysql -u root -ppassword -e "FLUSH PRIVILEGES;"

# allow all hosts to connect to db.
CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' $CONFIG_FILE
echo "MySQL bind-address updated to 0.0.0.0"
sudo systemctl restart mysql

echo "MySQL service restarted"
# Download and set up WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Configure WordPress
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sed -i "s/username_here/$wordpress_username/" /var/www/html/wp-config.php
sed -i "s/password_here/$wordpress_password/" /var/www/html/wp-config.php

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Configure WordPress and complete installation
sudo -u $wordpress_username wp core config --path=/var/www/html/ --dbname=wordpress --dbuser=$wordpress_username --dbpass=$wordpress_password --dbhost=localhost --dbprefix=wp_

# Install WordPress with WP-CLI
sudo -u $wordpress_username wp core install --path=/var/www/html/ --url="http://localhost" --title="WIS Site" --admin_user="admin" --admin_password="adminpassword" --admin_email="admin@example.com"

# create an additional user
sudo -u $wordpress_username wp user create user user@example.com --user_pass=userpassword --role=author --path=/var/www/html/

# Restart Apache to apply changes
systemctl restart apache2
sudo rm /var/www/html/index.html

# Set proper permissions
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;

echo "WordPress installation completed. Visit your site to complete the setup."

# install aws cli
# Define the URL for the AWS CLI installation package
CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
ZIP_FILE="awscliv2.zip"
INSTALL_DIR="./aws"

# Function to install AWS CLI
install_aws_cli() {
    echo "Installing AWS CLI..."
    curl "$CLI_URL" -o "$ZIP_FILE"
    unzip -o "$ZIP_FILE"
    sudo ./aws/install
    rm -rf "$ZIP_FILE" "$INSTALL_DIR"
}

# Check if AWS CLI is installed
if command -v aws &> /dev/null; then
    echo "AWS CLI is already installed. Updating..."
    # Check if there's an update available
    aws --version
    echo "Updating AWS CLI..."
    install_aws_cli
else
    echo "AWS CLI is not installed."
    install_aws_cli
fi

# Verify the installation
echo "AWS CLI version:"
aws --version
