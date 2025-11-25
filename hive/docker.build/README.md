# 说明
构建容器镜像，可打包任意版本hive。参考[hive官方文档](https://github.com/apache/hive/tree/master/packaging/src/docker)  
# 构建镜像
构建后，不会自动清理环境，会残留容器和基础镜像。需自己手动管理。  
## 思路
准备软件包。  
修改配置文件。  
构建容器镜像。  
上传到镜像仓库。
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
说明：版本只能填写当前目录已有的软件包版本。支持在中国地区网络构建。命令格式如下所示，
```bash
./build.sh -hadoop 3.1.1 -tez 0.9.2 -hive 3.1.2
```
## 查询构建结果
```bash
root@VM-8-10-ubuntu Tue Nov 25 [14:01:40] : ~
# docker images
                                                                                                                                         i Info →   U  In Use
IMAGE                           ID             DISK USAGE   CONTENT SIZE   EXTRA
apache/hive:3.1.2               06826a28c2bd       1.13GB             0B    U   
moby/buildkit:buildx-stable-1   fe0990fb85c4        227MB             0B    U   
```
