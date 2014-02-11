#!/usr/bin/env bash

echo ">>> Installing Mailcatcher"

#dependency
sudo apt-get install -y libsqlite3-dev


if $(which rvm) -v > /dev/null 2>&1; then
	echo ">>>>Installing with RVM"
	$(which rvm) default@mailcatcher --create do gem install --no-rdoc --no-ri mailcatcher
	$(which rvm) wrapper default@mailcatcher --no-prefix mailcatcher catchmail
else
	#gem check
	if ! gem -v > /dev/null 2>&1; then sudo aptitude install -y libgemplugin-ruby; fi

	#install
	gem install --no-rdoc --no-ri mailcatcher
fi


#make it start on boot

#first, strip old entry
sudo sed -i "s/^@reboot.*mailcatcher.*$//" /etc/crontab

sudo echo "@reboot $(which mailcatcher) --ip=0.0.0.0" >> /etc/crontab
sudo update-rc.d cron defaults

#make php use it to send mail
sudo echo "sendmail_path = /usr/bin/env $(which catchmail)" > /etc/php5/mods-available/mailcatcher.ini
sudo php5enmod mailcatcher
sudo service php5-fpm restart
sudo service apache2 restart

#start it now
/usr/bin/env $(which mailcatcher) --ip=0.0.0.0

#add aliases
if [[ -f "/home/vagrant/.bash_profile" ]]; then
    sudo sed -i "s/^alias mailcatcher.*$//" /home/vagrant/.bash_profile
	sudo echo "alias mailcatcher=\"mailcatcher --ip=0.0.0.0\"" >> /home/vagrant/.bash_profile
	. /home/vagrant/.bash_profile
fi

if [[ -f "/home/vagrant/.zshrc" ]]; then
    sudo sed -i "s/^alias mailcatcher.*$//" /home/vagrant/.zshrc
	sudo echo "alias mailcatcher=\"mailcatcher --ip=0.0.0.0\"" >> /home/vagrant/.zshrc
	. /home/vagrant/.zshrc
fi

if [[ -f "/home/vagrant/.bashrc" ]]; then
    sudo sed -i "s/^alias mailcatcher.*$//" /home/vagrant/.bashrc
	sudo echo "alias mailcatcher=\"mailcatcher --ip=0.0.0.0\"" >> /home/vagrant/.bashrc
	. /home/vagrant/.bashrc
fi

MAILCATCHER=$(which mailcatcher)

# start mailcatcher on boot
cat > /etc/init/mailcatcher.conf << EOF
# restart apache after vagrant mounted
description "start mailcatcher after vagrant mounted"
author "Kelvin Jones"

# Listen and start after the vagrant-mounted event
start on vagrant-mounted

exec $MAILCATCHER --ip=0.0.0.0

EOF