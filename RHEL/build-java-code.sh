#!/bin/bash

# 用于打包Java代码（适配Oracle Linux基础镜像）
# 需自定义代码所在目录、JDK版本、Maven版本，自动打包并将jar存档到当前目录
# 需使用最新版docker，机器需联网

set -euo pipefail  # 严格模式，出错立即退出

# 配置参数（核心修改：JDK镜像改为Oracle Linux基础）
PROJECT_DIR="./sentinel-server"         # 本机代码目录
TEMP_CONTAINER_NAME="temp-sentinel-builder"  # 临时容器名称
MAVEN_VERSION="3.8.6"                    # Maven版本
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
JAR_TARGET_PATH="/app/target"           # 容器内jar路径
LOCAL_JAR_DEST="./"                     # 本地jar存放目录
# 改为基于Oracle Linux 8的OpenJDK 8镜像（官方维护，适配Oracle Linux环境）
JDK_IMAGE="openjdk:8u342-oraclelinux8"  

# 清理临时容器函数（保持不变）
cleanup() {
    if docker ps -aq --filter "name=^/${TEMP_CONTAINER_NAME}$" | grep -q .; then
        echo "删除临时容器[$TEMP_CONTAINER_NAME]..."
        docker rm -f "$TEMP_CONTAINER_NAME" >/dev/null
        echo "临时容器已删除"
    fi
}

# 检查Docker环境（保持不变）
echo "检查Docker是否可用..."
if ! docker info >/dev/null 2>&1; then
    echo "错误：Docker未运行或未安装"
    exit 1
fi

# 检查项目目录（保持不变）
echo "检查项目目录[$PROJECT_DIR]..."
if [ ! -d "$PROJECT_DIR" ]; then
    echo "错误：项目目录[$PROJECT_DIR]不存在"
    exit 1
fi

# 检查pom.xml（保持不变）
echo "检查项目是否包含pom.xml..."
if [ ! -f "${PROJECT_DIR}/pom.xml" ]; then
    echo "错误：${PROJECT_DIR}中未找到pom.xml"
    exit 1
fi

# 提前清理残留容器（保持不变）
echo "清理可能残留的旧容器..."
cleanup

# 创建临时容器并执行打包（核心修改：适配Oracle Linux命令）
echo "创建临时容器并开始打包..."
docker run -i \
    --name "$TEMP_CONTAINER_NAME" \
    -v "$(realpath "$PROJECT_DIR"):/app" \
    --workdir /app \
    "$JDK_IMAGE" \
    /bin/bash -c "
        echo '安装基础工具（适配Oracle Linux）...'
        # Oracle Linux使用yum包管理器，安装wget、tar（无需apt-utils）
        yum install -y wget tar >/dev/null && yum clean all >/dev/null
        
        echo '安装Maven ${MAVEN_VERSION}...'
        wget -q -O /tmp/maven.tar.gz '$MAVEN_URL'
        tar -zxf /tmp/maven.tar.gz -C /usr/local/
        ln -s /usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn
        rm -f /tmp/maven.tar.gz
        
        echo '验证环境...'
        java -version 2>&1 | grep -q '1.8.0_342' || { echo 'JDK版本异常'; exit 1; }
        mvn -v | grep -q 'Apache Maven ${MAVEN_VERSION}' || { echo 'Maven版本异常'; exit 1; }
        
        echo '开始打包...'
        mvn clean package -Dmaven.test.skip=true
        
        echo '检查打包结果...'
        if [ ! -d '$JAR_TARGET_PATH' ]; then
            echo '错误：未生成target目录'
            exit 1
        fi
        JAR_FILE=\$(ls '$JAR_TARGET_PATH'/*.jar | grep -v 'original' | head -n 1)
        if [ -z \"\$JAR_FILE\" ]; then
            echo '错误：未找到jar文件'
            exit 1
        fi
        echo '打包成功：\$JAR_FILE'
        echo \$JAR_FILE > /app/.jar_path.tmp
    " || {
    echo "错误：打包过程失败"
    cleanup  # 打包失败时立即清理容器
    exit 1
}

# 复制jar到本地（保持不变）
echo "开始复制jar文件到本地..."
JAR_CONTAINER_PATH=$(cat "${PROJECT_DIR}/.jar_path.tmp")
rm -f "${PROJECT_DIR}/.jar_path.tmp"  # 清理临时文件

# 执行复制操作
docker cp "${TEMP_CONTAINER_NAME}:${JAR_CONTAINER_PATH}" "${LOCAL_JAR_DEST}" || {
    echo "错误：jar文件复制失败"
    cleanup  # 复制失败时清理容器
    exit 1
}

# 验证复制结果（保持不变）
LOCAL_JAR_NAME=$(basename "$JAR_CONTAINER_PATH")
if [ -f "${LOCAL_JAR_DEST}/${LOCAL_JAR_NAME}" ]; then
    echo "成功：jar文件已复制到本地 -> ${LOCAL_JAR_NAME}"
else
    echo "错误：本地未找到复制的jar文件"
    cleanup  # 验证失败时清理容器
    exit 1
fi

# 所有操作完成后，自动删除临时容器（保持不变）
cleanup

echo "所有流程完成"
