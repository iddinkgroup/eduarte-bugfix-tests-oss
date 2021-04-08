# Test WFLY-10106 fix
Project to test the bugfix for [WFLY-10106](https://issues.redhat.com/browse/WFLY-10106)

## Dependencies
- Maven 3.x
- Java 8
- Vagrant
- VirtualBox or VMWare Workstation/Fusion

# Testing the fix
First build this project using Maven

`mvn package`

Then start the Vagrant machine

`vagrant up`

Then check the output of the logfile

`vagrant ssh -- -t 'sudo tail -f /opt/wildfly/standalone/log/server.log'`

## Vagrant with VMWare Desktop
If you have Vagrant VMWare support you can use the following command to use 

`vagrant up --provider vmware_desktop`