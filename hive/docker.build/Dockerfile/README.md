# Dockerfile版本说明
| 版本 | 说明 |
|----|----|
| v1 | 支持hive 3及更高版本，对未来新版本预留支持，替换Dockerfile 中JDK版本即可。 |
| v2 | 支持hive 4版本，hive官方原版的离线模式改造。需在构建环境准备maven。 |

# 构建镜像
使用`Dockerfile.v4`构建镜像会残留临时容器和基础镜像。需手动清理环境。  
`entrypoint.sh`是hive官方提供。  
