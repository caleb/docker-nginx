#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t caleb/nginx:1.7-wordpress -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.9-wordpress -f Dockerfile-1.9 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.10-wordpress -f Dockerfile-1.10 .

docker tag caleb/nginx:1.10-wordpress caleb/nginx:latest-wordpress
