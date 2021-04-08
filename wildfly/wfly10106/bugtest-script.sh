#!/bin/bash

conf_folder=$1

function print_help() {
  echo "Usage: $0 conf_folder"
}

if [ -z "$conf_folder" ]; then
  print_help
  exit 1
fi

#try to stop a potential running wildfly
systemctl stop wildfly.service

# cleanup
rm -rf /opt/*

#reinstall wildfly
cd /opt/ || mkdir /opt && cd /opt || exit

tar xfz /vagrant/wildfly-13.0.0.Final.tar.gz
ln -s wildfly-13.0.0.Final wildfly
chown -R wildfly:wildfly wildfly-13.0.0.Final/

# start wildfly
systemctl start wildfly.service

#waiting for boot
# shellcheck disable=SC2069
while ! /opt/wildfly/bin/jboss-cli.sh -c "ls" > /dev/null 2>&1; do echo Waiting for wildfly... ; sleep 1; done

# change the time and the date of the system to a moment that triggers the bug
sudo date --set="27 March 2021 23:59:00"

#deploy all projects found in deploy/
for proj_war in "$conf_folder"/*.war; do
  echo "deploying $proj_war"
  /opt/wildfly/bin/jboss-cli.sh -c "deploy $proj_war"
done

echo "Wait 1 minute so the bug triggers (it triggers at 23:59:50)"
date
sleep 60
echo Done waiting
date
systemctl stop wildfly.service

tar xfz /vagrant/wildfly-13.0.1.Final.tar.gz
chown -R wildfly:wildfly wildfly-13.0.1.Final/
rm wildfly
ln -s wildfly-13.0.1.Final wildfly

systemctl start wildfly.service

#waiting for boot
while ! /opt/wildfly/bin/jboss-cli.sh -c "ls" > /dev/null 2>&1; do echo Waiting for wildfly... ; sleep 1; done

# change the time and the date of the system to a moment that triggers the bug
sudo date --set="27 March 2021 23:59:00"

#deploy all projects found in deploy/
for proj_war in "$conf_folder"/*.war; do
  echo "deploying $proj_war"
  /opt/wildfly/bin/jboss-cli.sh -c "deploy $proj_war"
done

echo "Wait 1 minute so the bug should trigger (it triggers at 23:59:50)"
date
sleep 60
echo Done waiting
date
systemctl stop wildfly.service

# now with just the patch of ejb-jar
mv wildfly-13.0.0.Final wildfly-13.0.0.Final-bugged
tar xfz /vagrant/wildfly-13.0.0.Final.tar.gz
mv wildfly-13.0.0.Final wildfly-13.0.0.Final-patched
cp wildfly-13.0.1.Final/modules/system/layers/base/org/jboss/as/ejb3/main/wildfly-ejb3-13.0.1.Final.jar wildfly-13.0.0.Final-patched/modules/system/layers/base/org/jboss/as/ejb3/main/wildfly-ejb3-13.0.1.Final.jar
sed -i 's/wildfly-ejb3-13.0.0.Final.jar/wildfly-ejb3-13.0.1.Final.jar/g' wildfly-13.0.0.Final-patched/modules/system/layers/base/org/jboss/as/ejb3/main/module.xml
chown -R wildfly:wildfly wildfly-13.0.0.Final-patched/
rm wildfly
ln -s wildfly-13.0.0.Final-patched wildfly

systemctl start wildfly.service

#waiting for boot
while ! /opt/wildfly/bin/jboss-cli.sh -c "ls" > /dev/null 2>&1; do echo Waiting for wildfly... ; sleep 1; done

# change the time and the date of the system to a moment that triggers the bug
sudo date --set="27 March 2021 23:59:00"

#deploy all projects found in deploy/
for proj_war in "$conf_folder"/*.war; do
  echo "deploying $proj_war"
  /opt/wildfly/bin/jboss-cli.sh -c "deploy $proj_war"
done

echo "Wait 1 minute so the bug should trigger (it triggers at 23:59:50)"
date
sleep 60
echo Done waiting
date
systemctl stop wildfly.service

# now rollback the patch
cp -R wildfly-13.0.0.Final-patched wildfly-13.0.0.Final-patched-rollback
rm wildfly-13.0.0.Final-patched-rollback/standalone/log/*
rm -rf wildfly-13.0.0.Final-patched-rollback/standalone/tmp/*
rm -rf wildfly-13.0.0.Final-patched-rollback/standalone/data/*
cp wildfly-13.0.0.Final-patched-rollback/standalone/configuration/standalone_xml_history/standalone.initial.xml wildfly-13.0.0.Final-patched-rollback/standalone/configuration/standalone.xml
sed -i 's/wildfly-ejb3-13.0.1.Final.jar/wildfly-ejb3-13.0.0.Final.jar/g' wildfly-13.0.0.Final-patched-rollback/modules/system/layers/base/org/jboss/as/ejb3/main/module.xml
chown -R wildfly:wildfly wildfly-13.0.0.Final-patched-rollback/
rm wildfly
ln -s wildfly-13.0.0.Final-patched-rollback wildfly

systemctl start wildfly.service

#waiting for boot
while ! /opt/wildfly/bin/jboss-cli.sh -c "ls" > /dev/null 2>&1; do echo Waiting for wildfly... ; sleep 1; done

# change the time and the date of the system to a moment that triggers the bug
sudo date --set="27 March 2021 23:59:00"

#deploy all projects found in deploy/
for proj_war in "$conf_folder"/*.war; do
  echo "deploying $proj_war"
  /opt/wildfly/bin/jboss-cli.sh -c "deploy $proj_war"
done

echo "Wait 1 minute so the bug should trigger (it triggers at 23:59:50)"
date
sleep 60
echo Done waiting
date
systemctl stop wildfly.service


echo Bug should no longer be there
echo Check /opt/wildfly-13.0.0.Final-bugged/standalone/log/server.log, /opt/wildfly-13.0.1.Final/standalone/log/server.log, /opt/wildfly-13.0.0.Final-patched/standalone/log/server.log, and /opt/wildfly-13.0.0.Final-patched-rollback/standalone/log/server.log
