# 说明
在docker环境部署Hadoop任意版本。仅用于测试。  
未配置数据持久化，配置数据卷会导致namenode启动失败。容器停止运行时会自动清空数据。
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
