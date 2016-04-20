# Pass the PHP scripts to FastCGI server
#
location ~ (\.php) {
  try_files $uri =404;

  {{#NGINX_PHP_CLIENT_MAX_BODY_SIZE}}
  client_max_body_size {{NGINX_PHP_CLIENT_MAX_BODY_SIZE}};
  {{/NGINX_PHP_CLIENT_MAX_BODY_SIZE}}

  include /etc/nginx/include/php-fastcgi-params.conf;
  include /etc/nginx/include/php-fastcgi-pass.conf;
}
