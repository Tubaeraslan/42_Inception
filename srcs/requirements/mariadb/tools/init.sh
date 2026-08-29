#!/bin/bash

set -e


if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing MariaDB database..."

    mysql_install_db \
        --user=mysql \
        --datadir=/var/lib/mysql

fi


echo "Starting temporary MariaDB server..."

mysqld_safe --skip-networking --skip-grant-tables &


until mysqladmin ping --silent; do
    sleep 1
done


echo "Creating database and users..."


mysql <<EOF

FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF


echo "Stopping temporary MariaDB..."

mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

sleep 2


echo "Starting MariaDB..."

exec mysqld

