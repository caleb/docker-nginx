FROM nginx:1.7

MAINTAINER Caleb Land <caleb@land.fm>

ADD https://github.com/caleb/docker-helpers/archive/master.tar.gz /tmp/helpers.tar.gz
ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

RUN mkdir -p /helpers \
&& tar xzf /tmp/helpers.tar.gz --strip-components=1 -C / docker-helpers-master/helpers \
&& rm /tmp/helpers.tar.gz \
&& chmod +x /usr/local/bin/mo \
&& mkdir -p /etc/nginx/sites-enabled \
&& rm -rf /etc/nginx/conf.d

RUN mkdir -p /etc/nginx/upstreams \
&&  mkdir -p /etc/nginx/handlers

COPY nginx.conf.mo   /etc/nginx/nginx.conf.mo
COPY sites-available /etc/nginx/sites-available
COPY include         /etc/nginx/include

COPY docker-entrypoint.sh /nginx-entrypoint.sh

ENTRYPOINT ["/nginx-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
