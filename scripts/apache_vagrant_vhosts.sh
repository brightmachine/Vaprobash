#!/usr/bin/env bash

echo ">>> Installing Config for Apache Server to point to vhosts in /vagrant/vhosts"

# PHP Config for Apache

echo "Include /vagrant/vhosts/*.conf" > /etc/apache2/conf-available/vhosts-vagrant.conf
sudo a2enconf vhosts-vagrant

sudo service apache2 restart