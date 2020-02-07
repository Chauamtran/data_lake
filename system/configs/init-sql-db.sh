#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE USER hive WITH PASSWORD 'hive';
  ALTER USER hive WITH SUPERUSER;
  CREATE DATABASE metastore;
  GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
  CREATE USER airflow WITH PASSWORD 'airflow';
  ALTER USER airflow WITH SUPERUSER;
  CREATE DATABASE airflow;
  GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;
  \c metastore
  \i /hive/hive-schema-3.1.2.postgres.sql
  \i /hive/hive-txn-schema-3.1.2.postgres.sql
  \pset tuples_only
  \o /tmp/grant-privs
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "' || schemaname || '"."' || tablename || '" TO hive ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
SELECT 'GRANT SELECT,INSERT,UPDATE,DELETE ON "' || schemaname || '"."' || tablename || '" TO airflow ;'
FROM pg_tables
WHERE tableowner = CURRENT_USER and schemaname = 'public';
  \o
  \i /tmp/grant-privs
EOSQL
