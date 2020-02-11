#!/bin/bash

# generate ssh key, only for nodemaster
echo "Y" | ssh-keygen -t rsa -b 4096 -P "" -f configs/id_rsa

# Copy ssh keys to data nodes
echo "Copying ssh keys to data nodes. Also use nodemaster as datanote when it is necessary"
ssh-copy-id -i $HOME/data_lake/system/configs/id_rsa.pub sdeploy@nodemaster
ssh-copy-id -i $HOME/data_lake/system/configs/id_rsa.pub sdeploy@node2
ssh-copy-id -i $HOME/data_lake/system/configs/id_rsa.pub sdeploy@node3

scp configs/id_rsa* sdeploy@node2:/home/sdeploy/data_lake/system/configs
scp configs/id_rsa* sdeploy@node3:/home/sdeploy/data_lake/system/configs

# Make build images
make build