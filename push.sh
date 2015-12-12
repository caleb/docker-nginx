#!/usr/bin/env bash

docker push caleb/nginx:1.7
docker push caleb/nginx:1.9
docker push caleb/nginx:latest

cd php
./push.sh
cd ..

cd wordpress
./push.sh
cd ..

cd rails
./push.sh
cd ..
