#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/nginx:1.7-rails .
