upstream memcached-servers {
  server {{NGINX_MEMCACHED_ADDR}}:{{NGINX_MEMCACHED_PORT}};
}
