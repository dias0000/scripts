#!/bin/bash

# update apt repositories
sudo apt-get update

apt-get install unzip
apt-get install make
apt-get install git
apt-get install python-pip
apt-get install python-netaddr
apt-get install aptitude
apt-get install g++
apt-get install npm

#user iface choice
sudo apt-get -y install python-pip gcc python-dev
sudo pip install netifaces
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/scripts/iface-choice.py -O /tmp/iface-choice.py
python /tmp/iface-choice.py
iface=$(<~/.honey_iface)



## install p0f ##
sudo apt-get install -y p0f
sudo mkdir /var/p0f/


# dependency for add-apt-repository
sudo apt-get install -y python-software-properties


## install dionaea ##
#add dionaea repo
sudo add-apt-repository -y ppa:honeynet/nightly
sudo apt-get update
sudo apt-get install -y dionaea


#make directories
sudo mkdir -p /var/dionaea/wwwroot
sudo mkdir -p /var/dionaea/binaries
sudo mkdir -p /var/dionaea/log
sudo mkdir -p /var/dionaea/bistreams
sudo chown -R nobody:nogroup /var/dionaea/


#edit config
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/templates/dionaea.conf.tmpl -O /etc/dionaea/dionaea.conf
#note that we try and strip :0 and the like from interface here
sudo sed -i "s|%%IFACE%%|${iface%:*}|g" /etc/dionaea/dionaea.conf


#persist iptables config
sudo iptables-save > /etc/iptables.rules


#setup iptables restore script
sudo echo '#!/bin/sh' >> /etc/network/if-up.d/iptablesload
sudo echo 'iptables-restore < /etc/iptables.rules' >> /etc/network/if-up.d/iptablesload
sudo echo 'exit 0' >> /etc/network/if-up.d/iptablesload


#enable restore script
sudo chmod +x /etc/network/if-up.d/iptablesload


#download init files and install them
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/templates/p0f.init.tmpl -O /etc/init.d/p0f
sudo sed -i "s|%%IFACE%%|$iface|g" /etc/init.d/p0f
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/init/dionaea -O /etc/init.d/dionaea


#install system services
sudo chmod +x /etc/init.d/p0f
sudo chmod +x /etc/init.d/dionaea
sudo update-rc.d p0f defaults
sudo update-rc.d dionaea defaults


#start the honeypot software
sudo /etc/init.d/p0f start
sudo /etc/init.d/dionaea start
