#!/bin/bash

# 定义基础配置
BASE_DIR="/data/export_etcd"
ETCD_ENDPOINTS="http://127.0.0.1:2389"
ETCDCTL_CMD="ETCDCTL_API=3 ./etcdctl --endpoints=${ETCD_ENDPOINTS}"

# 需要处理的资源类型列表
RESOURCES=("namespaces" "devopsprojects" "appprojects" "clustertemplates" "clustersteptemplates")

# 导出资源的函数
export_resource() {
    local resource_type=$1
    local target_dir="${BASE_DIR}/${resource_type}"
    local list_file="${target_dir}/${resource_type}.list"
    
    echo "开始处理 ${resource_type} 资源..."
    
    # 创建目标目录
    if ! mkdir -p "${target_dir}"; then
        echo "错误：无法创建目录 ${target_dir}"
        return 1
    fi
    
    # 查询资源列表并保存到文件
    echo "查询 ${resource_type} 资源列表..."
    if ! eval "${ETCDCTL_CMD} get --prefix \"\" --keys-only | grep \"${resource_type}\" > \"${list_file}\""; then
        echo "错误：查询 ${resource_type} 资源列表失败"
        return 1
    fi
    
    # 检查是否有资源需要导出
    if [ ! -s "${list_file}" ]; then
        echo "警告：未找到 ${resource_type} 资源"
        return 0
    fi
    
    # 导出每个资源为yaml文件
    echo "正在导出 ${resource_type} 资源..."
    while IFS= read -r resource_path; do
        # 跳过空行
        [ -z "${resource_path}" ] && continue
        
        # 提取资源名称（假设路径格式为/registry/.../name）
        resource_name=$(basename "${resource_path}")
        yaml_file="${target_dir}/${resource_name}.yaml"
        
        # 导出资源
        if eval "${ETCDCTL_CMD} get \"${resource_path}\" --print-value-only > \"${yaml_file}\""; then
            echo "成功导出: ${yaml_file}"
        else
            echo "错误：导出 ${resource_path} 失败"
        fi
    done < "${list_file}"
    
    echo "${resource_type} 资源处理完成"
    echo "----------------------------------------"
}

# 主程序：处理所有资源类型
for resource in "${RESOURCES[@]}"; do
    export_resource "${resource}"
done

echo "所有资源导出操作已完成"
