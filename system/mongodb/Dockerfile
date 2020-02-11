ARG VERSION=4.2.2
FROM percona/percona-server-mongodb:$VERSION

MAINTAINER Chau.Tran <chauamtran@gmail.com>
USER root

COPY config/mongod.conf /etc/mongod.conf
COPY config/initReplicaSet.js /etc/initReplicaSet.js
# Disable THP
COPY config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
RUN chmod 755 /etc/init.d/disable-transparent-hugepages && \
    /etc/init.d/disable-transparent-hugepages start && \
    chkconfig --add disable-transparent-hugepages

