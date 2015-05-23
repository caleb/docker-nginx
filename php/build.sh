#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.7-php -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.9-php -f Dockerfile-1.9 .

docker tag -f docker.rodeopartners.com/nginx:1.9-php docker.rodeopartners.com/nginx:latest-php
