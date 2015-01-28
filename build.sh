#!/usr/bin/env bash

echo "Building nginx:1.7-wordpress"
docker build -t docker.rodeopartners.com/nginx:1.7-wordpress 1.7/wordpress
