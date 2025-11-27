# 版本说明
| 版本 | 说明 |
|----|----|
| v1 | 基于Ubuntu24的普通版本 |
| v2 | 基于v1,删除内置的Ubuntu用户，添加iceberg支持。 |
# 集成iceberg
参考[官方文档](https://iceberg.apache.org/docs/latest/hive/#feature-support)  
hiv 4开始内置iceberg，使用v1构建。  
低于4版本需单独集成 Iceberg 1.6.1或自己期望使用的版本，使用v2构建。  

# 构建命令案例
构建镜像命令示例，版本自选。
## v1
```bash
docker build \
  --build-arg HADOOP_VERSION=3.1.1 \
  --build-arg HIVE_VERSION=3.1.2 \
  --build-arg TEZ_VERSION=0.9.2 \
  -t zhuyifeiruichuang/hive:3.1.2 .
```

## v2
```bash
docker build \
  --build-arg HADOOP_VERSION=3.1.1 \
  --build-arg HIVE_VERSION=3.1.2 \
  --build-arg TEZ_VERSION=0.9.2 \
  --build-arg ICEBERG_VERSION=1.4.2 \
  -t zhuyifeiruichuang/hive:3.1.2 .
```
注意：若使用此构建方法的镜像，应修改k8s部署文件中配置
```bash
securityContext:
          runAsUser: 1000
```
