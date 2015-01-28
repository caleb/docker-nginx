#!/usr/bin/env bash

if [ ! -f bin/mo ]; then
  curl https://raw.githubusercontent.com/caleb/mo/master/mo > bin/mo
  chmod +x bin/mo
fi

docker build -t docker.rodeopartners.com/nginx:1.7-wordpress .
