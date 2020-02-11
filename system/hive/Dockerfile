ARG VERSION=1.0.0
FROM hadoop:$VERSION

MAINTAINER Chau.Tran <chauamtran@gmail.com>

USER root

# get sources
RUN apt-get install -y libpostgresql-jdbc-java && \
    wget http://mirror.downloadvn.com/apache/hive/hive-2.3.6/apache-hive-2.3.6-bin.tar.gz -P /home/hadoop/ && \
    tar -xzf /home/hadoop/apache-hive-2.3.6-bin.tar.gz -C /home/hadoop/ && \
    mv /home/hadoop/apache-hive-2.3.6-bin /home/hadoop/hive && \
    rm -rf /home/hadoop/apache-hive-2.3.6*

# set environment variables
ENV HIVE_HOME /home/hadoop/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV IMPALA_CLUSTER_LOGS_DIR /home/hadoop/hive/operation_logs

COPY configs/hive-site.xml $HIVE_HOME/conf/hive-site.xml
COPY configs/hive-log4j2.properties $HIVE_HOME/conf/hive-log4j2.properties

RUN cp /usr/share/java/postgresql-jdbc4.jar /home/hadoop/hive/lib/ && \
    echo "export HADOOP_HOME=/home/hadoop/hadoop" >> /home/hadoop/hive/bin/hive-config.sh && \
    mkdir -p $IMPALA_CLUSTER_LOGS_DIR && \
    chown -R hadoop:hadoop /home/hadoop/hive && \
    export LANGUAGE=en_US.UTF-8
