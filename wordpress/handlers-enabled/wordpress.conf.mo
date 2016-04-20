charset UTF-8;
index index.php index.html index.htm;

{{#MEMCACHED_ADDR}}
set $memcached_raw_key $scheme://$host$request_uri;
set $memcached_key data-$memcached_raw_key;

set $memcached_request 1;

if ($request_method = POST) {
  set $memcached_request 0;
}

if ($uri ~ "/wp-") {
  set $memcached_request 0;
}

if ($args) {
  set $memcached_request 0;
}

if ($http_cookie ~* "comment_author_|wordpressuser_|wp-postpass_|wordpress_logged_in_") {
  set $memcached_request 0;
}
{{/MEMCACHED_ADDR}}

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
  expires 24h;
  log_not_found off;
}

# redirect server error pages to the static page /50x.html
#
error_page 500 502 503 504 /50x.html;
location = /50x.html {
  root /usr/share/nginx/html;
}

# Pass the PHP scripts to FastCGI server
#
location ~ ^(?<script_name>.+?\.php)(?<path_info>.*)$ {
  {{#NGINX_PHP_CLIENT_MAX_BODY_SIZE}}
  client_max_body_size {{NGINX_PHP_CLIENT_MAX_BODY_SIZE}};
  {{/NGINX_PHP_CLIENT_MAX_BODY_SIZE}}

  {{#MEMCACHED_ADDR}}
  default_type text/html;

  if ($memcached_request = 1) {
    memcached_pass memcached-servers;
    error_page 404 = @nocache;
  }
  {{/MEMCACHED_ADDR}}

  include /etc/nginx/include/php-fastcgi-params.conf;
  include /etc/nginx/include/php-fastcgi-pass.conf;
}

{{#MEMCACHED_ADDR}}
location @nocache {
  add_header X-Cache-Engine "not cached";
  include /etc/nginx/include/php-fastcgi-params.conf;
  include /etc/nginx/include/php-fastcgi-pass.conf;
}
{{/MEMCACHED_ADDR}}

location / {
  try_files $uri $uri/ @rewrites;
}

location @rewrites {
  rewrite ^ /index.php last;
}
