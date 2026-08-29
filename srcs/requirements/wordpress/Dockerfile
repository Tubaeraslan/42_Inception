FROM debian:bookworm


RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    wget \
    curl \
    mariadb-client \
    && apt clean


RUN mkdir -p /run/php


RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf


COPY tools/setup.sh /usr/local/bin/setup.sh


RUN chmod +x /usr/local/bin/setup.sh


WORKDIR /var/www/html


EXPOSE 9000


ENTRYPOINT ["/usr/local/bin/setup.sh"]


CMD ["php-fpm8.2", "-F"]
