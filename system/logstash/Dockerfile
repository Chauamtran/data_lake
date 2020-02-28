ARG VERSION=6.8.5
FROM docker.elastic.co/logstash/logstash:$VERSION
ARG FOLDER=config

MAINTAINER Chau.Tran <chauamtran@gmail.com>
USER root

RUN rm -f /usr/share/logstash/pipeline/logstash.conf && \
    logstash-plugin install logstash-input-mongodb && \
    export LS_JAVA_OPTS="-Xmx2g -Xms1g" && \
    export LS_JAVA_OPTS="-Dls.cgroup.cpuacct.path.override=/ -Dls.cgroup.cpu.path.override=/ $LS_JAVA_OPTS"

COPY config/$FOLDER/*.conf /usr/share/logstash/pipeline/
COPY config/$FOLDER/logstash.yml /usr/share/logstash/config/logstash.yml
COPY config/$FOLDER/pipelines.yml /usr/share/logstash/config/pipelines.yml

CMD logstash --config.reload.automatic