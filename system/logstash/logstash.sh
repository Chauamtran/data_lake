#!/bin/bash
# Author: Chau Tran

VERSION='6.8.5'
FOLDER_CONFIG=$2
DB=$(echo "${FOLDER_CONFIG}" | cut -d'_' -f1)

printf "Passing %s %s" "${FOLDER_CONFIG}" "${VERSION}"

function buildServices {
  echo ">> Building logstash images ..."
  docker build --rm -t logstash_"${FOLDER_CONFIG}":"${VERSION}" \
               -f Dockerfile_"${DB}" \
               --build-arg FOLDER="${FOLDER_CONFIG}" \
               --build-arg VERSION="${VERSION}" .
  sleep 5
}

function startServices {
    # 1 node
  echo ">> Starting logstash ..."
  docker run -d --net host \
              --hostname "${FOLDER_CONFIG}" \
              --name "${FOLDER_CONFIG}" \
              --restart always \
              --log-opt max-size=100m \
              --log-opt max-file=5 \
              -v "${FOLDER_CONFIG}":/usr/share/logstash/"${FOLDER_CONFIG}" \
              logstash_"${FOLDER_CONFIG}":"${VERSION}"

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

if [[ $1 = 'start' ]]; then
  echo ">> Start logstash services ..."
  startServices
  exit
elif [[ $1 = 'stop' ]]; then
  echo ">> Stop logstash services ..."
  stopServices
  exit
elif [[ $1 = 'down' ]]; then
  echo ">> Delete logstash services ..."
  deleteServices
  exit
elif [[ $1 = 'up' ]]; then
  echo ">> Build logstash services ..."
  buildServices
  startServices
  exit
else
  echo "Usage: logstash.sh start|stop|up|down instance_name"
  echo " Required.       instance_name - a folder where stores config of logstash instance"
  echo " Required.       start - start logstash instance"
  echo "                 stop - stop logstash instance"
  echo "                 up - build and run logstash instance"
  echo "                 down - delete logstash instance"

fi

