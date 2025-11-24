# 说明
使用docker，基于[Hadoop基础镜像](https://hub.docker.com/r/apache/hadoop-runner)，构建hadoop镜像，可用于Hadoop全量组件部署。  
可对任意版本Hadoop进行镜像构建。Hadoop[版本查询](https://archive.apache.org/dist/hadoop/common/)。  
必须使用系统支持的最新版本docker。  

# 二次开发
无论你对Hadoop代码做任何改动，请将代码打包为`hadoop.tar.gz`文件再用于容器镜像构建。
# 构建基础镜像
默认使用Hadoop官方的`apache/hadoop-runner:latest`,基于centos7，内置JDK8。  
有基础镜像安全更新需求或软件版本更新需求的，可[自定义基础镜像](https://github.com/zhuyifeiRuichuang/work-script/tree/main/hadoop/docker.build/base)。  
# 构建Hadoop镜像
## 软件准备
将需使用的hadoop.tar.gz文件存放到此目录。例如下载[v3.1.1](https://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz)  

## 构建镜像
修改dockerfile里的Hadoop版本号

```bash
docker build -t hadoop:3.1.1 .
```
`log4j.properties`使`kubectl logs`可以直接查看到组件日志。可选。

# 可用镜像清单
以下镜像均使用JDK8。
## 基础镜像
`hadoop-runner:apache`是apache hadoop官方原版的备份。
```bash
ccr.ccs.tencentyun.com/hadoop-dev/hadoop-runner:apache
ccr.ccs.tencentyun.com/hadoop-dev/hadoop-runner:ubuntu20
ccr.ccs.tencentyun.com/hadoop-dev/hadoop-runner:centos7
ccr.ccs.tencentyun.com/hadoop-dev/hadoop-runner:ubuntu22
```
## hadoop 镜像
```bash
ccr.ccs.tencentyun.com/hadoop-dev/hadoop:3.1.1
ccr.ccs.tencentyun.com/hadoop-dev/hadoop:3.4.2
zhuyifeiruichuang/hadoop:3.1.1
```
