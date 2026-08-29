#!/bin/bash

set -e

read_secret() {
    local name="$1"
    local file_path="$2"

    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        printf '%s' "$(tr -d '\r\n' < "$file_path")"
        return 0
    fi

    if [ -n "${!name}" ]; then
        printf '%s' "${!name}"
        return 0
    fi

    return 1
}

MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_USER="${MYSQL_USER:-wp_app}"
MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER:-wp_admin}"
MYSQL_PASSWORD="$(read_secret MYSQL_PASSWORD "${MYSQL_PASSWORD_FILE:-/run/secrets/db_password}")"
MYSQL_ADMIN_PASSWORD="$(read_secret MYSQL_ADMIN_PASSWORD "${MYSQL_ADMIN_PASSWORD_FILE:-/run/secrets/db_admin_password}")"
MYSQL_ROOT_PASSWORD="$(read_secret MYSQL_ROOT_PASSWORD "${MYSQL_ROOT_PASSWORD_FILE:-/run/secrets/db_root_password}")"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
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
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_ADMIN_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF


echo "Stopping temporary MariaDB..."

mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

sleep 2


echo "Starting MariaDB..."

exec mysqld

