# 说明
构建容器镜像。参考[hive官方文档](https://github.com/apache/hive/tree/master/packaging/src/docker)  
适配中国地区网络，规避容器内下载软件网络不可达的问题。  
`entrypoint.sh`是hive官方提供。  

## 思路
1. 选择dockerfile。  
2. 准备软件包。  
3. 修改配置文件。在目录conf中，修改配置文件。  
4. 构建容器镜像。  
5. 上传到镜像仓库。
## 查询版本兼容性
查询兼容性，选择适配的版本。  
Hadoop与hive的兼容性查询：[hive官方文档](https://hive.apache.org/general/downloads/)  
hive与tez版本兼容性：暂无  
tez与Hadoop的版本兼容性：[tez官方文档](https://tez.apache.org/install.html)
## 选择Dockerfile
详见目录`Dockerfile`
## 下载软件包
需将下载软件包到当前目录，包含以下：  
Hadoop：[Hadoop版本清单](https://archive.apache.org/dist/hadoop/common/)  
hive：[hive版本清单](https://archive.apache.org/dist/hive/)  
tez：[tez版本清单](https://tez.apache.org/releases/index.html)  
JDBC: 详见目录`JDBC`  
iceberg：详见目录`iceberg`  
## 准备配置文件
根据个人需求，修改目录`conf`中`hive-site.xml`，默认可不改。
## 构建hive镜像
命令格式详见目录`Dockerfile`
## 快速测试镜像
测试镜像可用性。容器状态UP，且容器日志无erro，则是镜像可用，重点关注`hive server2`的日志。
```bash
docker run -d -p 9083:9083 --env SERVICE_NAME=metastore --name metastore-standalone zhuyifeiruichuang/hive:3.1.2
docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 --name hive4 zhuyifeiruichuang/hive:3.1.2
```
若出现类似以下报错，说明镜像构建失败。
```bash
2025-11-26T06:03:40,139  WARN [main] server.HiveServer2: Error starting HiveServer2 on attempt 1, will retry in 60000ms
java.lang.RuntimeException: Error applying authorization policy on hive configuration: class jdk.internal.loader.ClassLoaders$AppClassLoader cannot be cast to class java.net.URLClassLoader (jdk.internal.loader.ClassLoaders$AppClassLoader and java.net.URLClassLoader are in module java.base of loader 'bootstrap')
	at org.apache.hive.service.cli.CLIService.init(CLIService.java:118) ~[hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.CompositeService.init(CompositeService.java:59) ~[hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.server.HiveServer2.init(HiveServer2.java:230) ~[hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.server.HiveServer2.startHiveServer2(HiveServer2.java:1036) [hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.server.HiveServer2.access$1600(HiveServer2.java:140) [hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.server.HiveServer2$StartOptionExecutor.execute(HiveServer2.java:1305) [hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.server.HiveServer2.main(HiveServer2.java:1149) [hive-service-3.1.2.jar:3.1.2]
	at jdk.internal.reflect.DirectMethodHandleAccessor.invoke(Unknown Source) ~[?:?]
	at java.lang.reflect.Method.invoke(Unknown Source) ~[?:?]
	at org.apache.hadoop.util.RunJar.run(RunJar.java:318) [hadoop-common-3.1.1.jar:?]
	at org.apache.hadoop.util.RunJar.main(RunJar.java:232) [hadoop-common-3.1.1.jar:?]
Caused by: java.lang.ClassCastException: class jdk.internal.loader.ClassLoaders$AppClassLoader cannot be cast to class java.net.URLClassLoader (jdk.internal.loader.ClassLoaders$AppClassLoader and java.net.URLClassLoader are in module java.base of loader 'bootstrap')
	at org.apache.hadoop.hive.ql.session.SessionState.<init>(SessionState.java:413) ~[hive-exec-3.1.2.jar:3.1.2]
	at org.apache.hadoop.hive.ql.session.SessionState.<init>(SessionState.java:389) ~[hive-exec-3.1.2.jar:3.1.2]
	at org.apache.hive.service.cli.CLIService.applyAuthorizationConfigPolicy(CLIService.java:128) ~[hive-service-3.1.2.jar:3.1.2]
	at org.apache.hive.service.cli.CLIService.init(CLIService.java:115) ~[hive-service-3.1.2.jar:3.1.2]
	... 10 more

```
