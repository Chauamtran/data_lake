#!/bin/bash

VERSION=$2

# Bring the services up
function startServices() {
  echo ">> Starting node 3 ..."
  docker start node3
  sleep 5
#  docker exec -u hadoop -d node3 start-slave.sh nodemaster:7077
#  sleep 5
#  echo ">> Starting Spark History Server ..."
#  docker exec -u hadoop nodemaster start-history-server.sh
#  sleep 5
}

function stopServices() {
  echo ">> Stopping Spark node 3 ..."
  # docker exec -u hadoop -d node3 stop-slave.sh
  echo ">> Stopping containers ..."
  docker stop node3
}

function upServices() {

  # Create custom network
#  docker network inspect hadoopnet > /dev/null 2>&1 || \
#  docker network create --subnet=172.18.0.0/16 hadoopnet

  echo ">> Starting nodes 3 ..."

  docker run -d --restart always \
                --net host \
                --hostname node3 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name node3 \
                -v $HOME/.ssh/known_hosts:/home/hadoop/.ssh/known_hosts \
                -it hadoop:"${VERSION}"

#                --add-host nodemaster:10.1.1.151 \
#                --add-host node2:10.1.1.152 \
#                --add-host node3:10.1.1.153 \

  sleep 5

}

if [[ $1 = "up" ]]; then
  echo ">> Bring up Spark, Hadoop, Hive ..."
  upServices
  startServices
  exit
elif [[ $1 = "down" ]]; then
  stopServices
  docker rm node3
#  docker network rm hadoopnet
  exit
elif [[ $1 = "start" ]]; then
  echo ">> Bring up Spark, Hadoop, Hive ..."
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
  echo "Usage: node3.sh start|stop|down|up|delete VERSION"
  echo "  Required       up  - Bring up existing containers"
  echo "  Required       down  - Bring down existing containers and delete containers"
  echo "  Required       start  - start existing containers"
  echo "  Required       stop   - stop running containers without deleting containers"
  echo "  Required       delete - remove all docker images"
  echo "  Required.      VERSION - VERSION of docker images"
fi