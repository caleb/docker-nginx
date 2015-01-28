FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

RUN chmod +x /usr/local/bin/mo \
 && mkdir -p /etc/nginx/sites-enabled \
 && rm -rf /etc/nginx/conf.d

COPY nginx.conf.mo   /etc/nginx/nginx.conf.mo
COPY sites-available /etc/nginx/sites-available
COPY include         /etc/nginx/include

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
