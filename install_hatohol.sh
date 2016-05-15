#!/bin/bash

#install hatohol
yum install -y unzip wget
wget -P /etc/yum.repos.d/ http://project-hatohol.github.io/repo/hatohol-el7.repo
wget -P http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm /tmp/
rpm -ivh /tmp/epel-release-7-6.noarch.rpm
yum install -y hatohol-server hatohol-web

#configure firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=162/udp --permanent
firewall-cmd --add-port=5672/tcp --zone=public --permanent
firewall-cmd --add-port=5672/tcp --zone=public

#cnfigure mariadb
sed -i -e "4i innodb_file_per_table" /etc/my.cnf
sed -i -e "4i innodb_log_buffer_size=16M" /etc/my.cnf
sed -i -e "4i innodb_buffer_pool_size=$(expr $(free|grep '^Mem'|awk '{print $2}') / 2)" /etc/my.cnf
sed -i -e "4i innodb_log_file_size=$(expr $(free|grep '^Mem'|awk '{print $2}') / 10)" /etc/my.cnf
sed -i -e "4i innodb_log_files_in_group=2" /etc/my.cnf
sed -i -e "4i key_buffer_size=$(expr $(free|grep '^Mem'|awk '{print $2}') / 10)" /etc/my.cnf
sed -i -e "4i max_allowed_packet=16MB" /etc/my.cnf
sed -i -e "4i skip-character-set-client-handshake" /etc/my.cnf
sed -i -e "4i character-set-server=utf8" /etc/my.cnf

systemctl enable mariadb
systemctl start mariadb

hatohol-db-initiator --db-user "" --db-password ""

mysql -uroot -e "CREATE DATABASE hatohol_client DEFAULT CHARACTER SET utf8;GRANT ALL PRIVILEGES ON hatohol_client.* TO hatohol@localhost IDENTIFIED BY 'hatohol';"

/usr/libexec/hatohol/client/manage.py syncdb

systemctl enable hatohol
systemctl enable httpd

systemctl start hatohol
systemctl start httpd

#プラグイン周り
setsebool -P nis_enabled 1
systemctl enable rabbitmq-server
systemctl start rabbitmq-server.service
rabbitmqctl add_vhost hatohol
rabbitmqctl add_user hatohol hatohol
rabbitmqctl set_permissions -p hatohol hatohol ".*" ".*" ".*"
curl -kL  https://bootstrap.pypa.io/get-pip.py | python
pip install pika daemon
yum install -y hatohol-hap2-fluentd

#mkdir /opt/hatohol_azu
#wget <pythonサーバ> -P /opt/hatohol_azu
#wget <python_service> -P /usr/lib/systemd/system


