# ~2 seconds is often enough for most folks to parse HTML/CSS and
# retrieve needed images/icons/frames, connections are cheap in
# nginx so increasing this is generally safe...
keepalive_timeout 5;

# auth_basic            "Restricted Area";
# auth_basic_user_file  /usr/local/nginx/conf/htpasswd;

try_files $uri/index.html $uri.html $uri @app;

location @app {
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

  # enable this if you forward HTTPS traffic to unicorn,
  # this helps Rack set the proper URL scheme for doing redirects:
  proxy_set_header X-Forwarded-Proto $scheme;

  # pass the Host: header from the client right along so redirects
  # can be set properly within the Rack application
  proxy_set_header Host $http_host;

  # we don't want nginx trying to do something clever with
  # redirects, we set the Host: header above already.
  proxy_redirect off;

  proxy_pass http://unicorn;
}

# Rails error pages
error_page 500 502 503 504 /500.html;
location = /500.html {
  root {{NGINX_ROOT}}/public;
}
