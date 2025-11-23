# 说明
docker环境用到的资源
在docker环境部署Hadoop任意版本。仅用于测试。  

# yaml版本说明
| 版本 | 说明 |
|----|----|
| v1 | Hadoop原版，数据不持久 |
| v2 | namenode和datanode数据持久化存储到数据卷 |

# 使用说明
在文件`.env`指定hadoop的版本。会影响docker compose build制作的镜像。  
先构建容器镜像，后启动容器。  
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

# 临时启动Hadoop
```bash
docker compose up -d
```

# 启动Hadoop集群，并启动3个数据节点
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

# compose-v2说明
若使用此yaml，需先做环境初始化。  
```bash
# 在当前目录操作
# 创建目录
mkdir -p data/namenode
mkdir -p data/datanode

# 放宽权限（或者你可以将所有者改为容器内的 hadoop 用户 ID，通常是 1000）
chmod 777 data/namenode
chmod 777 data/datanode

# 格式化 NameNode 并将其元数据写入 namenode_data 卷
docker compose run --rm namenode hdfs namenode -format
```

# 数据持久化测试
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
测试失败，数据会随机丢失。
