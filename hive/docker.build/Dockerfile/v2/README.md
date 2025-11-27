这是hive官方原本的改造版。构建镜像会残留临时容器和基础镜像。需手动清理环境。本地需配置maven。[官方文档](https://github.com/apache/hive/tree/master/packaging/src/docker)  
构建命令
```bash
./build.sh -hadoop 3.1.1 -tez 0.9.2 -hive 3.1.2
```
