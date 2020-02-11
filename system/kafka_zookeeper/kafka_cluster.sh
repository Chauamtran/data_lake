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
function upServices {
  # 3 nodes
  echo ">> Starting kafka cluster ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.5 \
              --hostname kafka-1 \
              --name kafka-1 \
              --restart always \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -e KAFKA_BROKER_ID=1 \
              -e KAFKA_NUM_PARTITIONS=10 \
              -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
              -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=3 \
              -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[0]}" \
              confluentinc/cp-kafka:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.6 \
                --hostname kafka-2 \
                --name kafka-2 \
                --restart always \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -e KAFKA_BROKER_ID=2 \
                -e KAFKA_NUM_PARTITIONS=10 \
                -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
                -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=3 \
                -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[1]}" \
                confluentinc/cp-kafka:"${VERSION}"


  docker run -d --net zookeepernet \
                --ip 182.18.1.7 \
                --hostname kafka-3 \
                --name kafka-3 \
                --restart always \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -e KAFKA_BROKER_ID=3 \
                -e KAFKA_NUM_PARTITIONS=10 \
                -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
                -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=3 \
                -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://"${KAFKA_HOST_PORTS[2]}" \
                confluentinc/cp-kafka:"${VERSION}"

  sleep 5
}

function checkServices {
  echo ">> Checking kafka is on ..."
  for i in "${KAFKA_HOST_PORTS[@]}"; do
    HOST="${i%%:*}"
    PORT="${i##*:}"
    docker run --net=zookeepernet \
               --rm confluentinc/cp-kafka:"${VERSION}" bash -c "echo stat | nc "${HOST}" "${PORT}" | grep Mode"
  done
}

function startServices {
  echo ">> Stopping kafka containers ..."
  docker start kafka-1 kafka-2 kafka-3
}

function stopServices {
  echo ">> Stopping kafka containers ..."
  docker stop kafka-1 kafka-2 kafka-3
}

function downServices {
  echo ">> Stopping kafka containers ..."
  docker stop kafka-1 kafka-2 kafka-3
  echo ">> Deleting kafka containers ..."
  docker rm kafka-1 kafka-2 kafka-3
}

if [[ $1 = 'start' ]]; then
  echo ">> Starting kafka services ..."
  startServices
  checkServices
elif [[ $1 = 'stop' ]]; then
  echo ">> Stopping kafka services ..."
  stopServices
elif [[ $1 = 'up' ]]; then
  echo ">> Run kafka services ..."
  upServices
  checkServices
elif [[ $1 = 'down' ]]; then
  echo ">> Down kafka services ..."
  downServices
else
  echo "Usage: kafka_cluster.sh start|stop|up|down"
  echo "                 start - start kafka services"
  echo "                 stop - stop kafka services without deleting containers"
  echo "                 up - run new kafka services"
  echo "                 down - stop kafka services and delete containers"
fi



