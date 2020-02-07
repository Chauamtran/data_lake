#!/bin/bash
# Author: Chau Tran

VERSION='5.3.1'
ZOOKEEPER_HOST_PORTS=( "182.18.1.1:12181"
                         "182.18.1.2:22181"
                         "182.18.1.3:32181" )
ZOOKEEPER_CLIENT_PORTS=(12181 22181 32181)

# Bring the services up
function upServices {

  echo ">> Creating docker network with subnet ..."
  docker network inspect zookeepernet > /dev/null 2>&1 || \
  docker network create --subnet=182.18.0.0/16 zookeepernet # create custom network

  # 3 nodes
  echo ">> Starting zookeeper cluster ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.1 \
              --hostname zk-1 \
              --add-host zk-2:182.18.1.2 \
              --add-host zk-3:182.18.1.3 \
              --name zk-1 \
              --restart always \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -e ZOOKEEPER_SERVER_ID=1 \
              -e ZOOKEEPER_CLIENT_PORT="${ZOOKEEPER_CLIENT_PORTS[0]}" \
              -e ZOOKEEPER_TICK_TIME=2000 \
              -e ZOOKEEPER_INIT_LIMIT=5 \
              -e ZOOKEEPER_SYNC_LIMIT=2 \
              -e ZOOKEEPER_SERVERS="zk-1:12888:13888;zk-2:22888:23888;zk-3:32888:33888" \
              confluentinc/cp-zookeeper:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.2 \
                --hostname zk-2 \
                --add-host zk-1:182.18.1.1 \
                --add-host zk-3:182.18.1.3 \
                --name zk-2 \
                --restart always \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -e ZOOKEEPER_SERVER_ID=2 \
                -e ZOOKEEPER_CLIENT_PORT="${ZOOKEEPER_CLIENT_PORTS[1]}" \
                -e ZOOKEEPER_TICK_TIME=2000 \
                -e ZOOKEEPER_INIT_LIMIT=5 \
                -e ZOOKEEPER_SYNC_LIMIT=2 \
                -e ZOOKEEPER_SERVERS="zk-1:12888:13888;zk-2:22888:23888;zk-3:32888:33888" \
                confluentinc/cp-zookeeper:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.3 \
                --hostname zk-3 \
                --add-host zk-1:182.18.1.1 \
                --add-host zk-2:182.18.1.2 \
                --name zk-3 \
                --restart always \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -e ZOOKEEPER_SERVER_ID=3 \
                -e ZOOKEEPER_CLIENT_PORT="${ZOOKEEPER_CLIENT_PORTS[2]}" \
                -e ZOOKEEPER_TICK_TIME=2000 \
                -e ZOOKEEPER_INIT_LIMIT=5 \
                -e ZOOKEEPER_SYNC_LIMIT=2 \
                -e ZOOKEEPER_SERVERS="zk-1:12888:13888;zk-2:22888:23888;zk-3:32888:33888" \
                confluentinc/cp-zookeeper:"${VERSION}"

  sleep 5
}

function checkServices {
  echo ">> Checking zookeeper is on ..."
  for i in "${ZOOKEEPER_HOST_PORTS[@]}"; do
    HOST="${i%%:*}"
    PORT="${i##*:}"
    docker run --net=zookeepernet \
               --rm confluentinc/cp-zookeeper:"${VERSION}" bash -c "echo stat | nc "${HOST}" "${PORT}" | grep Mode"
  done
}

function startServices {
  echo ">> Starting zookeeper containers ..."
  docker start zk-1 zk-2 zk-3
  checkServices
}

function stopServices {
  echo ">> Stopping zookeeper containers ..."
  docker stop zk-1 zk-2 zk-3
}

function downServices {
  echo ">> Stopping zookeeper containers ..."
  docker stop zk-1 zk-2 zk-3
  echo ">> Deleting zookeeper containers ..."
  docker rm zk-1 zk-2 zk-3
  echo ">> Removing zookeeper network ..."
  docker network rm zookeepernet
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
  echo "Usage: zookeeper_cluster.sh start|stop|up|down. Remember to stop/down kafka before stoppping zookeeper"
  echo "                 start - start zookeeper services"
  echo "                 stop - stop zookeeper services without deleting containers"
  echo "                 up - bring up zookeeper services"
  echo "                 down - bring down zookeeper services and delete containers"
fi


