#!/bin/bash

# ==============================================
# 可自定义变量（根据需求修改）
# ==============================================
BASE_IMAGE="ubuntu:24.04"       # 基础镜像
LOCAL_PROJECT_DIR="./file-online-preview-master"
LOCAL_JAR_DEST="./"             # 本地存放jar的目录
JDK_PACKAGE="openjdk-21-jdk"    # JDK安装包名
MAVEN_VERSION="3.9.11"          # Maven版本
CONTAINER_NAME="build-java-code" # 临时容器名称
# ==============================================

# 自动计算容器内的项目目录（与本地项目目录名称一致，例如本地是myproject，容器内就是/myproject）
CONTAINER_PROJECT_DIR="/$(basename "$LOCAL_PROJECT_DIR")"

# 检查Docker是否可用
if ! command -v docker &> /dev/null; then
    echo "错误：未安装Docker，请先安装Docker"
    exit 1
fi

# 检查本地项目目录是否存在
if [ ! -d "$LOCAL_PROJECT_DIR" ]; then
    echo "错误：本地项目目录 $LOCAL_PROJECT_DIR 不存在，请检查路径"
    exit 1
fi

MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# 拉取基础镜像
echo "拉取基础镜像 $BASE_IMAGE..."
if ! docker pull "$BASE_IMAGE"; then
    echo "错误：拉取镜像 $BASE_IMAGE 失败"
    exit 1
fi

# 启动临时容器
echo "启动临时容器 $CONTAINER_NAME..."
if ! docker run -d --rm --name "$CONTAINER_NAME" "$BASE_IMAGE" sleep infinity; then
    echo "错误：启动容器失败"
    exit 1
fi

# 复制本地项目到容器的/目录（容器内目录名与本地一致）
echo "复制本地项目到容器的 $CONTAINER_PROJECT_DIR 目录..."
if ! docker cp "$LOCAL_PROJECT_DIR" "$CONTAINER_NAME:/"; then
    echo "错误：复制项目到容器失败"
    docker stop "$CONTAINER_NAME" &> /dev/null
    exit 1
fi

# 在容器内执行安装和打包（使用自动计算的项目目录）
echo "在容器内安装依赖并打包项目..."
docker exec "$CONTAINER_NAME" bash -c "
    export DEBIAN_FRONTEND=noninteractive && \
    apt update -y -qq && \
    apt install -y -qq --no-install-recommends wget tar $JDK_PACKAGE && \
    wget -q --timeout=30 $MAVEN_URL -O /tmp/maven.tar.gz && \
    tar -zxf /tmp/maven.tar.gz -C /usr/local && \
    ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    export PATH=\$PATH:/usr/local/maven/bin && \
    # 进入容器内的项目目录（使用变量，不再硬编码/aaa）
    cd '$CONTAINER_PROJECT_DIR' && \
    mvn clean package -DskipTests -q
"

# 查找容器内的jar文件（基于自动计算的项目目录）
JAR_FILE=$(docker exec "$CONTAINER_NAME" bash -c "find '$CONTAINER_PROJECT_DIR' -name '*.jar' -path '*/target/*.jar' | head -n 1")
if [ -z "$JAR_FILE" ]; then
    echo "错误：未在容器内找到jar文件"
    docker stop "$CONTAINER_NAME" &> /dev/null
    exit 1
fi

# 提取jar到本地
JAR_FILENAME=$(basename "$JAR_FILE")
if ! docker cp "$CONTAINER_NAME:$JAR_FILE" "$LOCAL_JAR_DEST/$JAR_FILENAME"; then
    echo "错误：提取jar失败"
    docker stop "$CONTAINER_NAME" &> /dev/null
    exit 1
fi

# 验证本地jar
if [ -f "$LOCAL_JAR_DEST/$JAR_FILENAME" ]; then
    echo "成功提取jar：$LOCAL_JAR_DEST/$JAR_FILENAME"
else
    echo "错误：本地未找到jar"
    docker stop "$CONTAINER_NAME" &> /dev/null
    exit 1
fi

# 清理容器
echo "删除临时容器..."
docker stop "$CONTAINER_NAME" &> /dev/null
echo "操作完成！"
