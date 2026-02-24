#!/bin/bash
set -e

echo "== Waiting for PostgreSQL to be ready =="
until pg_isready -h db -p 5432 -U "${POSTGRES_USER:-dashboard_ip}" > /dev/null 2>&1; do
  echo "PostgreSQL is not ready yet... waiting"
  sleep 2
done
echo "== PostgreSQL is ready =="

echo "== Installing gems =="
bundle check || bundle install

echo "== Preparing database =="
bundle exec rails db:prepare

echo "== Building Tailwind CSS =="
bundle exec rails tailwindcss:build

echo "== Removing stale PID file =="
rm -f tmp/pids/server.pid

echo "== Starting Rails server on port 5000 =="
exec bundle exec rails server -b 0.0.0.0 -p 5000
