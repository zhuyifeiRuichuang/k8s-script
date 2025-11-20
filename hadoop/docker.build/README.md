使用docker构建hadoop容器镜像，可对任意版本Hadoop代码进行打包，提前将需使用的tar.gz文件下载到此目录。版本详见`https://archive.apache.org/dist/hadoop/common/`  
例如下载v3.1.1,`https://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz`  
推荐使用最新版本docker在当前目录构建容器镜像，例如
```bash
docker build -t apache/hadoop:3.1.1 .
```
