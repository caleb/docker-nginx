FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

RUN mkdir -p /etc/nginx/include \
 && mkdir -p /etc/nginx/sites-available \
 && mkdir -p /etc/nginx/sites-enabled \
 && rm -rf /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/nginx.conf

COPY sites-available/default.conf /etc/nginx/sites-available/default.conf
COPY sites-available/ssl.conf /etc/nginx/sites-available/ssl.conf
COPY include/wordpress.conf /etc/nginx/include/wordpress.conf

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
