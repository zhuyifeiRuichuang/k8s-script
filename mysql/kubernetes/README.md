# 说明
在kubernetes环境部署和测试MySQL任意版本(必须是docker hub 有镜像的)。  
yaml配置已将容器内`/var/lib/mysql`配置数据持久化到k8s集群的pvc。  
单实例可以使用deployment类型部署，集群和主从需使用statefulset类型部署，应优先使用MySQL的operator部署。例如`https://dev.mysql.com/doc/relnotes/mysql-operator/en/news-9-5-0-2.2.6.html`
## yaml版本说明
v1, deployment方式部署，可数据持久化。MySQL单实例。mysql:5.7.44
# 快速部署
在k8s集群内快速部署MySQL
```bash
kubectl apply -f mysql.yaml
```
# 访问测试
测试在k8s环境，集群内访问MySQL。
```bash
bash checkInternal.sh
```
## 数据持久化测试
```bash
# 查询pod名字
kubectl get pod -n bigdata2 

# 访问pod
kubectl exec -it -n bigdata2 mysql-55cf49d874-z6sr2 -- bash

# 登录数据库，默认密码root123456
mysql -u root -p 
# 配置测试数据
mysql> CREATE DATABASE IF NOT EXISTS test_persistence;
mysql> USE test_persistence;
mysql> CREATE TABLE IF NOT EXISTS user (id INT PRIMARY KEY, name VARCHAR(20));
mysql> INSERT INTO user (id, name) VALUES (1, "persistence_test");
mysql> SELECT * FROM user;
mysql> exit
bash-4.2# exit

# 删除pod，模拟MySQL被破坏
kubectl delete pod -n bigdata2 mysql-55cf49d874-z6sr2 

# 查询pod，确认pod被deployment自动恢复
kubectl get pod -n bigdata2 

# 访问pod
kubectl exec -it -n bigdata2 mysql-55cf49d874-td2c7 -- bash
# 登录数据库，默认密码root123456
bash-4.2# mysql -u root -p
# 查询数据，若可见数据，则数据持久化测试成功
mysql> USE test_persistence;
mysql> SELECT * FROM user;
mysql> exit
Bye
bash-4.2# exit
exit
```
