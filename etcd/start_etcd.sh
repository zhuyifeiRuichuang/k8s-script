#!/bin/bash
./etcd \
  --data-dir=/data/etcd/ \
  --name=temp-etcd \
  --listen-client-urls=http://127.0.0.1:2389 \
  --advertise-client-urls=http://127.0.0.1:2389 &
  
# 等待启动完成
sleep 3

# 验证启动状态
if ETCDCTL_API=3 ./etcdctl --endpoints=http://127.0.0.1:2389 endpoint health > /dev/null; then
  echo "etcd启动成功"
else
  echo "etcd启动失败"
fi
