user nginx;
worker_processes {{NGINX_WORKER_PROCESSES}};

error_log /var/log/nginx/error.log warn;
pid       /var/run/nginx.pid;

events {
  worker_connections 1024;
}

http {
  include      /etc/nginx/mime.types;
  default_type application/octet-stream;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';

  access_log /var/log/nginx/access.log  main;

  sendfile    on;
  #tcp_nopush on;

  keepalive_timeout 65;

  ## Compression
  gzip              on;
  gzip_buffers      16 8k;
  gzip_comp_level   4;
  gzip_http_version 1.0;
  gzip_min_length   1280;
  gzip_types        text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript image/x-icon image/bmp;
  gzip_vary         on;

  variables_hash_bucket_size 128;

  include /etc/nginx/sites-enabled/*.conf;
}
