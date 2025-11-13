#!/bin/bash
set -euo pipefail  # 严格模式，确保命令失败时脚本终止并捕获错误

# ==============================================
# 可自定义变量
# ==============================================
BASE_IMAGE="ubuntu:24.04"         # 基础镜像
LOCAL_PROJECT_DIR="./kkfile"      # 本地项目目录
JDK_PACKAGE="openjdk-21-jdk"      # JDK包名
MAVEN_VERSION="3.9.11"            # Maven版本
CONTAINER_NAME="build-java-code"  # 临时容器名称
# ==============================================

# 自动计算容器内挂载目录
CONTAINER_PROJECT_DIR="/$(basename "$LOCAL_PROJECT_DIR")"
# 本地target目录路径（用于验证）
LOCAL_TARGET_DIR="${LOCAL_PROJECT_DIR}/target"
# 临时日志文件（存储命令错误信息）
ERROR_LOG=$(mktemp)

# 清理函数：删除临时文件和容器（即使出错也执行）
cleanup() {
    rm -f "$ERROR_LOG"
    if docker inspect "$CONTAINER_NAME" &> /dev/null; then
        docker stop "$CONTAINER_NAME" &> /dev/null
    fi
}
trap cleanup EXIT  # 脚本退出时触发清理


# 步骤1：检查依赖和目录
echo "[1/6] 检查环境依赖..."
if ! command -v docker &> /dev/null; then
    echo "错误：未安装Docker，请先安装Docker"
    exit 1
fi
if [ ! -d "$LOCAL_PROJECT_DIR" ]; then
    echo "错误：本地项目目录 $LOCAL_PROJECT_DIR 不存在"
    exit 1
fi


# 步骤2：拉取基础镜像
echo "[2/6] 拉取基础镜像 $BASE_IMAGE..."
if ! docker pull "$BASE_IMAGE" &> "$ERROR_LOG"; then
    echo "错误：拉取镜像失败"
    echo "详细错误："
    cat "$ERROR_LOG"
    exit 1
fi


# 步骤3：启动容器并挂载目录
echo "[3/6] 启动临时容器并挂载项目目录..."
if ! docker run -d --rm --name "$CONTAINER_NAME" \
    -v "$LOCAL_PROJECT_DIR:$CONTAINER_PROJECT_DIR" \
    "$BASE_IMAGE" sleep infinity &> "$ERROR_LOG"; then
    echo "错误：启动容器失败"
    echo "详细错误："
    cat "$ERROR_LOG"
    exit 1
fi


# 步骤4：在容器内安装依赖和编译
echo "[4/6] 安装依赖并编译项目..."
# 容器内命令：重定向输出到日志，仅保留错误码
if ! docker exec "$CONTAINER_NAME" bash -c "
    export DEBIAN_FRONTEND=noninteractive && \
    apt update -y &> /dev/null && \
    apt install -y --no-install-recommends wget tar $JDK_PACKAGE &> /dev/null && \
    wget -q --timeout=30 https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O /tmp/maven.tar.gz &> /dev/null && \
    tar -zxf /tmp/maven.tar.gz -C /usr/local &> /dev/null && \
    ln -s /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven &> /dev/null && \
    export PATH=\$PATH:/usr/local/maven/bin && \
    cd '$CONTAINER_PROJECT_DIR' && \
    mvn clean package -DskipTests
" &> "$ERROR_LOG"; then
    echo "错误：编译过程失败"
    echo "容器内详细日志："
    docker logs "$CONTAINER_NAME"  # 输出容器内完整操作日志
    exit 1
fi


# 步骤5：验证编译结果
echo "[5/6] 验证编译结果..."
if [ ! -d "$LOCAL_TARGET_DIR" ] || [ -z "$(ls -A "$LOCAL_TARGET_DIR" 2> /dev/null)" ]; then
    echo "错误：本地项目目录中未生成target目录，编译可能未成功"
    exit 1
fi


# 步骤6：清理容器
echo "[6/6] 清理临时容器..."
# 容器会被trap中的cleanup自动删除，此处仅提示


echo "操作完成！编译结果已保存至：$LOCAL_TARGET_DIR"
