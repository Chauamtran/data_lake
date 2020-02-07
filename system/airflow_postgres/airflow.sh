#!/bin/bash

# generate ssh key
#GRID="$(id -g)"
#USRID="$(id -u)"



if [[ $# -eq 1 && $1 = "start" ]]; then
  docker-compose start --no-build
  exit 1
elif [[ $# -eq 1 && $1 = "stop" ]]; then
  docker-compose stop --no-build
  exit 1
elif [[ $# -eq 1 && $1 = "up" ]]; then
  # Make build images
  docker-compose build --build-arg GID="$(id -g)" --build-arg UID="$(id -u)"
  docker-compose up --no-build
  exit 1
elif [[ $# -eq 1 && $1 = "down" ]]; then
  docker-compose down --no-build
  exit 1
elif [[ $# -eq 2 && $1 = "start" ]]; then
  docker-compose start $2 --no-build
  exit 1
elif [[ $# -eq 2 && $1 = "stop" ]]; then
  docker-compose stop $2 --no-build
  exit 1
elif [[ $# -eq 2 && $1 = "up" ]]; then
  # Make build images
  docker-compose build --build-arg GID="$(id -g)" --build-arg UID="$(id -u)"
  docker-compose up $2 --no-build
  exit 1
elif [[ $# -eq 2 && $1 = "down" ]]; then
  docker-compose down $2 --no-build
  exit 1
else
  echo "Usage: airflow.sh start|stop|down|up|delete service"
  echo "  Required       up  - Bring up existing containers"
  echo "  Required       down  - Bring down existing containers and delete containers"
  echo "  Required       start  - start existing containers"
  echo "  Required       stop   - stop running containers without deleting containers"
  echo "  Required       delete - remove all docker images"
  echo "  Optional.      service - Name of service"
fi
