#!/bin/bash
# Runs once on first boot of an empty PostgreSQL data volume (via
# /docker-entrypoint-initdb.d). The official image creates POSTGRES_DB; the test
# database used by `bin/rails db:prepare` in development also needs to exist.
set -e

test_db="${POSTGRES_TEST_DATABASE:-terra_nova_test}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  SELECT format('CREATE DATABASE %I OWNER %I', '${test_db}', '${POSTGRES_USER}')
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${test_db}')\gexec
EOSQL
