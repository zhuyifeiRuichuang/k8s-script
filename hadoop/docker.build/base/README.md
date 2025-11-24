# 说明
有安全加固或其他需求的，可自定义基础镜像后，用于Hadoop镜像构建。
# 目录结构

**base**  
 ├─ **scripts**  Hadoop官方脚本  
 └─ **Dockerfile** 不同环境的配置文件  
 └─ **log4j.properties** Hadoop官方配置，使日志暴露，使命令`docker logs`和`kubectl logs`可直接看到日志。  

# 构建基础镜像
参考[Hadoop官方说明](https://apache.github.io/hadoop/hadoop-project-dist/hadoop-common/HadoopDocker.html)  
在本目录进行构建。因[Hadoop官方项目](https://github.com/apache/hadoop/tree/docker-hadoop-runner-latest) 长期未更新Dockerfile，此处做部分改动。请自行对比判断是否要调整。  
请在联网环境构建镜像，推荐美国网络，规避软件下载异常问题。  
## JDK版本选择说明
参考[Hadoop官方说明](https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions)，JDK8支持编译和运行hadoop当前所有版本，Hadoop v3.3及更高版本可使用JDK11运行。
基础镜像默认使用JDK8，若使用JDK11，需编辑Dockerfile修改JDK版本。
## dockerfile说明
ubuntu22是目前最新支持的环境，ubuntu24及更高版本内置软件版本过高。
## 执行构建命令
仅供参考
```bash
docker build -t apache/hadoop-runner -f Dockerfile.centos7 .
docker build -t hadoop-runner:centos7 -f Dockerfile.centos7 .
docker build -t hadoop-runner:ubuntu20 -f Dockerfile.ubuntu20 .
docker build -t hadoop-runner:ubuntu22 -f Dockerfile.ubuntu22 .
````
