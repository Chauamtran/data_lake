#!/bin/bash


# Force to change permission of keys
sudo chmod 600 configs/id_rsa
sudo chmod 600 configs/id_rsa.pub
sudo chmod 644 ~/.ssh/known_hosts

# Make build images
make build