#!/bin/bash
# Author: Chau Tran

VERSION='5.3.1'
ZOOKEEPER_HOST_PORTS=( "182.18.1.1:12181"
                         "182.18.1.2:22181"
                         "182.18.1.3:32181" )
ZOOKEEPER_CLIENT_PORTS=(12181 22181 32181)
KAFKA_HOST_PORTS=( "kafka-1:19092"
                   "kafka-2:29092"
                   "kafka-3:39092")

# Bring the services up
function startServices {
  # 3 nodes
  echo ">> Starting kafka cluster ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.5 \
              --hostname kafka-1 \
              --name kafka-1 \
              --restart always \
              -e KAFKA_BROKER_ID=1 \
              -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
              -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[0]}" \
              confluentinc/cp-kafka:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.6 \
                --hostname kafka-2 \
                --name kafka-2 \
                --restart always \
                -e KAFKA_BROKER_ID=2 \
                -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
                -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[1]}" \
                confluentinc/cp-kafka:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.7 \
                --hostname kafka-3 \
                --name kafka-3 \
                --restart always \
                -e KAFKA_BROKER_ID=3 \
                -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
                -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[2]}" \
                confluentinc/cp-kafka:"${VERSION}"

  sleep 5
}

function checkServices {
  echo ">> Checking kafka is on ..."
  for i in "${KAFKA_HOST_PORTS[@]}"; do
    HOST="${i%%:*}"
    PORT="${i##*:}"
    docker logs "${HOST}" | grep "started"
  done
}

function stopServices {
  echo ">> Stopping kafka containers ..."
  docker stop kafka-1 kafka-2 kafka-3
  echo ">> Deleting kafka containers ..."
  docker rm kafka-1 kafka-2 kafka-3
}

# If it is
if [[ $1 = 'start' ]]; then
  echo ">> Starting kafka services ..."
  startServices
  checkServices
  exit
fi

if [[ $1 = 'stop' ]]; then
  stopServices
  exit
fi

echo "Usage: kafka_cluster.sh start|stop"
echo "                 start - kafka services"
echo "                 stop - kafka services"


