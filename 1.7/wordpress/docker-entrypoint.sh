#!/usr/bin/env bash
set -e

# create the environment variable include file to we can access our environment
# from the nginx config
env | while read e; do
    name="$(echo -n "${e}" | cut -f 1 -d =)"
    value="${e#$name=}"
    echo "set \$env_${name} ${value};" >> /etc/nginx/env.conf
done

exec "$@"
