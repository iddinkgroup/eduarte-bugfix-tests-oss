#!/bin/bash

conf_folder=$1

function print_help() {
  echo "Usage: $0 conf_folder"
}

if [ -z "$conf_folder" ]; then
  print_help
  exit 1
fi

yum update
yum -y upgrade

# Download wildfly 13.0.0

# Download wildfly 13.0.1


# install java8 (centos method)
cat <<'EOF' > /etc/yum.repos.d/adoptopenjdk.repo
[AdoptOpenJDK]
name=AdoptOpenJDK
baseurl=http://adoptopenjdk.jfrog.io/adoptopenjdk/rpm/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public
EOF
yum -y install adoptopenjdk-8-hotspot

#setup wildfly user
useradd -d /home/wildfly -m -s/bin/sh -U -u 2000 wildfly

#install wildfly
cd /opt/ || mkdir /opt && cd /opt || exit

tar xfz /vagrant/wildfly-13.0.0.Final.tar.gz
ln -s wildfly-13.0.0.Final wildfly
chown -R wildfly:wildfly wildfly-13.0.0.Final/


#setup wildfly as a service
cat <<'EOF' > /etc/systemd/system/wildfly.service
[Unit]
Description=WildFly application server
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh
Restart=always
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF

# Make sure we are in a timezone with DST
timedatectl set-timezone Europe/Amsterdam

systemctl daemon-reload
systemctl enable wildfly.service

