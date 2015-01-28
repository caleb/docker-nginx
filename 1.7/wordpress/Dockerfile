FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

RUN mkdir -p /etc/nginx/include \
 && mkdir -p /etc/nginx/sites-available \
 && mkdir -p /etc/nginx/sites-enabled \
 && rm -rf /etc/nginx/conf.d

COPY bin/mo /usr/local/bin/mo

COPY nginx.conf.mo /etc/nginx/nginx.conf.mo

COPY sites-available/default.conf.mo /etc/nginx/sites-available/default.conf.mo
COPY sites-available/ssl.conf.mo /etc/nginx/sites-available/ssl.conf.mo
COPY include/wordpress.conf.mo /etc/nginx/include/wordpress.conf.mo

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
