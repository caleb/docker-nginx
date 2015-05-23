#!/usr/bin/env bash
set -e
shopt -s globstar

. /helpers/vars.sh
. /helpers/links.sh
. /helpers/auto-symlink.sh

read-var WITH_MEMCACHED        -- no
read-var WORDPRESS_DIR         -- /srv/wordpress
read-var WORDPRESS_UPLOADS_DIR -- /uploads

if [ -z "${NGINX_ROOT}" ]; then
  export NGINX_ROOT="${WORDPRESS_DIR}"
fi

if [ -z "${WORDPRESS_DIR}" ] || [ ! -d "${WORDPRESS_DIR}" ] || [ ! -d "${WORDPRESS_DIR}/wp-admin" ]; then
  echo "Either WORDPRESS_DIR isn't set, or doesn't point to a wordpress directory (i.e. one that contains a wp-admin directory)"
  exit 1
fi

if [ -n "${WORDPRESS_UPLOADS_DIR}" ]; then
  # Give this a special prefix so that it overwrites previous symlinks that
  # might be set by the normal "SYMLINK_*" variables
  __WORDPRESS_SYMLINK_UPLOADS="${WORDPRESS_UPLOADS_DIR} => ${WORDPRESS_DIR}/wp-content/uploads"
fi

auto-symlink
auto-symlink "__WORDPRESS"

#
# Check that the uploads directory is linked outside of the wordpress project
#
if [ ! -L "${WORDPRESS_DIR}/wp-content/uploads" ]; then
  # If the uploads directory isn't a link, check to see
  echo "You need to specify the path for storing uploads by specifying WORDPRESS_UPLOADS_DIR"
  exit 1
fi

if [ "${WITH_MEMCACHED,,}" = "yes"] || [ "${WITH_MEMCACHED,,}" = "true"]; then
  read-link MEMCACHED memcached 11211 tcp

  # Enable the memcached upstream if a memcached addr is specified
  if [ -n "${MEMCACHED_ADDR}" ] && [ -n "${MEMCACHED_PORT}" ] && [ -f /etc/nginx/upstreams-available/memcached_upstream.conf.mo ]; then
    memcached_upstream_conf_file="/etc/nginx/upstreams-available/memcached_upstream.conf.mo"
    /usr/local/bin/mo "${memcached_upstream_conf_file}" > "${memcached_upstream_conf_file%.mo}"
    rm "${memcached_upstream_conf_file}"
    ln -s /etc/nginx/upstreams-available/memcached_upstream.conf /etc/nginx/upstreams-enabled
  fi
fi

exec /nginx-php-entrypoint.sh "$@"
