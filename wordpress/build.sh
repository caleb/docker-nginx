#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.7-wordpress -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.9-wordpress -f Dockerfile-1.9 .

docker tag -f docker.rodeopartners.com/nginx:1.9-wordpress docker.rodeopartners.com/nginx:latest-wordperss