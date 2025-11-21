# 说明
在不同环境部署MySQL。

# deploy （kubernetes）
用于在k8s环境部署MySQL任意版本非集群架构，当前案例展示mysql:5.7.44，根据需求替换image部分即可。
```bash
kubectl apply -f mysql.yaml
```
# test（kubernetes）
测试在k8s环境，集群内访问MySQL。
```bash
bash checkInternal.sh
```
