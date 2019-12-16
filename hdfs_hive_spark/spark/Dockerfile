ARG VERSION=1.0.0
FROM hadoop:$VERSION

MAINTAINER Chau.Tran <chau.tran@paysmart.com.vn>

USER root


# get sources
RUN mkdir /usr/share/scala && \
    wget https://downloads.lightbend.com/scala/2.13.1/scala-2.13.1.tgz -P /tmp/ && \
    tar -xzf /tmp/scala-2.13.1.tgz -C /tmp/ && \
    mv /tmp/scala-2.13.1/* /usr/share/scala/ && \
    rm -rf /tmp/scala-2.13.1 /tmp/scala-2.13.1.tgz && \
    cp /usr/share/scala/bin/* /usr/bin/ && \
    wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-without-hadoop.tgz -P /home/hadoop/ && \
    tar -xzf /home/hadoop/spark-2.4.4-bin-without-hadoop.tgz -C /home/hadoop/ && \
    mv /home/hadoop/spark-2.4.4-bin-without-hadoop /home/hadoop/spark && \
    rm /home/hadoop/spark-2.4.4-bin-without-hadoop.tgz

RUN mkdir -p /home/hadoop/spark/logs && \
    chown hadoop -R /home/hadoop/

# set environment variables
ENV SCALA_HOME /usr/share/scala
ENV SPARK_HOME /home/hadoop/spark
ENV SPARK_LOG_DIR /home/hadoop/spark/logs
ENV PATH $SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

RUN export SPARK_DIST_CLASSPATH=$(hadoop classpath) && \
    mv /home/hadoop/spark/conf/spark-env.sh.template /home/hadoop/spark/conf/spark-env.sh && \
    echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> /home/hadoop/spark/conf/spark-env.sh && \
    echo "export SPARK_LOG_DIR=/home/hadoop/spark/logs" >> /home/hadoop/spark/conf/spark-env.sh && \
    mv /home/hadoop/spark/conf/spark-defaults.conf.template /home/hadoop/spark/conf/spark-defaults.conf && \
    echo "spark.eventLog.dir file:/home/hadoop/spark/logs" >> /home/hadoop/spark/conf/spark-defaults.conf && \
    echo "spark.history.fs.logDirectory file:/home/hadoop/spark/logs" >> /home/hadoop/spark/conf/spark-defaults.conf

ADD configs/workers /home/hadoop/spark/conf/slaves

#USER hadoop