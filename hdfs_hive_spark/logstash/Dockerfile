ARG CONFIG=authen_account.conf
ARG VERSION=6.8.5
FROM docker.elastic.co/logstash/logstash:$VERSION

MAINTAINER Chau.Tran <chauamtran@gmail.com>
USER root

RUN rm -f /usr/share/logstash/pipeline/logstash.conf && \
    export LS_JAVA_OPTS="-Xmx2g -Xms1g" && \
    export LS_JAVA_OPTS="-Dls.cgroup.cpuacct.path.override=/ -Dls.cgroup.cpu.path.override=/ $LS_JAVA_OPTS"


COPY ./pipeline/$CONFIG /usr/share/logstash/pipeline/$CONFIG
ADD ./config/logstash.yml /usr/share/logstash/config/logstash.yml
ADD ./config/pipelines.yml /usr/share/logstash/config/pipelines.yml

CMD logstash -f /usr/share/logstash/pipeline/$CONFIG
