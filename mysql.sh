#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------
# Set the Root Password. This should include lower case letters, upper case letters, numbers and special characters.
#-------------------------------------------------------------------------------------------------------------------
DATABASE_PASSWORD=rootDBPass#12

#-------------------------------------------------------------------------------------------------------------------
# Remove Existing Installation. Comment out these lines if not needed

#-------------------------------------------------------------------------------------------------------------------
# Set Yum Repository and Install MySQL Community Server
#-------------------------------------------------------------------------------------------------------------------

echo 'Installing mysql server 8.0 Community Edition '
sudo yum install -y https://repo.mysql.com//mysql80-community-release-el8-4.noarch.rpm

# Disabling the Default MySQL Module (EL8 systems only) 
sudo yum module disable -y mysql

sudo yum install -y mysql-community-server

#-------------------------------------------------------------------------------------------------------------------
# Start MySQL Server and Grep Temporary Password
#-------------------------------------------------------------------------------------------------------------------

echo ' Starting mysql server for First Time '

sudo systemctl start mysqld
# systemctl enable mysqld.service

tempRootPass="`sudo grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"

#-------------------------------------------------------------------------------------------------------------------
# Set New Password for root user
#-------------------------------------------------------------------------------------------------------------------
echo 'Setting up new mysql server root password'

mysql -u "root" --password="$tempRootPass" --connect-expired-password -e "alter user root@localhost identified by '${DATABASE_PASSWORD}'; flush privileges;" 2>/dev/null


#-------------------------------------------------------------------------------------------------------------------
# Do the Basic Hardening
#-------------------------------------------------------------------------------------------------------------------

mysql -u root --password="$DATABASE_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; FLUSH PRIVILEGES;" 2>/dev/null
# sudo systemctl status mysqld.service

#-------------------------------------------------------------------------------------------------------------------
# Perform a Sanity Check
#-------------------------------------------------------------------------------------------------------------------
echo "Sanity check: check if password login works for root."
mysql -u root --password="$DATABASE_PASSWORD" -e quit 2>/dev/null

#-------------------------------------------------------------------------------------------------------------------
# Enable Firewall
#-------------------------------------------------------------------------------------------------------------------
# echo "Enabling Firewall Services."
# sudo firewall-cmd --permanent --add-service=mysql
# sudo firewall-cmd --reload

#-------------------------------------------------------------------------------------------------------------------
# Final Output
#-------------------------------------------------------------------------------------------------------------------
#echo "MySQL server installation completed, root password: $DATABASE_PASSWORD";