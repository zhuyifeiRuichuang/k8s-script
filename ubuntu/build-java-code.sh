#!/bin/bash

# 基于ubuntu24容器镜像，打包Java代码，可自定义JDK版本，自定义maven版本。需自定义项目目录路径
# ==============================================
# 可自定义变量 - 根据实际情况修改以下参数
# ==============================================
# 本地Java项目目录（aaa）的路径（相对或绝对路径）
LOCAL_PROJECT_DIR="./aaa"
# 本地存放提取的jar文件的目录（相对或绝对路径）
LOCAL_JAR_DEST="./"
# JDK安装包名称（Ubuntu 24.04默认源中的openjdk-21包名）
JDK_PACKAGE="openjdk-21-jdk"
# Maven版本（已固定为3.9.11，如需修改可调整）
MAVEN_VERSION="3.9.11"
# 临时容器名称（已固定为build-java-code）
CONTAINER_NAME="build-java-code"
# ==============================================

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "错误：未安装Docker，请先安装Docker后再运行脚本"
    exit 1
fi

# 检查本地项目目录是否存在
if [ ! -d "$LOCAL_PROJECT_DIR" ]; then
    echo "错误：本地项目目录 $LOCAL_PROJECT_DIR 不存在，请检查路径是否正确"
    exit 1
fi

# 构建Maven下载地址
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# 拉取Ubuntu 24.04镜像
echo "开始拉取ubuntu:24.04镜像..."
if ! docker pull ubuntu:24.04; then
    echo "错误：拉取ubuntu:24.04镜像失败"
    exit 1
fi

# 启动临时容器（后台运行）
echo "启动临时容器 $CONTAINER_NAME..."
if ! docker run -d --name "$CONTAINER_NAME" ubuntu:24.04 sleep infinity; then
    echo "错误：启动容器失败"
    exit 1
fi

# 复制本地项目到容器的/目录
echo "复制本地项目到容器的/目录..."
if ! docker cp "$LOCAL_PROJECT_DIR" "$CONTAINER_NAME:/"; then
    echo "错误：复制项目到容器失败"
    docker stop "$CONTAINER_NAME" &> /dev/null
    docker rm "$CONTAINER_NAME" &> /dev/null
    exit 1
fi

# 在容器内执行环境配置和打包操作
echo "在容器内安装依赖并打包项目..."
docker exec "$CONTAINER_NAME" bash -c "
    # 更新软件源
    apt update -y && \
    # 安装必要工具
    apt install -y wget tar $JDK_PACKAGE && \
    # 下载并安装Maven
    wget -q $MAVEN_URL -O /tmp/maven.tar.gz && \
    tar -zxf /tmp/maven.tar.gz -C /usr/local && \
    ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    export PATH=\$PATH:/usr/local/maven/bin && \
    # 进入项目目录并打包
    cd /aaa && \
    mvn clean package -DskipTests
"

# 检查打包是否成功（查找容器内的jar文件）
echo "查找打包生成的jar文件..."
JAR_FILE=$(docker exec "$CONTAINER_NAME" bash -c "find /aaa -name '*.jar' -path '*/target/*.jar' | head -n 1")
if [ -z "$JAR_FILE" ]; then
    echo "错误：未在容器内找到打包生成的jar文件"
    echo "保留容器 $CONTAINER_NAME 供排查问题，手动删除命令：docker rm -f $CONTAINER_NAME"
    exit 1
fi

# 提取jar文件到本地
echo "提取jar文件到本地 $LOCAL_JAR_DEST..."
JAR_FILENAME=$(basename "$JAR_FILE")
if ! docker cp "$CONTAINER_NAME:$JAR_FILE" "$LOCAL_JAR_DEST/$JAR_FILENAME"; then
    echo "错误：提取jar文件到本地失败"
    echo "保留容器 $CONTAINER_NAME 供排查问题，手动删除命令：docker rm -f $CONTAINER_NAME"
    exit 1
fi

# 验证本地jar文件是否存在
if [ -f "$LOCAL_JAR_DEST/$JAR_FILENAME" ]; then
    echo "成功提取jar文件：$LOCAL_JAR_DEST/$JAR_FILENAME"
else
    echo "错误：本地未找到提取的jar文件"
    echo "保留容器 $CONTAINER_NAME 供排查问题，手动删除命令：docker rm -f $CONTAINER_NAME"
    exit 1
fi

# 清理临时容器
echo "删除临时容器 $CONTAINER_NAME..."
if ! docker rm -f "$CONTAINER_NAME"; then
    echo "警告：删除容器失败，请手动执行命令删除：docker rm -f $CONTAINER_NAME"
    exit 1
fi

echo "所有操作完成！"
