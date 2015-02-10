#!/usr/bin/env bash
dir="$(dirname $0)"
docker build -t docker.rodeopartners.com/nginx:1.7-php "${dir}"
