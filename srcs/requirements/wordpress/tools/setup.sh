#!/bin/bash


cd /var/www/html


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



exec "$@"
