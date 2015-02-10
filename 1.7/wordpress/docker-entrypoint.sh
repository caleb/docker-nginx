#!/usr/bin/env bash
set -e
shopt -s globstar

export MEMCACHED_ADDR
export MEMCACHED_PORT
export WORDPRESS_DIR
export WORDPRESS_UPLOADS_DIR

: ${WORDPRESS_DIR:=/srv/wordpress}
: ${WORDPRESS_UPLOADS_DIR:=/uploads}
: ${MEMCACHED_ADDR:=}
: ${MEMCACHED_PORT:=11211}

if [ -z "${NGINX_ROOT}" ]; then
  NGINX_ROOT="${WORDPRESS_DIR}"
fi

if [ -z "${WORDPRESS_DIR}" ] || [ ! -d "${WORDPRESS_DIR}" ] || [ ! -d "${WORDPRESS_DIR}/wp-admin" ]; then
  echo "Either WORDPRESS_DIR isn't set, or doesn't point to a wordpress directory"
  exit 1
fi

#
# Check that the uploads directory is linked outside of the wordpress project
#
uploads_link_found=false
for link_var in ${!NGINX_SHARED_LINK*}; do
  link="${!link_var}"
  to="${link#*:}"
  if [ "${to}" = "${WORDPRESS_DIR}/wp-content/uploads" ]; then
    uploads_link_found=true
  fi
done

if [ "${uploads_link_found}" = "false" ]; then
  if [ -z "${WORDPRESS_UPLOADS_DIR}" ] ||
       [ ! -d "${WORDPRESS_UPLOADS_DIR}" ]; then
    echo "You need to specify a shared link to a uploads folder by specifying WORDPRESS_UPLOADS_DIR"
    exit 1
  else
    # The user gave a WORDPRESS_UPLOADS_DIR, create a link
    export NGINX_SHARED_LINK_WORDPRESS_UPLOADS_DIR="${WORDPRESS_UPLOADS_DIR}:${WORDPRESS_DIR}/wp-content/uploads"
  fi
fi

# Enable the memcached upstream if a memcached addr is specified
if [ -n "${MEMCACHED_ADDR}" ]; then
  memcached_upstream_conf_file="/etc/nginx/sites-available/memcached_upstream.conf.mo"
  /usr/local/bin/mo "${memcached_upstream_conf_file}" > "${memcached_upstream_conf_file%.mo}"
  rm "${memcached_upstream_conf_file%.mo}"
  ln -s /etc/nginx/sites-available/memcached_upstream.conf /etc/nginx/sites-enabled
fi

exec /nginx-php-entrypoint.sh "$@"
