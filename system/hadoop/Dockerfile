ARG VERSION=1.0.0
FROM hdfs-base:$VERSION

MAINTAINER Chau.Tran <chauamtran@gmail.com>

USER root

# OpenJDK installation
RUN apt-get update && \
    apt-get install -y openjdk-8-jre && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config && \
    mkdir -p /home/hadoop/.ssh && \
    echo "PubkeyAcceptedKeyTypes +ssh-dss" >> /home/hadoop/.ssh/config && \
    echo "PasswordAuthentication no" >> /home/hadoop/.ssh/config


# copy keys
ADD configs/id_rsa.pub /home/hadoop/.ssh/id_rsa.pub
ADD configs/id_rsa /home/hadoop/.ssh/id_rsa
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chown hadoop -R /home/hadoop/.ssh && \
    wget https://archive.apache.org/dist/hadoop/core/hadoop-3.2.0/hadoop-3.2.0.tar.gz -P /home/hadoop/ && \
    tar -xzf /home/hadoop/hadoop-3.2.0.tar.gz -C /home/hadoop/ && \
    mv /home/hadoop/hadoop-3.2.0 /home/hadoop/hadoop && \
    rm -rf /home/hadoop/hadoop-3.2.0*

# set environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME /home/hadoop/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HADOOP_MAPRED_HOME $HADOOP_HOME 
ENV HADOOP_COMMON_HOME $HADOOP_HOME 
ENV HADOOP_HDFS_HOME $HADOOP_HOME 
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV YARN_HOME $HADOOP_HOME
ENV PATH $JAVA_HOME/bin:$PATH
ENV PATH $HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# set hadoop-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_HOME=/home/hadoop/hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_CONF_DIR=/home/hadoop/hadoop/etc/hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# create folders for nodes
RUN mkdir -p /home/hadoop/data/nameNode \
    /home/hadoop/data/dataNode \
    /home/hadoop/data/nameNodeSecondary \
    /home/hadoop/data/tmp \
    /home/hadoop/hadoop/logs

ADD configs/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD configs/workers $HADOOP_HOME/etc/hadoop/workers

# permissions
RUN chown hadoop -R /home/hadoop/

#USER hadoop

CMD service ssh start && bash
