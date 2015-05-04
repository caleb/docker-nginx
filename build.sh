#!/usr/bin/env bash

NO_CACHE="${1:-false}"

echo "Building nginx:1.7"
cd 1.7
./build.sh $NO_CACHE
cd ..
docker tag -f docker.rodeopartners.com/nginx:1.7 docker.rodeopartners.com/nginx:latest

echo "Building nginx:1.7-php"
cd 1.7/php
./build.sh $NO_CACHE
cd ../..
docker tag -f docker.rodeopartners.com/nginx:1.7-php docker.rodeopartners.com/nginx:latest-php

echo "Building nginx:1.7-wordpress"
cd 1.7/wordpress
./build.sh $NO_CACHE
cd ../..
docker tag -f docker.rodeopartners.com/nginx:1.7-wordpress docker.rodeopartners.com/nginx:latest-wordpress

echo "Building nginx:1.7-rails"
cd 1.7/rails
./build.sh $NO_CACHE
cd ../..
docker tag -f docker.rodeopartners.com/nginx:1.7-rails docker.rodeopartners.com/nginx:latest-rails
