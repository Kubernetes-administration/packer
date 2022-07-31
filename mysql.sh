#!/bin/bash

DATABASE_PASSWORD=rootDBPass#12

echo 'Installing mysql server 8.0 Community Edition'
sudo yum install -y https://repo.mysql.com//mysql80-community-release-el8-4.noarch.rpm
sudo yum module disable -y mysql
sudo yum install -y mysql-community-server

echo ' Starting mysql server for First Time '
sudo systemctl start mysqld


tempRootPass="`sudo grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"

echo 'Setting up new mysql server root password'
mysql -u "root" --password="$tempRootPass" --connect-expired-password -e "alter user root@localhost identified by '${DATABASE_PASSWORD}'; flush privileges;" 2>/dev/null

mysql -u root --password="$DATABASE_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; FLUSH PRIVILEGES;" 2>/dev/null

echo "Sanity check: check if password login works for root."
mysql -u root --password="$DATABASE_PASSWORD" -e quit 2>/dev/null
