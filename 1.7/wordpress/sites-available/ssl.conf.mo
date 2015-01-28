server {
	listen 80; ## listen for ipv4; this line is default and implied
	listen [::]:80 default ipv6only=on; ## listen for ipv6
  
  server_name {{SERVER_NAME}};
  
  redirect 301 https://$canonical_name$request_uri;
}

server {
  listen 443 ssl;
  listen [::]:443 default ssl ipv6only=on; ## listen for ipv6
  
  server_name {{SERVER_NAME}};

  ssl_certificate     /etc/nginx/certs/ssl.crt;
  ssl_certificate_key /etc/nginx/certs/ssl.key; 
  
  include /etc/nginx/include/wordpress.conf;
}

include /etc/nginx/include/memcached_upstream.conf;

