#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.7 -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.9 -f Dockerfile-1.9 .

docker tag -f docker.rodeopartners.com/nginx:1.9 docker.rodeopartners.com/nginx:latest

cd php
./build.sh $NO_CACHE
cd ..

cd wordpress
./build.sh $NO_CACHE
cd ..

cd rails
./build.sh $NO_CACHE
cd ..
