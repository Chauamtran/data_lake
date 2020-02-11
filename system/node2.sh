#!/bin/bash

VERSION=$2

# Bring the services up
function startServices() {
  echo ">> Starting node2 ..."
  docker start node2
  sleep 5
#  docker exec -u hadoop -d node2 start-slave.sh nodemaster:7077
#  sleep 5
}

function stopServices() {
  echo ">> Stopping slaves ..."
  # docker exec -u hadoop -d node2 stop-slave.sh
  echo ">> Stopping containers ..."
  docker stop node2
}

function upServices() {

  # Create custom network
#  docker network inspect hadoopnet > /dev/null 2>&1 || \
#  docker network create --subnet=172.18.0.0/16 hadoopnet

  echo ">> Starting node 2 ..."
  docker run -d --restart always \
                --net host \
                --hostname node2 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name node2 \
                -v $HOME/.ssh/known_hosts:/home/hadoop/.ssh/known_hosts \
                -it hadoop:"${VERSION}"

#                --add-host nodemaster:10.1.1.151 \
#                --add-host node2:10.1.1.152 \
#                --add-host node3:10.1.1.153 \

#                --ip 172.18.1.2 \
#                -p 9864:9864 \
#                -p 9865:9865 \
#                -p 9866:9866 \
#                -p 9867:9867 \

  sleep 5

#  docker exec -it nodemaster bash -c "ssh-copy-id -i $HOME/.ssh/id_rsa.pub hadoop@hadoop1"
}

if [[ $1 = "up" ]]; then
  echo ">> Bring up Hadoop ..."
  upServices
  startServices
  exit
elif [[ $1 = "down" ]]; then
  stopServices
  docker rm node2
#  docker network rm hadoopnet
  exit
elif [[ $1 = "start" ]]; then
  echo ">> Bring up Hadoop ..."
  startServices
  exit
elif [[ $1 = "stop" ]]; then
  echo ">> Stopping up Spark Master and slaves ..."
  stopServices
  exit
elif [[ $1 = "delete" ]]; then
  stopServices
#  docker network rm hadoopnet
  docker system prune -f
  exit
else
  echo "Usage: node2.sh start|stop|down|up|delete VERSION"
  echo "  Required       up  - Bring up existing containers"
  echo "  Required       down  - Bring down existing containers and delete containers"
  echo "  Required       start  - start existing containers"
  echo "  Required       stop   - stop running containers without deleting containers"
  echo "  Required       delete - remove all docker images"
  echo "  Required.      VERSION - VERSION of docker images"
fi