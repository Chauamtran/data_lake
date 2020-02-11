#!/bin/bash

VERSION=$2

# Bring the services up
function startServices() {
  docker start nodemaster node2 node3 psqlhms hiveserver2
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
  echo ">> Starting Spark ..."
  docker exec -u hadoop -d nodemaster start-master.sh
  docker exec -u hadoop -d node2 start-slave.sh nodemaster:7077
  docker exec -u hadoop -d node3 start-slave.sh nodemaster:7077
  sleep 5
  echo ">> Starting Spark History Server ..."
  docker exec -u hadoop nodemaster start-history-server.sh
  sleep 5
  echo ">> Preparing hdfs for hive ..."
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -mkdir -p /user/hive/warehouse
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /tmp
  docker exec -u hadoop -it nodemaster hdfs dfs -chmod g+w /user/hive/warehouse
  sleep 5
  echo ">> Starting Hive Metastore ..."
  docker exec -u hadoop -d nodemaster hive --service metastore
  echo "Hadoop info @ nodemaster: http://172.18.1.1:8088/cluster"
  echo "DFS Health @ nodemaster : http://172.18.1.1:50070/dfshealth"
  echo "MR-JobHistory Server @ nodemaster : http://172.18.1.1:19888"
  echo "Spark info @ nodemaster  : http://172.18.1.1:8080"
  echo "Spark History Server @ nodemaster : http://172.18.1.1:18080"
}

function stopServices() {
  echo ">> Stopping Spark Master and slaves ..."
  docker exec -u hadoop -d nodemaster stop-master.sh
  docker exec -u hadoop -d node2 stop-slave.sh
  docker exec -u hadoop -d node3 stop-slave.sh
  echo ">> Stopping containers ..."
  docker stop nodemaster node2 node3 psqlhms hiveserver2
}

function upServices() {

  # Create custom network
  docker network inspect hadoopnet > /dev/null 2>&1 || \
  docker network create --subnet=172.18.0.0/16 hadoopnet

  # Starting Postresql Hive metastore
  echo ">> Starting postgresql hive metastore ..."
  docker run -d --restart always \
                --net hadoopnet \
                --ip 172.18.1.4 \
                --hostname psqlhms \
                --name psqlhms \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -p 5432:5432 \
                -it postgresql-hms:"${VERSION}"
  sleep 5

  # 3 nodes
  echo ">> Starting nodes master and worker nodes ..."
  docker run -d --restart always \
                --net hadoopnet \
                --ip 172.18.1.1 \
                --hostname nodemaster \
                --add-host node2:172.18.1.2 \
                --add-host node3:172.18.1.3 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name nodemaster \
                -it hive:"${VERSION}"

  docker run -d --restart always \
                --net hadoopnet \
                --ip 172.18.1.2 \
                --hostname node2 \
                --add-host nodemaster:172.18.1.1 \
                --add-host node3:172.18.1.3 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name node2 \
                -it spark:"${VERSION}"

  docker run -d --restart always \
                --net hadoopnet \
                --ip 172.18.1.3 \
                --hostname node3 \
                --add-host nodemaster:172.18.1.1 \
                --add-host node2:172.18.1.2 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                --name node3 \
                -it spark:"${VERSION}"

  # Format nodemaster
  echo ">> Formatting hdfs ..."
  docker exec -u hadoop -it nodemaster hdfs namenode -format

  sleep 5

  # Starting Hive Server 2
  echo ">> Starting hive server 2 ..."
  docker run -d --restart always \
                --net hadoopnet \
                --ip 172.18.1.5 \
                --hostname hiveserver2 \
                --name hiveserver2 \
                --log-opt max-size=100m \
                --log-opt max-file=5 \
                -p 10002:10002 \
                -v hiveserver2_operationlogs:/home/hadoop/hive/operation_logs/ \
                -u hadoop:hadoop \
                -it hive:"${VERSION}" \
                hiveserver2

}

if [[ $1 = "up" ]]; then
  echo ">> Bring up Spark, Hadoop, Hive ..."
  upServices
  startServices
  exit
elif [[ $1 = "down" ]]; then
  stopServices
  docker rm nodemaster node2 node3 hiveserver2 psqlhms
  docker network rm hadoopnet
  exit
elif [[ $1 = "start" ]]; then
  echo ">> Starting Spark, Hadoop, Hive ..."
  startServices
  exit
elif [[ $1 = "stop" ]]; then
  echo ">> Stopping up Spark Master and slaves ..."
  stopServices
  exit
elif [[ $1 = "delete" ]]; then
  stopServices
  docker rmi hadoop spark hive -f
  docker network rm hadoopnet
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