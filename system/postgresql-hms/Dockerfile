FROM postgres:12.0

MAINTAINER Chau.Tran <chau.tran@paysmart.com.vn>

USER root

RUN export LANGUAGE=en_US.UTF-8
COPY configs/hive-schema-2.3.6.postgres.sql /hive/hive-schema-2.3.6.postgres.sql
COPY configs/hive-txn-schema-2.3.6.postgres.sql /hive/hive-txn-schema-2.3.6.postgres.sql
COPY configs/init-sql-db.sh /docker-entrypoint-initdb.d/init-user-db.sh

