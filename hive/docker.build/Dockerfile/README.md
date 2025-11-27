# Dockerfile版本说明
注意：均需提前下载软件到本地目录，脚本不提供联网下载软件。
| 版本 | 说明 |
|----|----|
| v1 | 支持hive 3及更高版本，对未来新版本预留支持，替换Dockerfile 中JDK版本即可。 |
| v2 | 支持hive 4版本，hive官方原版的离线模式改造。需在构建环境准备maven。 |
# 使用方法
将需要使用的Dockerfile文件复制到上级目录，命名为Dockerfile  
