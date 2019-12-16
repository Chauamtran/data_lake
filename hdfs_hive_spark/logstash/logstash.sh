#!/bin/bash
# Author: Chau Tran

VERSION='7.5.0'
CONFIG=$1

#UID=$(id -u)
#GID=$(id -g)

#--build-arg UID="${UID}" --build-arg GID="${GID}"
#--build-arg CONFIG="${CONFIG}" --build-arg VERSION="${VERSION}"

function buildServices {
  echo ">> Building logstash images ..."
  docker build  --build-arg CONFIG="${CONFIG}" --build-arg VERSION="${VERSION}" --rm -t logstash_"${CONFIG}":"${VERSION}" -f Dockerfile .
  sleep 5
}

function startServices {
    # 1 node
  echo ">> Starting logstash ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.8 \
              --hostname logstash-1 \
              --name logstash-1 \
              --restart always \
              --link kafka-1:kafka-1 \
              --link kafka-2:kafka-2 \
              --link kafka-3:kafka-3 \
              --link nodemaster:nodemaster \
              -p 5044:5044 \
              logstash_"${CONFIG}":"${VERSION}"

  echo ">> Connecting logstash to hadoops network interface"
  docker network connect hadoopnet logstash-1

  sleep 5
}

function stopServices {
  echo ">> Stopping logstash containers ..."
  docker stop logstash-1
}

function deleteServices {
  echo ">> Stopping logstash containers ..."
  docker stop logstash-1
  echo ">> Deleting logstash containers ..."
  docker rm logstash-1
}

if [[ $2 = 'start' ]]; then
  echo ">> Start logstash services ..."
  buildServices
  startServices
fi

if [[ $2 = 'stop' ]]; then
  echo ">> Stop logstash services ..."
  stopServices
fi

if [[ $2 = 'delete' ]]; then
  echo ">> Delete logstash services ..."
  deleteServices
fi

if [[ $2 = 'build' ]]; then
  echo ">> Build logstash services ..."
  buildServices
fi