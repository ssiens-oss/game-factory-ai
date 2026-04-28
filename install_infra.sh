#!/bin/bash

sudo apt update
sudo apt install -y redis-server python3-pip

sudo systemctl enable redis-server
sudo systemctl restart redis-server

pip3 install redis
