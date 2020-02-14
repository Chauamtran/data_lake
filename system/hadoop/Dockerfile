ARG VERSION=1.0.0
FROM hdfs-base:$VERSION

MAINTAINER Chau.Tran <chauamtran@gmail.com>

USER root

# OpenJDK installation
RUN apt-get update && \
    apt-get install -y openjdk-8-jre && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    mkdir -p /home/hadoop/.ssh && \
    echo "PubkeyAcceptedKeyTypes +ssh-dss" >> /home/hadoop/.ssh/config && \
    echo "PasswordAuthentication no" >> /home/hadoop/.ssh/config && \
    echo "StrictHostKeyChecking no" >> /home/hadoop/.ssh/config && \
    echo "Port 22000" >> /etc/ssh/sshd_config && \
    echo "PubkeyAcceptedKeyTypes +ssh-dss" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# copy keys
COPY configs/id_rsa.pub /home/hadoop/.ssh/id_rsa.pub
COPY configs/id_rsa /home/hadoop/.ssh/id_rsa
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chown hadoop:hadoop -R /home/hadoop/.ssh && \
    wget http://mirror.downloadvn.com/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz -P /home/hadoop/ && \
    tar -xzf /home/hadoop/hadoop-3.2.1.tar.gz -C /home/hadoop/ && \
    mv /home/hadoop/hadoop-3.2.1 /home/hadoop/hadoop && \
    rm -rf /home/hadoop/hadoop-3.2.1*

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
    echo "export HDFS_SECONDARYNAMENODE_USER=hadoop" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_LOG_DIR=/home/hadoop/hadoop/logs" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HADOOP_SSH_OPTS=\"-p 22000\"" >>  $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_OPTS=\"-XX:+UseParallelGC -Xmx6g\"" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# create folders for nodes
RUN mkdir -p $HADOOP_HOME/data/nameNode \
    $HADOOP_HOME/data/dataNode \
    $HADOOP_HOME/data/nameNodeSecondary \
    $HADOOP_HOME/data/tmp \
    $HADOOP_HOME/logs

COPY configs/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY configs/workers $HADOOP_HOME/etc/hadoop/workers

# permissions
RUN chown hadoop:hadoop -R /home/hadoop/

#USER hadoop

CMD service ssh start && bash
