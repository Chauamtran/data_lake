# Updates on the project 
## Versions
* **1.0.0**
  * Add a python folder including some python examples 
  * Add airflow component to data flow
  * Create unittest 
  * Refactor deployment scripts to build and run dockers on each computer
* **0.1.0**
  * Create deployments on system by dockers:
    >- Hadoop in 3 nodes including **nodemaster**, **node2**, **node3**
    >- Hive to import and query hdfs data
    >- Kafka, Zookeeper are installed on 3 nodes cluster
    >- Logstash to ship logs from external db to datalake system
    >- Postgres-hms to store metadata of hive and airflow in the future
    >- Spark to run data in a cluster 3 nodes                                                                                                                                                                                             