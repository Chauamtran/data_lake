# An example to build a big data project (data lake) 
This project aims to help a person to build a big data project with many popular tools. 
Since this is built by *docker*, you can easily deploy it on many different infrastructures. The project also supports to deploy services with a cluster model. 
Also there are a plan to integrate kubernetes into the project.
More details of project about building and explaining will be updated on Medium and Wordpress soon. 
**Services in requirements**
  > - HDFS in cluster (hadoop-3.2.0) in 3 nodes 
  > - Kafka in cluster (5.3.1) in 3 nodes
  > - Zookeeper in cluster (5.3.1) in 3 nodes
  > - Postgres (12.0) with Hive (apache-hive-2.3.4) 
  > - Scala (2.13.1)
  > - Spark (2.4.4) 
  > - Logstash (6.8.5)
  > - Airflow (1.10.7)

TO be recommended: 
  * **Kafka, zookeeper** should be in separate servers (three servers in this project) meanwhile **Scala, Spark, hadoop** are on one server, airflow is on another server to process data
## Notes on major folders/files:
### Folder *system* includes all required services, built by docker    
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

### Steps to deploy services on server: 
  IMPORTANT NOTES: Config Ip address of hadoop, kafka, zookeeper in 
  **cluster.sh, kafka_cluster.sh, zookeeper_cluster.sh**  
  Start hadoop cluster, then zookeeper then kafka last
  
  Under **hdfs_hive_spark** folder, to start hadoop cluster
  > - ./build.sh
  > - ./cluster.sh start version(1.0.0) # To start hadoop cluster with project version, default = 1.0.0
  > - ./cluster.sh stop # To stop hadoop cluster
  
  Under **./hdfs_hive_spark/kafka_zookeeper** folder, to start zookeeper cluster
  > - ./zookeeper_cluster.sh start # To start zookeeper cluster
  > - ./zookeeper_cluster.sh stop # To stop zookeeper cluster 

  Under **./hdfs_hive_spark/kafka_zookeeper** folder, to start kafka cluster
  > - ./kafka_cluster.sh start # To start kafka cluster
  > - ./kafka_cluster.sh start # To stop kafka cluster

  Under **./hdfs_hive_spark/logstash** folder, to start a logstash instance
  > - ./logstash.sh instance_name start # To start a logstash instance
  > - ./logstash.sh instance_name stop # To stop a logstash instance
  > - ./logstash.sh instance_name delete # To delete a logstash instance
