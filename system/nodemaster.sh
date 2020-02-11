#!/bin/bash

VERSION=$2

# Bring the services up
function startServices() {
  docker start nodemaster psqlhms hiveserver2
  sleep 5
  echo ">> Starting hdfs ..."
  docker exec -u hadoop -it nodemaster start-dfs.sh
  sleep 5
  echo ">> Starting yarn ..."
  docker exec -u hadoop -d nodemaster start-yarn.sh
  sleep 5
  echo ">> Starting MR-JobHistory Server ..."
  docker exec -u hadoop -d nodemaster mr-jobhistory-daemon.sh start historyserver
  sleep 5
#  echo ">> Starting Spark ..."
#  docker exec -u hadoop -d nodemaster start-master.sh
#  sleep 5
#  echo ">> Starting Spark History Server ..."
#  docker exec -u hadoop nodemaster start-history-server.sh
#  sleep 5
  echo ">> Preparing hdfs for hive ..."
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /user/hive/warehouse
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /user/hive/warehouse
  sleep 5
  echo ">> Starting Hive Metastore ..."
  docker exec -u hadoop -d nodemaster hive --service metastore
  echo "Hadoop info @ nodemaster: http://10.1.1.151:8088/cluster"
  echo "DFS Health @ nodemaster : http://10.1.1.151:50070/dfshealth"
  echo "MR-JobHistory Server @ nodemaster : http://10.1.1.151:19888"
#  echo "Spark info @ nodemaster  : http://10.1.1.151:8080"
#  echo "Spark History Server @ nodemaster : http://10.1.1.151:18080"
}

function stopServices() {
  echo ">> Stopping Spark Master node ..."
  # docker exec -u hadoop -d nodemaster stop-master.sh
  echo ">> Stopping containers ..."
  docker stop nodemaster psqlhms hiveserver2
}

function upServices() {

  # Create custom network
#  docker network inspect hadoopnet > /dev/null 2>&1 || \
#  docker network create --subnet=172.18.0.0/16 hadoopnet

  # Starting Postresql Hive metastore
  echo ">> Starting postgresql hive metastore ..."
  docker run -d --restart always \
                --net host \
                --hostname psqlhms \
                --name psqlhms \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -it postgresql-hms:"${VERSION}"
  sleep 5

  # 3 nodes
  echo ">> Starting nodes master ..."
  docker run -d --restart always \
                --net host \
                --hostname nodemaster \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name nodemaster \
                -v $HOME/.ssh/known_hosts:/home/hadoop/.ssh/known_hosts \
                -it hive:"${VERSION}"

  # Format nodemaster
  echo ">> Formatting hdfs ..."
  docker exec -u hadoop -it nodemaster hdfs namenode -format

  sleep 5

  # Starting Hive Server 2
  echo ">> Starting hive server 2 ..."
  docker run -d --restart always \
                --net host \
                --hostname hiveserver2 \
                --name hiveserver2 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -v hiveserver2_operationlogs:/home/hadoop/hive/operation_logs/ \
                -u hadoop:hadoop \
                -it hive:"${VERSION}" \
                hiveserver2

  sleep 5

}

if [[ $1 = "up" ]]; then
  echo ">> Bring up Hadoop, Hive ..."
  upServices
  startServices
  exit
elif [[ $1 = "down" ]]; then
  stopServices
  docker rm nodemaster hiveserver2 psqlhms
#  docker network rm hadoopnet
  exit
elif [[ $1 = "start" ]]; then
  echo ">> Bring up Spark, Hadoop, Hive ..."
  startServices
  exit
elif [[ $1 = "stop" ]]; then
  echo ">> Stopping up Spark Master and slaves ..."
  stopServices
  exit
elif [[ $1 = "delete" ]]; then
  stopServices
  docker rmi hadoop spark hive -f
#  docker network rm hadoopnet
  docker system prune -f
  exit
else
  echo "Usage: cluster.sh start|stop|down|up|delete VERSION"
  echo "  Required       up  - Bring up existing containers"
  echo "  Required       down  - Bring down existing containers and delete containers"
  echo "  Required       start  - start existing containers"
  echo "  Required       stop   - stop running containers without deleting containers"
  echo "  Required       delete - remove all docker images"
  echo "  Required.      VERSION - VERSION of docker images"
fi