FROM postgres:12.0

MAINTAINER Chau.Tran <chauamtran@gmail.com>

USER root

RUN export LANGUAGE=en_US.UTF-8
ADD configs/hive-schema-2.3.4.postgres.sql /hive/hive-schema-2.3.4.postgres.sql
ADD configs/hive-txn-schema-2.3.4.postgres.sql /hive/hive-txn-schema-2.3.4.postgres.sql

COPY configs/init-hive-db.sh /docker-entrypoint-initdb.d/init-user-db.sh

#USER hadoop
