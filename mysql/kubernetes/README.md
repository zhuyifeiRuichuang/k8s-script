# 说明
在kubernetes环境部署和测试MySQL任意版本。
# deploy （kubernetes）
用于在k8s环境部署MySQL任意版本非集群架构，当前案例展示mysql:5.7.44，根据需求替换image部分可部署不同版本MySQL。
```bash
kubectl apply -f mysql.yaml
```
# test（kubernetes）
测试在k8s环境，集群内访问MySQL。
```bash
bash checkInternal.sh
```
