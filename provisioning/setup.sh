#! /usr/bin/env bash

echo -e "\n--- Removing no tty annoyance ---\n"
sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile

for vagrant_arg in "${BASH_ARGV[@]}"
do
    export $vagrant_arg
done

if [[ -z ${DBPASSWD+x} || -z ${DBNAME+x} || -z ${DBUSER+x} || -z ${DBHOST+x} || -z ${APP_ENV+x} ]]; then
  echo -e "\n--- Not all required variables set or available ---\n"
  echo -e "\nExiting..\n"
  exit 1
fi

echo -e "\n--- Updating the Ubuntu packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages ---\n"
apt-get -y install vim curl build-essential python-software-properties git

echo -e "\n--- Add some repos to update our distro ---\n"
add-apt-repository ppa:ondrej/php5-5.6

echo -e "\n--- Re-Updating the Ubuntu packages list ---\n"
apt-get -qq update

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
apt-get -y install mysql-server-5.5

echo -e "\n--- Setting up MySQL ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-json php5-mysql php-apc

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite

echo -e "\n--- Copying Apache configuration ---\n"
sudo cp /vagrant/templates/apache2.conf /etc/apache2/apache2.conf

echo -e "\n--- Setting document root to public directory ---\n"
rm -rf /var/www
ln -fs /vagrant/development-stage /var/www

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

echo -e "\n--- Copying VirtualHost configuration  ---\n"
sudo cp /vagrant/templates/000-default.conf /etc/apache2/sites-available/000-default.conf
sudo sed -i "s/\$APPENV/$APP_ENV/" /etc/apache2/sites-enabled/000-default.conf

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

BOLT_CMS_DIRECTORY=/var/www/boltcms

cd /var/www

[ -d "$BOLT_CMS_DIRECTORY" ] || composer create-project bolt/composer-install boltcms --prefer-dist

echo -e "\n--- Copying Bolt.cm MySQL based configuration ---\n"
sudo cp /vagrant/templates/bolt-config.yml /var/www/boltcms/app/config/config.yml

echo -e "\n--- Modifying Bolt.cm MySQL database configuration ---\n"
sudo sed -i "s/database-username/$DBUSER/" /var/www/boltcms/app/config/config.yml
sudo sed -i "s/database-password/$DBPASSWD/" /var/www/boltcms/app/config/config.yml
sudo sed -i "s/database-name/$DBNAME/" /var/www/boltcms/app/config/config.yml
sudo sed -i "s/database-host/$DBHOST/" /var/www/boltcms/app/config/config.yml

echo -e "\n--- Generating de_DE locale ---\n"
sudo locale-gen de_DE && sudo locale-gen de_DE.UTF-8