# 说明
在k8s环境部署记录
## 镜像
容器镜像参考[资料](https://github.com/zhuyifeiRuichuang/work-script/tree/main/hadoop/docker.build)打包定制专用镜像。
# 部署
```bash
kubectl create namespace bigdata4
kubectl apply -f hadoop-configmap.yaml
kubectl apply -f hadoop-namenode.yaml
kubectl apply -f hadoop-datanode.yaml
kubectl apply -f hadoop-resourcemanager.yaml
kubectl apply -f hadoop-nodemanager.yaml
```
# 部署后查询
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
# 测试
部署后测试。
## 浏览器访问
<img width="2560" height="1479" alt="image" src="https://github.com/user-attachments/assets/9f70ed80-014a-46fa-b12d-cb3d18da2a41" />

## 数据持久化测试
测试验证数据持久化，数据持久依赖pv，pv在，数据就在。

### namenode
```bash
# 配置测试数据
root@master Mon Nov 24 [10:49:38] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it namenode-0 -n bigdata4 -- /bin/bash
bash-4.2$ hdfs dfs -mkdir -p /test-namenode-persist
bash-4.2$ hdfs dfs -ls /
Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2025-11-24 02:51 /test-namenode-persist
bash-4.2$ exit
exit

# 模拟namenode破坏性故障
root@master Mon Nov 24 [10:55:48] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl delete pod namenode-0 -n bigdata4
pod "namenode-0" deleted

# 等待namenode pod自动恢复后，查询历史数据
root@master Mon Nov 24 [10:57:28] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it namenode-0 -n bigdata4 -- /bin/bash
bash-4.2$ hdfs dfs -ls /
Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2025-11-24 02:51 /test-namenode-persist
bash-4.2$ exit
exit
root@master Mon Nov 24 [10:58:12] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it namenode-0 -n bigdata4 -- ls -l /opt/hadoop/data/nn/current/
total 3108
-rw-r--r-- 1 hadoop hadoop     216 Nov 24 02:56 VERSION
-rw-r--r-- 1 hadoop hadoop      42 Nov 24 01:50 edits_0000000000000000001-0000000000000000002
-rw-r--r-- 1 hadoop hadoop      42 Nov 24 01:50 edits_0000000000000000003-0000000000000000004
-rw-r--r-- 1 hadoop hadoop      42 Nov 24 01:51 edits_0000000000000000005-0000000000000000006
-rw-r--r-- 1 hadoop hadoop 1048576 Nov 24 01:51 edits_0000000000000000007-0000000000000000007
-rw-r--r-- 1 hadoop hadoop 1048576 Nov 24 02:51 edits_0000000000000000008-0000000000000000009
-rw-r--r-- 1 hadoop users  1048576 Nov 24 02:56 edits_inprogress_0000000000000000010
-rw-r--r-- 1 hadoop hadoop     391 Nov 24 01:50 fsimage_0000000000000000000
-rw-r--r-- 1 hadoop hadoop      62 Nov 24 01:50 fsimage_0000000000000000000.md5
-rw-r--r-- 1 hadoop users      479 Nov 24 02:56 fsimage_0000000000000000009
-rw-r--r-- 1 hadoop users       62 Nov 24 02:56 fsimage_0000000000000000009.md5
-rw-r--r-- 1 hadoop users        3 Nov 24 02:56 seen_txid
```
### datanode
```bash
# 配置测试数据
root@master Mon Nov 24 [11:09:09] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it datanode-0 -n bigdata4 -- /bin/bash
.txt-4.2$ echo "这是 Datanode 持久化测试数据" > /tmp/test-datanode-file 
bash-4.2$ hdfs dfs -put /tmp/test-datanode-file.txt /test-namenode-persist/
bash-4.2$ hdfs dfs -ls /test-namenode-persist/
Found 1 items
-rw-r--r--   1 hadoop supergroup         38 2025-11-24 03:10 /test-namenode-persist/test-datanode-file.txt
bash-4.2$ hdfs dfs -cat /test-namenode-persist/test-datanode-file.txt
这是 Datanode 持久化测试数据
bash-4.2$ exit
exit

# 模拟datanode破坏性故障
root@master Mon Nov 24 [11:10:35] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl delete pod datanode-0 -n bigdata4
pod "datanode-0" deleted

# 等待datanode pod自动恢复，查询历史数据
root@master Mon Nov 24 [11:11:41] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it namenode-0 -n bigdata4 -- /bin/bash
bash-4.2$ hdfs dfs -cat /test-namenode-persist/test-datanode-file.txt
这是 Datanode 持久化测试数据
bash-4.2$ hdfs fsck /test-namenode-persist/test-datanode-file.txt -files -blocks
Connecting to namenode via http://namenode-0.namenode.bigdata4:9870/fsck?ugi=hadoop&files=1&blocks=1&path=%2Ftest-namenode-persist%2Ftest-datanode-file.txt
FSCK started by hadoop (auth:SIMPLE) from /10.233.70.10 for path /test-namenode-persist/test-datanode-file.txt at Mon Nov 24 03:12:21 UTC 2025
/test-namenode-persist/test-datanode-file.txt 38 bytes, replicated: replication=1, 1 block(s):  OK
0. BP-461085605-10.233.70.200-1763949032615:blk_1073741825_1001 len=38 Live_repl=1


Status: HEALTHY
 Number of data-nodes:	1
 Number of racks:		1
 Total dirs:			0
 Total symlinks:		0

Replicated Blocks:
 Total size:	38 B
 Total files:	1
 Total blocks (validated):	1 (avg. block size 38 B)
 Minimally replicated blocks:	1 (100.0 %)
 Over-replicated blocks:	0 (0.0 %)
 Under-replicated blocks:	0 (0.0 %)
 Mis-replicated blocks:		0 (0.0 %)
 Default replication factor:	1
 Average block replication:	1.0
 Missing blocks:		0
 Corrupt blocks:		0
 Missing replicas:		0 (0.0 %)

Erasure Coded Block Groups:
 Total size:	0 B
 Total files:	0
 Total block groups (validated):	0
 Minimally erasure-coded block groups:	0
 Over-erasure-coded block groups:	0
 Under-erasure-coded block groups:	0
 Unsatisfactory placement block groups:	0
 Average block group size:	0.0
 Missing block groups:		0
 Corrupt block groups:		0
 Missing internal blocks:	0
FSCK ended at Mon Nov 24 03:12:21 UTC 2025 in 5 milliseconds


The filesystem under path '/test-namenode-persist/test-datanode-file.txt' is HEALTHY
bash-4.2$ exit
exit

root@master Mon Nov 24 [11:12:34] : /opt/bigdata2/hadoop/v3.1.1/v4
# kubectl exec -it datanode-0 -n bigdata4 -- ls -l /opt/hadoop/data/dn/current/
total 8
drwx------ 4 hadoop hadoop 4096 Nov 24 03:11 BP-461085605-10.233.70.200-1763949032615
-rw-r--r-- 1 hadoop hadoop  229 Nov 24 03:11 VERSION
```
