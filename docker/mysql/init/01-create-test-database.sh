#!/bin/bash
# Runs once on first boot of an empty MySQL data volume (via
# /docker-entrypoint-initdb.d). The official image creates MYSQL_DATABASE; the
# test database used by `bin/rails db:prepare` in development also needs to
# exist and be usable by the application user.
set -e

test_db="${DB_TEST_DATABASE:-terra_nova_test}"
user="${MYSQL_USER:-root}"

mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS \`${test_db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
  GRANT ALL PRIVILEGES ON \`${test_db}\`.* TO '${user}'@'%';
  FLUSH PRIVILEGES;
EOSQL
