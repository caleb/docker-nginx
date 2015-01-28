server {
	listen 80; ## listen for ipv4; this line is default and implied
	listen [::]:80 default ipv6only=on; ## listen for ipv6
  
  server_name {{NGINX_SERVER_NAME}};
  
  include /etc/nginx/include/wordpress.conf;
}

{{#MEMCACHED_ADDR}}
include /etc/nginx/include/memcached_upstream.conf;
{{#MEMCACHED_ADDR}}
