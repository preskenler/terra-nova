#!/bin/bash
# Runs once on first boot of an empty MySQL data volume (via /docker-entrypoint-initdb.d).
#
# The official image creates MYSQL_DATABASE and grants MYSQL_USER access to it only.
# `bin/rails db:prepare` in development also prepares the test database, so create it
# and grant the application user access here.
set -e

test_db="${MYSQL_TEST_DATABASE:-terra_nova_test}"
app_user="${MYSQL_USER:-rails}"

mysql --protocol=socket -uroot -p"$MYSQL_ROOT_PASSWORD" <<-EOSQL
  CREATE DATABASE IF NOT EXISTS \`${test_db}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  GRANT ALL PRIVILEGES ON \`${test_db}\`.* TO '${app_user}'@'%';
  FLUSH PRIVILEGES;
EOSQL
