FROM debian:bookworm


RUN apt update && \
    apt install -y nginx openssl && \
    apt clean


RUN mkdir -p /etc/nginx/ssl


COPY conf/nginx.conf /etc/nginx/conf.d/default.conf


COPY tools/start.sh /usr/local/bin/start.sh


RUN chmod +x /usr/local/bin/start.sh


EXPOSE 443


ENTRYPOINT ["/usr/local/bin/start.sh"]


CMD ["nginx", "-g", "daemon off;"]
