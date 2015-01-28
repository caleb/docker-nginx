#!/usr/bin/env bash
set -e

if [ -z "${ROOT}" ]; then
    export ROOT=/srv
fi

if [ -z "${SERVER_NAME}" ]; then
    export SERVER_NAME=localhost
fi

# Generate a canonical name if one isn't provided
if [ -z "${CANONICAL_NAME}" ]; then
    export CANONICAL_NAME="$(echo -n "${SERVER_NAME}" | cut -f 1 -d " ")"
fi

# create the environment variable include file to we can access our environment
# from the nginx config
env | while read e; do
    name="$(echo -n "${e}" | cut -f 1 -d =)"
    value="${e#$name=}"
    echo "set \$env_${name} ${value};" >> /etc/nginx/env.conf
done

# if the user has ssl keys, configure nginx with ssl
if [ -f /etc/nginx/certs/ssl.key -a -f /etc/nginx/certs/ssl.crt ]; then
    cp /etc/nginx/ssl.conf /etc/nginx/conf.d/ssl.conf
else
    cp /etc/nginx/default.conf /etc/nginx/conf.d/default.conf
fi

exec "$@"
