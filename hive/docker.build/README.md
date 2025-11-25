# 说明
构建容器镜像，可打包任意版本hive。参考[hive官方文档](https://github.com/apache/hive/tree/master/packaging/src/docker)  
## 查询版本兼容性
Hadoop与hive的兼容性查询：[hive官方文档](https://hive.apache.org/general/downloads/)  
hive与tez版本兼容性：暂无  
tez与Hadoop的版本兼容性：[tez官方文档](https://tez.apache.org/install.html)
## 下载软件包
需将下载软件包到当前目录，包含以下：  
Hadoop：[Hadoop版本清单](https://archive.apache.org/dist/hadoop/common/)  
hive：[hive版本清单](https://archive.apache.org/dist/hive/)  
tez：[tez版本清单](https://tez.apache.org/releases/index.html)  
## 准备配置文件
修改目录`conf`中`hive-site.xml`
## 构建hive镜像  
说明：需指定当前目录已有的Hadoop版本，hive版本，tez引擎版本。支持在中国地区网络构建。
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
