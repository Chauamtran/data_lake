#!/bin/bash
# Author: Chau Tran

VERSION='5.3.1'
ZOOKEEPER_HOST_PORTS=( "182.18.1.1:12181"
                         "182.18.1.2:22181"
                         "182.18.1.3:32181" )
ZOOKEEPER_CLIENT_PORTS=(12181 22181 32181)

# Bring the services up
function startServices {
  # 3 nodes
  echo ">> Starting zookeeper cluster ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.1 \
              --hostname zk-1 \
              --add-host zk-2:182.18.1.2 \
              --add-host zk-3:182.18.1.3 \
              --name zk-1 \
              --restart always \
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
    docker run --restart always --net=zookeepernet --rm confluentinc/cp-zookeeper:"${VERSION}" bash -c "echo stat | nc "${HOST}" "${PORT}" | grep Mode"
  done
}

function stopServices {
  echo ">> Stopping zookeeper containers ..."
  docker stop zk-1 zk-2 zk-3
  echo ">> Deleting zookeeper containers ..."
  docker rm zk-1 zk-2 zk-3
  echo ">> Removing zookeeper network ..."
  docker network rm zookeepernet
}

# If it is
if [[ $1 = 'start' ]]; then
  echo ">> Creating docker network with subnet ..."
  docker network create --subnet=182.18.0.0/16 zookeepernet # create custom network
  startServices
  checkServices
  exit
fi

if [[ $1 = 'stop' ]]; then
  stopServices
  exit
fi

echo "Usage: zookeeper_cluster.sh start|stop"
echo "                 start - zookeeper services"
echo "                 stop - zookeeper services"


