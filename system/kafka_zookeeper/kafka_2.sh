#!/bin/bash
# Author: Chau Tran

VERSION='5.4.0'

# Bring the services up
function upServices {
  # 1 nodes
  echo ">> Starting kafka cluster ..."
  docker run -d --net host \
              --hostname kafka-2 \
              --name kafka-2 \
              --add-host kafka-1:10.1.1.155 \
              --add-host kafka-2:10.1.1.156 \
              --add-host kafka-3:10.1.1.157 \
              --add-host zk-1:10.1.1.155 \
              --add-host zk-2:10.1.1.156 \
              --add-host zk-3:10.1.1.157 \
              --restart always \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -e KAFKA_BROKER_ID=2 \
              -e KAFKA_NUM_PARTITIONS=10 \
              -e KAFKA_ZOOKEEPER_CONNECT=zk-1:12181,zk-2:22181,zk-3:32181 \
              -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=2 \
              -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka-2:29092 \
              -v $HOME/kafka/data:/var/lib/kafka/data \
              confluentinc/cp-kafka:"${VERSION}"

  sleep 5
}

function checkServices {
  echo ">> Checking kafka is on ..."
  docker run --net=host \
             --rm confluentinc/cp-kafka:"${VERSION}" bash -c "echo stat | nc kafka-2 29092 | grep Mode"
}

function startServices {
  echo ">> Stopping kafka containers ..."
  docker start kafka-2
}

function stopServices {
  echo ">> Stopping kafka containers ..."
  docker stop kafka-2
}

function downServices {
  echo ">> Stopping kafka containers ..."
  docker stop kafka-2
  echo ">> Deleting kafka containers ..."
  docker rm kafka-2
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
  echo "Usage: kafka_2.sh start|stop|up|down. Remember to start zookeeper before starting kafka"
  echo "                 start - start kafka services"
  echo "                 stop - stop kafka services without deleting containers"
  echo "                 up - run new kafka services"
  echo "                 down - stop kafka services and delete containers"
fi



