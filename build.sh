#!/usr/bin/env bash

echo "Building nginx:1.7"
docker build -t docker.rodeopartners.com/nginx:1.7 1.7

echo "Building nginx:1.7-php"
docker build -t docker.rodeopartners.com/nginx:1.7-php 1.7/php

echo "Building nginx:1.7-wordpress"
docker build -t docker.rodeopartners.com/nginx:1.7-wordpress 1.7/wordpress

