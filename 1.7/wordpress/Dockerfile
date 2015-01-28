FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/default.conf
COPY ssl.conf /etc/nginx/ssl.conf
COPY wordpress.conf /etc/nginx/wordpress.conf
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
