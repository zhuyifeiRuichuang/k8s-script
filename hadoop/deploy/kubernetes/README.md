# 说明
仅供测试使用。Hadoop官网文档和代码仓库已提示，容器化部署存在丢数据和进程管理异常的风险。  
若正式使用，应当拆分yaml文件各资源类型到单独yaml文件，减少资源之间修改配置的影响。自担风险。  
## 版本说明
无数据持久化。  
`hadoop-v1.yaml`,pod方式部署。有故障。   
`hadoop-v2.yaml`,deployment方式部署。有故障。

# 快捷部署
修改`hadoop.yaml`,`namespace bigdata2`应改为全新namespace，避免排错时误删现有资源。  
`nodePort`部分必须配置全集群唯一的端口。
image可改为自己定制的。
后执行部署命令，
```bash
kubectl apply -f hadoop.yaml
```
已配置数据持久化到pvc.

# 查询pod，仅供参考
```bash
root@master Thu Nov 20 [13:48:31] : /opt/bigdata2/hadoop
# kubectl get pod -n bigdata2 -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP              NODE     NOMINATED NODE   READINESS GATES
datanode          1/1     Running   0          18m   10.233.70.69    master   <none>           <none>
namenode          1/1     Running   0          18m   10.233.70.128   master   <none>           <none>
nodemanager       1/1     Running   0          18m   10.233.70.7     master   <none>           <none>
resourcemanager   1/1     Running   0          18m   10.233.70.44    master   <none>           <none>
```

# 查询service ，仅供参考
```bash
root@master Thu Nov 20 [13:48:38] : /opt/bigdata2/hadoop
# kubectl get svc -n bigdata2 
NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                       AGE
datanode          NodePort   10.233.51.111   <none>        9864:30075/TCP,9866:30077/TCP,9867:30876/TCP                  19m
namenode          NodePort   10.233.54.69    <none>        9870:30070/TCP,8020:30071/TCP,9868:30076/TCP                  19m
nodemanager       NodePort   10.233.4.44     <none>        8042:30074/TCP,8040:30078/TCP                                 19m
resourcemanager   NodePort   10.233.61.168   <none>        8088:30072/TCP,8030:30073/TCP,8031:30079/TCP,8032:31273/TCP   19m
```

# 浏览器访问测试 主机IP和映射后的端口
http://10.106.9.87:30070/  
http://10.106.9.87:30072/  
http://10.106.9.87:30074/  
http://10.106.9.87:30075/  
