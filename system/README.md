# System project
Most components are mostly built using [docker](https://docs.docker.com/). Only [airflow](https://airflow.apache.org/) 
is directly installed on a physical server since airflow needs to call most of operations including docker services. 
It is likely inconvenient to use a docker service and call other docker services internally due to performance problem. 

# Requirements
* Install [docker](https://docs.docker.com/), [make tools](https://en.wikipedia.org/wiki/Make_(software)#Makefile)

# Major folders
* **configs**
  > - Configs of services 
* **docker**
  > - Base docker image 
* **hadoop**
  > - Hadoop docker image   
* **hive**
  > - Hive docker image
  > - Hive Architecture ![](hive/HiveArchitecture.png?raw=true)
  > - Hive Meta Store ![](hive/HiveMetaStore.png?raw=true)
* **kafka_zookeeper**
  > - Docker file and scripts to start the services on each machine
* **logstash**
  > - Configs to transfer data from external source to hadoop
  > - Docker file and scripts to start logstash jobs
  > - Libs to install logstash plugins offline
  > - Logstash flow ![](logstash/LogstashFlows.jpg?raw=true)
* **mongodb**
  > - Configs to mongodb 
  > - Data lake organization between hadoop and mongodb ![](mongodb/DataLakeMongoHdfs.png?raw=true)
* **postgresql-hms**
  > - Meta data of airflow and hive
* **spark** 
  > - Spark framework         
# Usage
1. First, run ``` make build ``` to build docker images of <em>hadoops, hive, postgresql-hms</em>. You can add
more docker images to build in **Makefile**
2. Scripts **build.sh**, **cluster.sh** to build above docker services on a same machines.
These scripts are just for <em>develop</em> environment.
3. Scripts **build_datanode.sh**, **build_nodemaster**, **nodemaster.sh**, **node2.sh**, **node3.sh** to build 
each service on each machine. These scripts are used for <em>product</em> environment.  