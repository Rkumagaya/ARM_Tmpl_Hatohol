#!/bin/bash

#install hatohol
yum install -y unzip wget
wget -P /etc/yum.repos.d/ http://project-hatohol.github.io/repo/hatohol-el7.repo
wget -P /tmp/ http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm -ivh /tmp/epel-release-7-9.noarch.rpm
yum install -y hatohol-server
yum install -y hatohol-web
yum install -y mariadb-server

systemctl enable mariadb
systemctl start mariadb

hatohol-db-initiator --db-user "" --db-password ""

mysql -uroot -e "CREATE DATABASE hatohol_client DEFAULT CHARACTER SET utf8;GRANT ALL PRIVILEGES ON hatohol_client.* TO hatohol@localhost IDENTIFIED BY 'hatohol';"

/usr/libexec/hatohol/client/manage.py syncdb

#プラグイン周り
wget -O /etc/yum.repos.d/epel-erlang.repo http://repos.fedorapeople.org/repos/peter/erlang/epel-erlang.repo
yum install -y erlang
rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
yum install -y rabbitmq-server

systemctl enable rabbitmq-server
systemctl start rabbitmq-server

rabbitmqctl add_vhost hatohol
rabbitmqctl add_user hatohol hatohol
rabbitmqctl set_permissions -p hatohol hatohol ".*" ".*" ".*"

curl -kL  https://bootstrap.pypa.io/get-pip.py | python
pip install pika daemon
yum install -y hatohol-hap2-fluentd
yum install -y hatohol-hap2-zabbix
hatohol-db-initiator --db-user "" --db-password ""

mkdir /opt/azure_trapper
chmod a+r,a+w /opt/azure_trapper
wget -P /opt/azure_trapper/ https://raw.githubusercontent.com/Rkumagaya/ARM_Tmpl_Hatohol/master/azure_trapper.py
wget -P /opt/azure_trapper/ https://raw.githubusercontent.com/Rkumagaya/ARM_Tmpl_Hatohol/master/start_hap_fluentd.sh
wget -P /opt/azure_trapper/ https://raw.githubusercontent.com/Rkumagaya/ARM_Tmpl_Hatohol/master/Azure-reader.conf
wget -P /usr/lib/systemd/system/ https://raw.githubusercontent.com/Rkumagaya/ARM_Tmpl_Hatohol/master/hap_fluentd.service
wget -P /usr/lib/systemd/system/ https://raw.githubusercontent.com/Rkumagaya/ARM_Tmpl_Hatohol/master/azure_trapper.service
wget -P /tmp wget http://packages.treasuredata.com.s3.amazonaws.com/2/redhat/7/x86_64/td-agent-2.3.0-0.el7.x86_64.rpm
rpm -i /tmp/td-agent-2.3.0-0.el7.x86_64.rpm

chmod a+x /opt/azure_trapper/start_hap_fluentd.sh
chmod a+x /opt/azure_trapper/azure_trapper.py
systemctl daemon-reload

systemctl enable hatohol
systemctl enable httpd

systemctl start hatohol
systemctl start httpd
