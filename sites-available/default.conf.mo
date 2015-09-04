server {
  listen 80; ## listen for ipv4; this line is default and implied
  listen [::]:80 default ipv6only=on; ## listen for ipv6

  server_name {{NGINX_SERVER_NAME}};

  root {{NGINX_ROOT}};

  autoindex {{NGINX_AUTOINDEX}};

  include /etc/nginx/handlers-enabled/*.conf;
}
