#!/bin/bash

# generate ssh key
echo "Y" | ssh-keygen -t rsa -P "" -f config/id_rsa

# Make build images
make build