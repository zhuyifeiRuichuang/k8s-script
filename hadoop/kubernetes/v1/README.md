# 说明
部署记录。初始测试。
## 镜像
容器镜像参考[资料](https://github.com/zhuyifeiRuichuang/work-script/tree/main/hadoop/docker.build)打包定制专用镜像。
点击这里 <a href="https://www.google.com" target="_blank" rel="noopener noreferrer">Google</a> 在新页签打开。

```bash
kubectl create namespace bigdata4
kubectl apply -f hadoop-configmap.yaml
kubectl apply -f hadoop-namenode.yaml
kubectl apply -f hadoop-datanode.yaml
kubectl apply -f hadoop-resourcemanager.yaml
kubectl apply -f hadoop-nodemanager.yaml
```
部署后查询
```bash
root@master Mon Nov 24 [10:05:40] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl get all -n bigdata4 

NAME                    READY   STATUS    RESTARTS      AGE
pod/datanode-0          1/1     Running   0             9m20s
pod/namenode-0          1/1     Running   3 (14m ago)   15m
pod/nodemanager-0       1/1     Running   0             8s
pod/resourcemanager-0   1/1     Running   0             76s

NAME                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
service/datanode          ClusterIP   None         <none>        9864/TCP,9866/TCP            20m
service/namenode          ClusterIP   None         <none>        9870/TCP,9000/TCP,8020/TCP   27m
service/nodemanager       ClusterIP   None         <none>        8042/TCP                     8s
service/resourcemanager   ClusterIP   None         <none>        8088/TCP,8032/TCP            7m9s

NAME                               READY   AGE
statefulset.apps/datanode          1/1     20m
statefulset.apps/namenode          1/1     27m
statefulset.apps/nodemanager       1/1     8s
statefulset.apps/resourcemanager   1/1     76s
root@master Mon Nov 24 [10:05:42] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl get pvc -n bigdata4 
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
hadoop-dn-data-datanode-0   Bound    pvc-1ce19f52-729d-4d2e-8b4a-6c064b5901fe   20Gi       RWO            local          26m
hadoop-nn-data-namenode-0   Bound    pvc-8d162dd9-c732-4337-acd2-01945a9ff929   10Gi       RWO            local          33m
```
