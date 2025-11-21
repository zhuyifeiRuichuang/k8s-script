# 构建Hadoop镜像
基于Hadoop基础镜像，使用docker构建hadoop容器镜像，可对任意版本Hadoop代码进行打包，构建的镜像可用于部署Hadoop全量组件，基础镜像详见`https://hub.docker.com/r/apache/hadoop-runner`。  
有基础镜像安全更新需求或软件版本更新需求的，可自定义基础镜像，详见目录base。  
提前将需使用的hadoop.tar.gz文件下载到此目录。版本详见`https://archive.apache.org/dist/hadoop/common/`  
例如下载v3.1.1,`https://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz`  
推荐使用最新版本docker在当前目录构建容器镜像，例如
```bash
docker build -t hadoop:3.1.1 .
```
`log4j.properties`使`kubectl logs`可以直接查看到组件日志。非必须。
