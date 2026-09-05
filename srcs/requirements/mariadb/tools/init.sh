#!/bin/bash

set -euo pipefail

read_secret() {
    local name="$1"
    local file_path="$2"

    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        printf '%s' "$(tr -d '\r\n' < "$file_path")"
        return 0
    fi

    if [ -n "${!name:-}" ]; then
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
    echo "Initializing MariaDB database directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Generating temporary init SQL file..."
    cat > /tmp/init.sql <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \\`${MYSQL_DATABASE}\\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \\`${MYSQL_DATABASE}\\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON \\`${MYSQL_DATABASE}\\`.* TO '${MYSQL_ADMIN_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    chmod 600 /tmp/init.sql

    echo "Starting MariaDB with --init-file to run initial statements..."
    exec mysqld --init-file=/tmp/init.sql
else
    echo "MariaDB data directory already initialized, starting MariaDB normally..."
    exec mysqld
fi

