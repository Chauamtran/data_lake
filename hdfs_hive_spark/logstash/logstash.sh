#!/bin/bash
# Author: Chau Tran

VERSION='6.8.5'
CONFIG=$1

#UID=$(id -u)
#GID=$(id -g)

function buildServices {
  echo ">> Building logstash images ..."
  docker build  --build-arg CONFIG="${CONFIG}.conf" --build-arg VERSION="${VERSION}" --rm -t logstash_"${CONFIG}":"${VERSION}" -f Dockerfile .
  sleep 5
}

function startServices {
    # 1 node
  echo ">> Starting logstash ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.8 \
              --hostname "${CONFIG}" \
              --name "${CONFIG}" \
              --restart always \
              --link kafka-1:kafka-1 \
              --link kafka-2:kafka-2 \
              --link kafka-3:kafka-3 \
              --link nodemaster:nodemaster \
              -p 5044:5044 \
              logstash_"${CONFIG}":"${VERSION}"

  echo ">> Connecting logstash to hadoops network interface"
  docker network connect hadoopnet "${CONFIG}"

  sleep 5
}

function stopServices {
  echo ">> Stopping logstash containers ..."
  docker stop "${CONFIG}"
}

function deleteServices {
  echo ">> Stopping logstash containers ..."
  docker stop "${CONFIG}"
  echo ">> Deleting logstash containers ..."
  docker rm "${CONFIG}"
}

if [[ $2 = 'start' ]]; then
  echo ">> Start logstash services ..."
  buildServices
  startServices
elif [[ $2 = 'stop' ]]; then
  echo ">> Stop logstash services ..."
  stopServices
elif [[ $2 = 'delete' ]]; then
  echo ">> Delete logstash services ..."
  deleteServices
elif [[ $2 = 'build' ]]; then
  echo ">> Build logstash services ..."
  buildServices
else
  echo "Usage: logstash.sh instance_name start|stop|delete"
  echo "                 start - a logstash instance"
  echo "                 stop - a logstash instance"
  echo "                 delete - a logstash instance"
fi

