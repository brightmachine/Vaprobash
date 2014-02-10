#!/usr/bin/env bash

echo ">>> Installing Config for Apache Server to point to vhosts in /vagrant/vhosts"

# PHP Config for Apache

echo "Include /vagrant/server/vhosts/*.conf" > /etc/apache2/conf-available/vhosts-vagrant.conf
sudo a2enconf vhosts-vagrant
sudo a2enmod vhost_alias

sudo service apache2 restart

# On boot apache is started before /vagrant is mounted, therefore after vagrant is mounted we should
# restart apache again. This upstart script does just that.
cat > /etc/init/apache-vagrant-vhosts.conf << EOF
# restart apache after vagrant mounted
description "restart apache after vagrant mounted"
author "Kelvin Jones"

# Listen and start after the vagrant-mounted event
start on vagrant-mounted

exec /etc/init.d/apache2 restart

EOF