ARG VERSION=1.0.0
FROM spark:$VERSION

MAINTAINER Chau.Tran <chau.tran@paysmart.com.vn>

USER root

# get sources
RUN apt-get install -y libpostgresql-jdbc-java && \
    wget https://archive.apache.org/dist/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz -P /home/hadoop/ && \
    tar -xzf /home/hadoop/apache-hive-2.3.4-bin.tar.gz -C /home/hadoop/ && \
    mv /home/hadoop/apache-hive-2.3.4-bin /home/hadoop/hive && \
    rm -rf /home/hadoop/apache-hive-2.3.4*

# set environment variables
ENV HIVE_HOME /home/hadoop/hive
ENV PATH $HIVE_HOME/bin:$PATH

ADD configs/hive-site.xml $HIVE_HOME/conf/hive-site.xml
RUN cp /usr/share/java/postgresql-jdbc4.jar /home/hadoop/hive/lib/ && \
    echo "export HADOOP_HOME=/home/hadoop/hadoop" >> /home/hadoop/hive/bin/hive-config.sh && \
    chown hadoop -R /home/hadoop/hive && \
    export LANGUAGE=en_US.UTF-8

