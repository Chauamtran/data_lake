#!/bin/bash
# Author: Chau Tran

VERSION='6.8.5'
FOLDER_CONFIG=$1

printf "Passing %s %s" "${FOLDER_CONFIG}" "${VERSION}"

#UID=$(id -u)
#GID=$(id -g)

function buildServices {
  echo ">> Building logstash images ..."
  docker build --rm -t logstash_"${FOLDER_CONFIG}":"${VERSION}" -f Dockerfile \
               --build-arg FOLDER="${FOLDER_CONFIG}" \
               --build-arg VERSION="${VERSION}" .
  sleep 5
}

function startServices {
    # 1 node
  echo ">> Starting logstash ..."
  docker run -d --net zookeepernet \
              --ip 182.18.1.8 \
              --hostname "${FOLDER_CONFIG}" \
              --name "${FOLDER_CONFIG}" \
              --restart always \
              --link kafka-1:kafka-1 \
              --link kafka-2:kafka-2 \
              --link kafka-3:kafka-3 \
              --link nodemaster:nodemaster \
              -v "${FOLDER_CONFIG}":/usr/share/logstash/"${FOLDER_CONFIG}" \
              -p 5044:5044 \
              logstash_"${FOLDER_CONFIG}":"${VERSION}"

  echo ">> Connecting logstash to hadoops network interface"
  docker network connect hadoopnet "${FOLDER_CONFIG}"

  sleep 5
}

function stopServices {
  echo ">> Stopping logstash containers ..."
  docker stop "${FOLDER_CONFIG}"
}

function deleteServices {
  echo ">> Stopping logstash containers ..."
  docker stop "${FOLDER_CONFIG}"
  echo ">> Deleting logstash containers ..."
  docker rm "${FOLDER_CONFIG}"
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
  echo "                 instance_name - a folder where stores config of logstash instance"
  echo "                 start - start logstash instance"
  echo "                 stop - stop logstash instance"
  echo "                 delete - delete logstash instance"
fi

