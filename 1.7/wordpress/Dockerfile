FROM docker.rodeopartners.com/nginx:1.7-php

MAINTAINER Caleb Land <caleb@land.fm>

COPY handlers/*           /etc/nginx/handlers/
COPY sites-available/*    /etc/nginx/sites-available/
COPY docker-entrypoint.sh /nginx-wordpress-entrypoint.sh

ENTRYPOINT ["/nginx-wordpress-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
