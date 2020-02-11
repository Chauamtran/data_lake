#!/bin/bash
# Author: Chau Tran

VERSION='4.2.2'
NAME=$2
function buildServices {
  echo ">> Building mongo images ..."
  docker build --rm -t mongodb_"${NAME}":"${VERSION}" \
               -f Dockerfile \
               --build-arg VERSION="${VERSION}" .
  sleep 5
}

function startServices {
    # 1 node
  echo ">> Starting mongo db ..."
  docker run -d --net host \
              --name mongodb_"${NAME}" \
              --restart always \
              --add-host mongodb_node1:10.1.1.151 \
              --add-host mongodb_node2:10.1.1.152 \
              --add-host mongodb_node3:10.1.1.153 \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -v $HOME/mongo/data:/data/db \
              mongodb_"${NAME}":"${VERSION}" \
              --replSet datalake \
              --config /etc/mongod.conf

  sleep 30
}

function initReplicaSet {
    # Init Replica Set
    docker exec -it mongodb_"${NAME}" mongo localhost:27017 /etc/initReplicaSet.js
}

function stopServices {
  echo ">> Stopping mongo containers ..."
  docker stop mongodb_"${NAME}"
  echo ">> Deleting mongo containers ..."
  docker rm mongodb_"${NAME}"

}

function deleteServices {
  echo ">> Stopping mongo containers ..."
  docker stop mongodb_"${NAME}"
  echo ">> Deleting mongo containers ..."
  docker rm mongodb_"${NAME}"
  echo ">> Deleting mongo images ..."
  docker rmi mongodb_"${NAME}"
}

if [[ $1 = 'up' ]]; then
  echo ">> Bring up mongo services ..."
  buildServices
  startServices
  if [[ $3 = 'rs' ]]; then
      echo ">> Init Replica Set ..."
      initReplicaSet
      sleep 10
  fi
  exit
elif [[ $1 = 'start' ]]; then
  echo ">> Start mongo services"
    startServices
  if [[ $3 = 'rs' ]]; then
      echo ">> Init Replica Set ..."
      initReplicaSet
      sleep 10
  fi
  exit
elif [[ $1 = 'stop' ]]; then
  echo ">> Stop mongo services ..."
  stopServices
  exit
elif [[ $1 = 'down' ]]; then
  echo ">> Delete mongo services ..."
  deleteServices
  exit
else
  echo "Usage: mongo.sh start|stop|up|down name_node replicaSet"
  echo " Required.       name_node - mongo version. Default=4.2.2"
  echo " Required.       start - start logstash instance"
  echo "                 stop - stop logstash instance"
  echo "                 up - Bring up a logstash instance"
  echo "                 down - delete logstash instance"
  echo " Optional.       replicaSet: Enable replicaSet if = 'rs'. Only use for node1"
fi

