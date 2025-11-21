# 说明
在docker环境部署Hadoop任意版本。仅用于测试。
# 使用说明
在文件`.env`指定hadoop的版本。会影响docker compose build制作的镜像。

# 构建Hadoop指定版本容器镜像
```bash
docker build -t hadoop:3.1.1 .
```

# 分组件构建容器镜像
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
