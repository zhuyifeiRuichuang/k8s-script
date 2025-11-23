# 说明
docker环境用到的资源
在docker环境部署Hadoop任意版本。仅用于测试。  
## 数据持久化
数据持久化通过数据卷挂载容器指定目录方式实现。  
重建容器后，docker自动将数据卷挂载回容器指定目录，重新读取原数据。  
所有数据都必须存放在容器的/opt/hadoop下指定的目录中，容器内置的hadoop用户在其他目录无权限。

# yaml版本说明
| 版本 | 说明 |
|----|----|
| v1 | Hadoop原版，数据不持久 |
| v2 | namenode和datanode数据持久化存储到数据卷，无法多datanode，会数据混乱。 |

# 使用说明
可先构建容器镜像，后启动容器。也可以使用已有容器镜像。
将版本目录下文件复制到其上级目录。例如使用v1目录内，则应在v1目录下执行命令`cp * ..`

# 构建容器镜像
在文件`.env`指定hadoop的版本。会影响docker compose build制作的镜像。  
先下载需使用的hadoop版本软件到此目录，版本清单`https://archive.apache.org/dist/hadoop/common/`  
例如`https://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz`

# 构建Hadoop指定版本容器镜像
先修改`Dockerfile`的Hadoop版本号。
```bash
docker build -t hadoop:3.1.1 .
```

# 分组件构建容器镜像
先修改`.env`中Hadoop的版本号。
```bash
docker compose build
```

# 启动Hadoop
```bash
docker compose up -d
```

# 启动Hadoop，且启动3个数据节点
```bash
docker compose up -d --scale datanode=3
```

# 查询Hadoop集群状态
```bash
docker compose ps -a
```

# 清空测试环境，保留持久化数据
```bash
docker compose down
```
# 完整清空测试环境所有数据
```bash
docker compose down -v
```


# 数据持久化测试
支持数据持久化的版本
v2

## 测试namenode
```bash
# 1. 进入 NameNode 容器
docker exec -it hadoop-docker-namenode-1 bash

# 2. 在 HDFS 中创建测试目录
hdfs dfs -mkdir /test_persistence

# 3. 创建一个包含时间戳的测试文件，写入 HDFS
echo "This is a test file created at $(date)" > /tmp/test_file.txt
hdfs dfs -put /tmp/test_file.txt /test_persistence/namenode_test.txt

# 4. 退出容器
exit

# 5. 使用 down/up 重建 Namenode 服务
# 注意：这里只操作 Namenode
docker compose stop namenode
docker compose rm -f namenode

# 6. 重新启动集群（这会重建并启动 Namenode）
docker compose up -d namenode

# 7. 进入 NameNode 容器
docker exec -it hadoop-docker-namenode-1 bash

# 8. 尝试列出并查看刚才创建的文件
hdfs dfs -ls /test_persistence
hdfs dfs -cat /test_persistence/namenode_test.txt

# 9. 退出容器
exit
```

## 测试datanode
待更新
