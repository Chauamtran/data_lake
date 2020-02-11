#!/bin/bash
# Author: Chau Tran

VERSION='5.4.0'

# Bring the services up
function upServices {

  # 1 node
  echo ">> Starting zookeeper cluster ..."
  docker run -d --net host \
              --hostname zk-3 \
              --add-host zk-1:10.1.1.155 \
              --add-host zk-2:10.1.1.156 \
              --add-host zk-3:10.1.1.157 \
              --name zk-3 \
              --restart always \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -e ZOOKEEPER_SERVER_ID=3 \
              -e ZOOKEEPER_CLIENT_PORT=32181 \
              -e ZOOKEEPER_TICK_TIME=2000 \
              -e ZOOKEEPER_INIT_LIMIT=5 \
              -e ZOOKEEPER_SYNC_LIMIT=2 \
              -e ZOOKEEPER_SERVERS="zk-1:2888:3888;zk-2:2888:3888;zk-3:2888:3888" \
              -e ZOOKEEPER_DATA_DIR=/var/zookeeper \
              -v $HOME/zookeeper/data:/var/zookeeper \
              confluentinc/cp-zookeeper:"${VERSION}"

  sleep 5
}

function checkServices {
  echo ">> Checking zookeeper is on ..."
  docker run --net=host \
             --rm confluentinc/cp-zookeeper:"${VERSION}" \
             bash -c "echo stat | nc localhost 2181 | grep Mode"

}

function startServices {
  echo ">> Starting zookeeper containers ..."
  docker start zk-3
}

function stopServices {
  echo ">> Stopping zookeeper containers ..."
  docker stop zk-3
}

function downServices {
  echo ">> Stopping zookeeper containers ..."
  docker stop zk-3
  echo ">> Deleting zookeeper containers ..."
  docker rm zk-3
}

if [[ $1 = 'start' ]]; then
  echo ">> Starting zookeeper containers ..."
  startServices
  checkServices
elif [[ $1 = 'stop' ]]; then
  echo ">> Stopping zookeeper containers ..."
  stopServices
elif [[ $1 = 'up' ]]; then
  echo ">> Bring up zookeeper services ..."
  upServices
  checkServices
elif [[ $1 = 'down' ]]; then
  echo ">> Bring down zookeeper services ..."
  downServices
else
  echo "Usage: zookeeper_3.sh start|stop|up|down. Remember to stop/down kafka before stoppping zookeeper"
  echo "                 start - start zookeeper services"
  echo "                 stop - stop zookeeper services without deleting containers"
  echo "                 up - bring up zookeeper services"
  echo "                 down - bring down zookeeper services and delete containers"
fi

