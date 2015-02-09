#!/bin/bash

if [ "`whoami`" != "root" ]; then
	echo "Retry, with root privileges"
	exit 1
fi

LSB=`lsb_release -c | awk '{print $2}'`
if [ "$LSB" != "precise" -a "$LSB" != "raring" ]; then
	echo "Sorry, Your Ubuntu is not 'precise (or raring)!!"
	exit 1
fi
SRC_DIR=`pwd`
HTML_DIR="/var/www/html"
SSH_KEY_DIR="/var/www/.ssh"
#LOCAL_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

RESET="\033[0m"

GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m" 
YELLOW="\033[1;33m" 
CYAN="\033[1;36m"

reset_color() {
	echo -e "$RESET"
}

msg() {
	msg=$1
	echo
	echo
	echo -e "$CYAN =============================================="
	echo -e "$CYAN      $msg"
	echo -e "$CYAN =============================================="
	reset_color
	sleep 2
}

sub_msg() {
	msg=$1
	echo -e "$GREEN      $msg"
	reset_color
}

alert_msg() {
	msg=$1
	echo
	echo
	echo -e "$RED [Alert]: $msg"
	echo -e "$RED [Alert]: $msg"
	echo -e "$RED [Alert]: $msg"
	echo
	reset_color
}

msg "Input Local IP-Address"
echo -n -e "$YELLOW Input Local IP-Address: "
read -s LOCAL_IP
echo
echo -n -e "$YELLOW Input Local IP-Address (again): "
read -s LOCAL_IP
echo
reset_color

msg "Input MySQL root password"
echo -n -e "$YELLOW Input MySQL root's password: "
read -s mysql_pw_1
echo
echo -n -e "$YELLOW Input MySQL root's password (again): "
read -s mysql_pw_2
echo
reset_color

msg "Set Dynamic DNS"
echo -n -e "$YELLOW Input your domain-name (default: 'test.org'): "
read DOMAIN_NAME
reset_color

if [ $mysql_pw_1 != $mysql_pw_2 ]; then
	alert_msg "the input value is not matched !!!"
	exit 2
fi

msg "Set Default-Gateway Info"
echo -e "$YELLOW (Notice) Last value must be \"1\" (e.g: 172.21.3.1)"
echo -n -e "$YELLOW Input default gateway ip address: "
read GATEWAY
reset_color

msg "Set Netmask Info"
echo -n -e "$YELLOW Input Netmask (e.g: 255.255.255.0): "
read NETMASK
reset_color

if [ $mysql_pw_1 != $mysql_pw_2 ]; then
	alert_msg "the input value is not matched !!!"
	exit 2
fi

cd $SRC_DIR
msg "Updata Source List"
apt-get update

export DEBIAN_FRONTEND=noninteractive

#echo "mysql-server mysql-server/root_password password $mysql_pw_1" | debconf-set-selections
#echo "mysql-server mysql-server/root_password_again password $mysql_pw_1" | debconf-set-selections

cd $SRC_DIR
msg "Install Packages for Whitehole"
if [ "$LSB" == "precise" ]; then
#apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install make apache2 libapache2-mod-php5 libssh2-php libssh2-1 libssh2-1-dbg libssh2-1-dev php5 php5-dev php5-cli php5-common php5-curl php5-gd php5-imagick php5-mysql php5-snmp php5-xmlrpc mysql-server mysql-client bind9 snmp smistrip snmpd mrtg nfs-common libvirt-dev libxml2 libxml2-dev libxml2-utils xsltproc bind9 bind9utils virt-manager qemu-utils kpartx libguestfs-tools parted sysstat uuid
apt-get -y install make apache2 libapache2-mod-php5 libssh2-php libssh2-1 libssh2-1-dbg libssh2-1-dev php5 php5-dev php5-cli php5-common php5-curl php5-gd php5-imagick php5-mysql php5-snmp php5-xmlrpc mysql-server mysql-client bind9 snmp smistrip snmpd mrtg nfs-common libvirt-dev libxml2 libxml2-dev libxml2-utils xsltproc bind9 bind9utils virt-manager qemu-utils kpartx libguestfs-tools parted sysstat uuid
ln -s /usr/bin/uuid /usr/bin/uuidgen
else
#apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install make apache2 libapache2-mod-php5 libssh2-php libssh2-1 libssh2-1-dbg libssh2-1-dev php5 php5-dev php5-cli php5-common php5-curl php5-gd php5-imagick php5-mysql php5-snmp php5-xmlrpc mysql-server mysql-client bind9 snmp snmp-mibs-downloader snmpd mrtg nfs-common libvirt-dev libxml2 libxml2-dev libxml2-utils xsltproc bind9 bind9utils virt-manager qemu-utils kpartx libguestfs-tools parted sysstat uuid
apt-get -y install make apache2 libapache2-mod-php5 libssh2-php libssh2-1 libssh2-1-dbg libssh2-1-dev php5 php5-dev php5-cli php5-common php5-curl php5-gd php5-imagick php5-mysql php5-snmp php5-xmlrpc mysql-server mysql-client bind9 snmp snmp-mibs-downloader snmpd mrtg nfs-common libvirt-dev libxml2 libxml2-dev libxml2-utils xsltproc bind9 bind9utils virt-manager qemu-utils kpartx libguestfs-tools parted sysstat uuid
fi

mysqladmin -u root password $mysql_pw_1

cd $SRC_DIR
msg "Install libvirt-php"
tar zxvf libvirt-php-0.4.8.tar.gz
cd libvirt-php-0.4.8/
./configure && make && make install

#cd $SRC_DIR
#msg "Install ssh2"
#tar zxvf ssh2-0.12.tgz
#cd ssh2-0.12/
#phpize
#./configure --with-ssh2 && make && make install

cd $SRC_DIR
msg "Install HTML source"
cp -av whitehole-html $HTML_DIR
cd $HTML_DIR
chmod 755 ./perms.sh
./perms.sh
sed -i "s/mysql_root_pw/$mysql_pw_1/g" $HTML_DIR/db_conn.php $HTML_DIR/dbconfig.php
sed -i "s/@_LOCAL_IP_@/$LOCAL_IP/g" $HTML_DIR/functions.php $HTML_DIR/bbs/view_vm.php
sed -i "s/@_GATEWAY_@/$GATEWAY/g" $HTML_DIR/bbs/view_vm.php 
sed -i "s/@_NETMASK_@/$NETMASK/g" $HTML_DIR/bbs/view_vm.php

cd $SRC_DIR
msg "Configure MySQL Database"
mysql -uroot -p${mysql_pw_1} -h localhost -e "create database board"
mysql -uroot -p${mysql_pw_1} -h localhost board < board.sql
mysql -uroot -p${mysql_pw_1} -h localhost -e "create database whitehole"
mysql -uroot -p${mysql_pw_1} -h localhost whitehole < whitehole.schema.sql

cd $SRC_DIR
msg "Configure Apahce2 VHOST"
cp -av 000-whitehole /etc/apache2/sites-available/whitehole
a2dissite 000-default
a2ensite whitehole

cd $SRC_DIR
msg "Configure SSH Env."
echo "UserKnownHostsFile /dev/null
StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "useDNS no" >> /etc/ssh/sshd_config
mkdir $SSH_KEY_DIR
ssh-keygen -t rsa -P '' -f $SSH_KEY_DIR/id_rsa
chown -R www-data:www-data $SSH_KEY_DIR
mkdir /root/.ssh
chmod 700 /root/.ssh
cp $SSH_KEY_DIR/id_rsa /root/.ssh/
cat $SSH_KEY_DIR/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 700 $SSH_KEY_DIR /root/.ssh
chown root:root /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

cd $SRC_DIR
msg "install Script/Cron Env."
cp -av whitehole-home /home/whitehole
ln -s /home/whitehole/cron.d/whitehole /etc/cron.d/whitehole

cd $SRC_DIR
msg "install DNS/Bind9 Env."
echo "
zone \"$DOMAIN_NAME\" IN {
        type master;
        file \"/var/lib/bind/$DOMAIN_NAME.zone\";
        allow-update { ${LOCAL_IP}; 127.0.0.1; };
};" >> /etc/bind/named.conf.local
cp -av dns.zone /var/lib/bind/$DOMAIN_NAME.zone
sed -i "s/@_LOCAL_IP_@/$LOCAL_IP/g" /var/lib/bind/$DOMAIN_NAME.zone
sed -i "s/@_DOMAIN_@/$DOMAIN_NAME/g" /var/lib/bind/$DOMAIN_NAME.zone $HTML_DIR/bbs/proc-add_vm.php $HTML_DIR/bbs/proc-remove_vm.php
sed -i "s/@_DNS_@/$LOCAL_IP/g" setup-node.sh
chown bind:bind /var/lib/bind/$DOMAIN_NAME.zone
chmod 644 /var/lib/bind/$DOMAIN_NAME.zone
chown root:bind /var/lib/bind
chmod 775 /var/lib/bind
/etc/init.d/bind9 restart

cd $SRC_DIR
msg "Configure Etc..."
echo "nbd" >> /etc/modules
modprobe nbd
for i in `seq 0 15`; do mkdir /mnt/nbd$i; mysql -uroot -p1234 -h localhost whitehole -e "insert into nbd values ('$i','0')"; done
service apache2 restart

cd $SRC_DIR
echo -e "$YELLOW ========================================================="
echo -e "$YELLOW  Congratulations, the installation is complete. ^^"
echo -e "$YELLOW  Input \"http://${LOCAL_IP}\" on your Web-Browser~~~"
echo -e "$YELLOW ========================================================="
reset_color
