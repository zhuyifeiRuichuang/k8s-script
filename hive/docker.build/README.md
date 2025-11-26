# 说明
构建容器镜像。参考[hive官方文档](https://github.com/apache/hive/tree/master/packaging/src/docker)  
适配中国地区网络，规避容器内下载软件网络不可达的问题。  
# Dockerfile版本说明
| 版本 | 说明 |
|----|----|
| v4 | 支持hive 4版本，hive官方原版的离线模式改造。需在构建环境准备maven。 |
| v3 | 支持hive 3及更高版本，对未来新版本预留支持，替换Dockerfile 中JDK版本即可。 |

# 构建镜像
使用`Dockerfile.v4`构建镜像会残留临时容器和基础镜像。需手动清理环境。  
`entrypoint.sh`是hive官方提供。  
## 思路
1. 准备软件包。下载Hadoop，hive，tez软件到当前目录。  下载数据库连接驱动jar文件到目录driver。
2. 修改配置文件。在目录conf中，修改配置文件。  
3. 构建容器镜像。  
4. 上传到镜像仓库。
## 查询版本兼容性
查询兼容性，选择适配的版本。  
Hadoop与hive的兼容性查询：[hive官方文档](https://hive.apache.org/general/downloads/)  
hive与tez版本兼容性：暂无  
tez与Hadoop的版本兼容性：[tez官方文档](https://tez.apache.org/install.html)
## 下载软件包
需将下载软件包到当前目录，包含以下：  
Hadoop：[Hadoop版本清单](https://archive.apache.org/dist/hadoop/common/)  
hive：[hive版本清单](https://archive.apache.org/dist/hive/)  
tez：[tez版本清单](https://tez.apache.org/releases/index.html)  
## 准备配置文件
根据个人需求，修改目录`conf`中`hive-site.xml`，默认可不改。
## 构建hive镜像  
若采用`Dockerfile.v4`，构建命令格式如下所示，
```bash
./build.sh -hadoop 3.1.1 -tez 0.9.2 -hive 3.1.2
```
若采用`Dockerfile.v3`，构建命令格式如下所示，
```bash
docker build \
  --build-arg HADOOP_VERSION=3.1.1 \
  --build-arg HIVE_VERSION=3.1.2 \
  --build-arg TEZ_VERSION=0.9.2 \
  -t hive-dev:3.1.2 .
```

## 快速测试镜像
测试镜像可用性。容器状态UP，且容器日志无erro，则是镜像可用，重点关注`hive server2`的日志。
```bash
docker run -d -p 9083:9083 --env SERVICE_NAME=metastore --name metastore-standalone zhuyifeiruichuang/hive:3.1.2
docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 --name hive4 zhuyifeiruichuang/hive:3.1.2
```
