#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t caleb/nginx:1.7-rails -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.9-rails -f Dockerfile-1.9 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.10-rails -f Dockerfile-1.10 .

docker tag -f caleb/nginx:1.10-rails caleb/nginx:latest-rails
