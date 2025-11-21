# 构建基础镜像
若不想用apache官网提供的镜像，可自己构建基础镜像。  
参考`https://apache.github.io/hadoop/hadoop-project-dist/hadoop-common/HadoopDocker.html`  
在本目录进行构建。因原项目`https://github.com/apache/hadoop/tree/docker-hadoop-runner-latest`长期未更新，此处做部分改动。请自行对比判断是否要调整。  
请在联网环境构建镜像，推荐美国网络。  
## JDK版本选择说明
参考，`https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions`，JDK8支持编译和运行hadoop当前所有版本，Hadoop v3.3及更高版本可使用JDK11运行。
基础镜像默认使用JDK8，若使用JDK11，需编辑Dockerfile修改JDK版本。

## 执行构建命令，仅供参考
```bash
docker build -t apache/hadoop-runner -f Dockerfile.centos7 .
docker build -t hadoop-runner:centos7 -f Dockerfile.centos7 .
docker build -t hadoop-runner:ubuntu20 -f Dockerfile.ubuntu20 .
docker build -t hadoop-runner:ubuntu22 -f Dockerfile.ubuntu22 .
````
