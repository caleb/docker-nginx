FROM docker.rodeopartners.com/nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

COPY handlers/*           /etc/nginx/handlers/
COPY docker-entrypoint.sh /nginx-php-entrypoint.sh

ENTRYPOINT ["/nginx-php-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
