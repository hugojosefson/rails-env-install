#!/bin/bash
#Basic apache, passenger and mysql enviroment installation script for Ubuntu
#Developed by Marcelo Murad - email at marcelomurad dot com
#You can redistribute it and/or modify it under either the terms of the GPL (http://www.gnu.org/licenses/gpl-3.0.txt)

if [ "$(whoami)" != "root" ]; then
echo "You need to be root to run this!"
  exit 2
fi

sudo apt-get install -y apache2 mysql-server build-essential gcc apache2-prefork-dev libmysql-ruby libmysqlclient15-dev

sudo gem install mysql --no-rdoc --no-ri

sudo gem install passenger -v2.2.2 --no-rdoc --no-ri

yes '' | passenger-install-apache2-module


echo "LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.2.2/ext/apache2/mod_passenger.so" >> passenger.load
echo "PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.2.2
PassengerRuby /usr/bin/ruby1.8" >> passenger.conf

sudo mv passenger.load /etc/apache2/mods-available/
sudo mv passenger.conf /etc/apache2/mods-available/
sudo a2enmod passenger

echo "NameVirtualHost *
<VirtualHost *>
    ServerName site_name.domain_name.com
    DocumentRoot /directory_path_to_rails_app/public
</VirtualHost>" >> example.local

sudo mv example.local /etc/apache2/sites-available/

sudo /etc/init.d/apache2 reload

echo "############################################################"
echo "A basic example of apache site configuration is available at"
echo "/etc/apache2/sites-available/example.local"
echo "############################################################"

