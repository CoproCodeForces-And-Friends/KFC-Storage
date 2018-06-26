FROM tarantool/tarantool-nginx:latest
LABEL maintainer="ba_ski@hotmail.com"

COPY config.nginx /etc/nginx/nginx.conf
VOLUME ["/var/cache/nginx"]
EXPOSE 80 443
CMD nginx -g "daemon off;"