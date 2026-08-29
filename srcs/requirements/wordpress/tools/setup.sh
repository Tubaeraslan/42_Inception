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

cd /var/www/html

MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_HOSTNAME="${MYSQL_HOSTNAME:-mariadb}"
MYSQL_USER="${MYSQL_USER:-wp_app}"
MYSQL_PASSWORD="$(read_secret MYSQL_PASSWORD "${MYSQL_PASSWORD_FILE:-/run/secrets/db_password}")"
WP_ADMIN_USER="${WP_ADMIN_USER:-wpadmin}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL:-admin@teraslan.42.fr}"
WP_ADMIN_PASSWORD="$(read_secret WP_ADMIN_PASSWORD "${WORDPRESS_ADMIN_PASSWORD_FILE:-/run/secrets/wp_admin_password}")"

if [ ! -f wp-config.php ]; then
    echo "Downloading Wordpress..."
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* .
    rm -rf wordpress latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${MYSQL_HOSTNAME}/" wp-config.php
fi

chown -R www-data:www-data /var/www/html

if ! wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
    wp core install --allow-root \
        --url="${DOMAIN_NAME:-teraslan.42.fr}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path=/var/www/html
fi

exec "$@"
