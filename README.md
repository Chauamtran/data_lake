# Introduction
**An overview of project**

![](Data_Lake_Architecture.jpg?raw=true) 

This project aims to build a big data project with many popular tools. 
Since this is built by *docker*, you can easily deploy it on many different infrastructures. 
The project also supports to deploy services with a cluster model. 
There is a plan to integrate kubernetes into the project as well.
More details of project about building and explaining will be updated on Medium and Wordpress soon. 
# Requirements
* HDFS in cluster (hadoop-3.2.0) in 3 nodes 
* Kafka in cluster (5.3.1) in 3 nodes
* Zookeeper in cluster (5.3.1) in 3 nodes
* Postgres (12.0) with Hive (apache-hive-2.3.4) 
* Scala (2.13.1)
* Spark (2.4.4) 
* Logstash (6.8.5)
* Airflow (1.10.7)

Note: 
  > - Kafka and zookeeper on a cluster 3 nodes, 
  > - Hadoop, mongodb on a cluster 3 nodes 
  > - Spark, airflow, logstash on a same server (3 nodes for the best) for processing data

# Information  
Folder *system* includes all required services, built by docker    
  * **configs** 
  > - Include all configs of major services
  
  * **hadoop** 
  > - Docker file to build hadoop 
  > - There are three nodes including one nodemaster and two datanodes

  * **docker**
  > - Docker base image for all services

  * **hive** 
  > - Docker file to build hive, based on spark image

  * **postgresql-hms** 
  > - Docker file to build postgres with hive

  * **spark** 
  > - Docker file to build spark 
 
  * **Makefile**
  > - To build docker images of **hadoop, spark, hive, postgresql-hms**
  
  * **build.sh**
  > - Create ssh keys for services and run <em>make build</em> (Makefile)

  * **cluster.sh**
  > - Hadoop cluster info (Ip address config)
  > - Start hadoop clusters including (nodemaster, node2, node3, postgresql-hms)

  * **./kafka_zookeeper/kafka_cluster.sh**
  > - Start kafka cluster (Ip address config)
  > - Include zookeeper cluster info, kafka client info
  
  * **./kafka_zookeeper/zookeeper_cluster.sh**
  > - Start zookeeper cluster (Ip address config)
  > - Include zookeeper cluster config

  * **./logstash/logstash.sh**
  > - Start a logstash instance 

Folder **python** contains python scripts that use to define tasks in airflow and other purposes
  * **airflow**
  > - *dags* to contain dag definitions of airflow
  > - other folders for future in use
  > - airflow.cfg to define configs in airflow. Note to run *airflow upgradedb* after changing in the config
  * **config** 
  > - configs for python scripts
  * **ElasticSearchData**
  > - Some example scripts to get data from ElasticSearch
  * **MongoDbData**
  > - Some example scripts to get data from MongoDB
  * **utils**  
  > - Some libs to connect DB services, cache data
  * **requirements.txt**
  > - File to define necessary python libs
  * **tests**
  > - To run test cases

# Deployment 
  IMPORTANT NOTES: Config Ip address of hadoop, kafka, zookeeper in 
  **cluster.sh, kafka_cluster.sh, zookeeper_cluster.sh**  
  Start hadoop cluster, then zookeeper then kafka last
  
  Add **/etc/hosts** the following lines:
  > - ip_address1 nodemaster psqlhms mongodb_node1
  > - ip_address2 node2 mongodb_node2
  > - ip_address3 node3 mongodb_node3
  > - ip_address4 etl
  > - ip_address5 kafka-1 zk-1
  > - ip_address6 kafka-2 zk-2
  > - ip_address7 kafka-3 zk-3

  Under **system** folder, to build hadoop images
  ```
  1. ./build_nodemaster.sh
  2. ./build_datanode.sh

  ```
    
  Under **system/hadoop** folder:
  * To start hadoop, postgres, hive services
  ```
  ./nodemaster.sh 
  ./node2.sh
  ./node3.sh
  ```

  Under **./system/kafka_zookeeper** folder 
  * To start zookeeper cluster
  ```
  ./zookeeper_1.sh start # To start zookeeper cluster on node 1
  ./zookeeper_2.sh start # To start zookeeper cluster on node 2 
  ./zookeeper_3.sh start # To start zookeeper cluster on node 3  
  ```
  * To start kafka cluster
  ```
  ./kafka_1.sh start # To start kafka cluster on node 1
  ./kafka_2.sh start # To start kafka cluster on node 2
  ./kafka_3.sh start # To start kafka cluster on node 3

  ```
  Under **./system/mongodb** folder 
  ```
  ./mongo.sh up node1 rs # Build and start mongo replicaset with rs option on node 1  
  ./mongo.sh up node2 # Build and start mongo replicaset on node 2
  ./mongo.sh up node3 # Build and start mongo replicaset on node 3
  ```
  Under **./system/logstash** folder, to start a logstash instance (You can integrate with airflow 
  dag to call logstash containers)
  > - ./logstash.sh start instance_name # To start a logstash instance container
  > - ./logstash.sh stop instance_name stop # To stop a logstash instance container
  > - ./logstash.sh up instance_name # To build and run a logstash instance container with its image
  > - ./logstash.sh down instance_name # To delete a logstash instance container with its image
