#!/bin/bash

# 单点登录，maxkey-web-mgt-app前端文件打包专用脚本。

# 定义目录名称和路径
SOURCE_DIR="jnpf-web-tenant-vue3-v6x-v6.0.x-stable"
WORK_DIR="${SOURCE_DIR}/"
DIST_DIR="${WORK_DIR}/dist"
CONTAINER_WORKDIR="/app"

# 检查源目录是否存在
if [ ! -d "${SOURCE_DIR}" ]; then
    echo "错误：当前目录下未找到 ${SOURCE_DIR} 目录"
    exit 1
fi

echo "开始构建前端代码..."

# 使用docker运行临时容器执行构建
docker run --rm -it \
    -v $(pwd):${CONTAINER_WORKDIR} \
    node:20.10.0 \
    /bin/bash -c "
        # 安装pnpm
        echo '安装pnpm...'
        npm install -g pnpm@^9.12
        
        # 进入工作目录
        cd ${CONTAINER_WORKDIR}/${WORK_DIR} || { echo '工作目录不存在'; exit 1; }
        
        # 安装依赖
        echo '安装依赖包...'
        npm install -f
        
        # 执行构建
        echo '开始构建...'
        npm run build
        
        # 检查构建结果
        if [ -d 'dist' ]; then
            echo '构建成功'
        else
            echo '错误：构建失败，未生成dist目录'
            exit 1
        fi
    "

# 检查容器执行是否成功
if [ $? -ne 0 ]; then
    echo "构建过程出错，已终止"
    exit 1
fi

# 将dist目录复制到当前目录
echo "复制dist目录到当前目录..."
cp -r "${DIST_DIR}" ./

# 检查复制结果
if [ -d "dist" ]; then
    echo "操作完成，dist目录已复制到当前目录"
else
    echo "警告：dist目录复制失败"
    exit 1
fi
