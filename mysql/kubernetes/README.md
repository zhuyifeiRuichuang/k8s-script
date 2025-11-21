# 说明
在kubernetes环境部署和测试MySQL任意版本。配置已将容器内`/var/lib/mysql`配置数据持久化到k8s集群的pvc.用于在k8s环境部署MySQL任意版本非集群架构，当前案例展示mysql:5.7.44，根据需求替换image部分可部署不同版本MySQL。  
## yaml版本说明
v1, deployment方式部署，可数据持久化。
# deploy （kubernetes）
```bash
kubectl apply -f mysql.yaml
```
# test（kubernetes）
测试在k8s环境，集群内访问MySQL。
```bash
bash checkInternal.sh
```
## 数据持久化测试
