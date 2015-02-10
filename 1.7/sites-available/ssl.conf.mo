server {
  listen 443 ssl;
  listen [::]:443 default ssl ipv6only=on; ## listen for ipv6
  
  server_name {{NGINX_SERVER_NAME}};

  ssl_certificate     /etc/nginx/certs/ssl.crt;
  ssl_certificate_key /etc/nginx/certs/ssl.key; 
  
  root {{NGINX_ROOT}};

  include /etc/nginx/handlers/*.conf;
}

include /etc/nginx/include/http-to-https-redirect.conf;
