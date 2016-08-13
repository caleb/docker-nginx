#!/usr/bin/env bash

docker pull nginx:1.7
docker pull nginx:1.9
docker pull nginx:1.10

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t caleb/nginx:1.7 -f Dockerfile-1.7 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.9 -f Dockerfile-1.9 .
docker build --no-cache=$NO_CACHE -t caleb/nginx:1.10 -f Dockerfile-1.10 .

docker tag caleb/nginx:1.10 caleb/nginx:latest

cd php
./build.sh $NO_CACHE
cd ..

cd wordpress
./build.sh $NO_CACHE
cd ..

cd rails
./build.sh $NO_CACHE
cd ..
