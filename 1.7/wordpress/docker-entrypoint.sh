#!/usr/bin/env bash
set -e

: ${ROOT:=/srv}
: ${SERVER_NAME:=localhost}
: ${PHP_FPM_HOST:=php-fpm}
: ${PHP_FPM_PORT:=9000}
: ${MEMCACHED_HOST:=memcached}
: ${MEMCACHED_PORT:=11211}
: ${WORKER_PROCESSES:=2}

if [ -z "${CANONICAL_NAME}" ]; then
  CANONICAL_NAME="$(echo -n "${SERVER_NAME}" | cut -f 1 -d " ")"
fi

declare -a vars=(ROOT SERVER_NAME CANONICAL_NAME)

for var in "${vars[@]}"; do
  name=$(echo "${var}" | tr '[:upper:]' '[:lower:]')
  eval value="\${${var}}"
  echo "set \$env_${name} ${value};" >> /etc/nginx/include/env.conf
done

# write some partials to use for our php-fpm and memcached hosts
echo "worker_processes ${WORKER_PROCESSES};" > /etc/nginx/include/worker_processes.conf
echo "fastcgi_pass ${PHP_FPM_HOST}:${PHP_FPM_PORT};" > /etc/nginx/include/php_fpm_fastcgi_pass.conf
cat <<EOF > /etc/nginx/include/memcached_upstream.conf
upstream memcached-servers {
  server ${MEMCACHED_HOST}:${MEMCACHED_PORT};
}
EOF

# if the user has ssl keys, configure nginx with ssl
if [ -f /etc/nginx/certs/ssl.key -a -f /etc/nginx/certs/ssl.crt ]; then
  ln -s /etc/nginx/sites-available/ssl.conf /etc/nginx/sites-enabled/default.conf
else
  ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
fi

exec "$@"
