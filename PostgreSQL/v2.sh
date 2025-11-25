#!/bin/bash

# 创建数据卷
docker volume create postgresql-data

# 启动 PostgreSQL
docker run -d \
  --name postgresql \
  --restart=always \
  --privileged=true \
  -p 5432:5432 \
  -e POSTGRES_USER=hive \
  -e POSTGRES_PASSWORD=hive \
  -e POSTGRES_DB=metastore_db \
  -e TZ=Asia/Shanghai \
  -e POSTGRES_INITDB_ARGS="--encoding=UTF8 --lc-collate=C --lc-ctype=C" \
  -e POSTGRES_HOST_AUTH_METHOD=md5 \
  -v postgresql-data:/var/lib/postgresql \
  -v /etc/localtime:/etc/localtime:ro \
  --memory=4g \
  --cpus=2 \
  --health-cmd="pg_isready -U hive -d metastore_db -h localhost" \
  --health-interval=10s \
  --health-timeout=5s \
  --health-retries=3 \
  --health-start-period=30s \
  postgres:18.1 \
  -c max_connections=1000 \
  -c shared_buffers=1GB \
  -c work_mem=32MB \
  -c maintenance_work_mem=256MB \
  -c effective_cache_size=3GB \
  -c checkpoint_completion_target=0.9 \
  -c wal_buffers=16MB \
  -c default_statistics_target=100 \
  -c log_min_messages=warning \
  -c log_rotation_size=100MB \
  -c log_directory=/var/lib/postgresql/18/main/logs \
  -c listen_addresses='*'
