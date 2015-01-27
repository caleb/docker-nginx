FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
