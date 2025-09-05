#!/bin/bash

# 默认配置
DEFAULT_BASE_DIR="/tmp"
DEFAULT_RESOURCE="namespaces"
ETCD_ENDPOINTS="http://127.0.0.1:2389"
ETCDCTL_PATH="./etcdctl"
ETCDCTL_CMD="ETCDCTL_API=3 ${ETCDCTL_PATH} --endpoints=${ETCD_ENDPOINTS}"

# 初始化变量
base_dir=""
resource=""
resource_file=""
RESOURCES=()

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)
                base_dir="$2"
                shift 2
                ;;
            -r|--resource)
                resource="$2"
                shift 2
                ;;
            -f|--file)
                resource_file="$2"
                shift 2
                ;;
            --help)
                print_help
                exit 0
                ;;
            *)
                echo "错误：未知参数 $1"
                print_help
                exit 1
                ;;
        esac
    done

    # 设置默认基础目录
    if [ -z "${base_dir}" ]; then
        base_dir="${DEFAULT_BASE_DIR}"
    fi

    # 确定资源列表
    if [ -n "${resource_file}" ]; then
        # 从文件读取资源列表
        if [ ! -f "${resource_file}" ]; then
            echo "错误：资源清单文件 ${resource_file} 不存在"
            exit 1
        fi
        # 读取文件内容，忽略空行和注释
        while IFS= read -r line; do
            # 跳过空行和注释行
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            RESOURCES+=("$line")
        done < "${resource_file}"
        
        if [ ${#RESOURCES[@]} -eq 0 ]; then
            echo "警告：资源清单文件 ${resource_file} 中没有有效的资源类型"
            exit 1
        fi
    elif [ -n "${resource}" ]; then
        # 使用指定的单个资源
        RESOURCES+=("${resource}")
    else
        # 使用默认资源
        RESOURCES+=("${DEFAULT_RESOURCE}")
    fi
}

# 打印帮助信息
print_help() {
    echo "用法: $0 [选项]"
    echo "导出etcd中的资源到指定目录"
    echo
    echo "选项:"
    echo "  -d, --dir      指定基础目录，默认: ${DEFAULT_BASE_DIR}"
    echo "  -r, --resource 指定要处理的资源类型，默认: ${DEFAULT_RESOURCE}"
    echo "  -f, --file     从文件中读取要处理的资源类型列表"
    echo "  --help         显示帮助信息"
    echo
    echo "示例:"
    echo "  $0 -d /data/etcd_export -r namespaces"
    echo "  $0 --dir /tmp/export --file resources.txt"
}

# 检查etcdctl是否可执行
check_etcdctl() {
    if [ ! -x "${ETCDCTL_PATH}" ]; then
        echo "错误：etcdctl不存在或不可执行 - ${ETCDCTL_PATH}"
        echo "请检查路径是否正确，并确保有执行权限"
        exit 1
    fi
    
    # 测试连接
    echo "测试etcd连接..."
    if ! eval "${ETCDCTL_CMD} endpoint health > /dev/null 2>&1"; then
        echo "错误：无法连接到etcd服务 - ${ETCD_ENDPOINTS}"
        echo "请检查endpoints是否正确，etcd服务是否运行"
        exit 1
    fi
    echo "etcd连接测试成功"
}

# 导出资源的函数
export_resource() {
    local resource_type=$1
    local target_dir="${base_dir}/${resource_type}"
    local list_file="${target_dir}/${resource_type}.list"
    
    echo "开始处理 ${resource_type} 资源..."
    
    # 创建目标目录
    if ! mkdir -p "${target_dir}"; then
        echo "错误：无法创建目录 ${target_dir}"
        return 1
    fi
    
    # 构建查询命令
    local query_cmd="${ETCDCTL_CMD} get --prefix \"\" --keys-only"
    local filter_cmd="grep \"${resource_type}\""
    local full_cmd="${query_cmd} | ${filter_cmd} > \"${list_file}\""
    
    # 查询资源列表并保存到文件
    echo "查询 ${resource_type} 资源列表..."
    
    if ! eval "${full_cmd}"; then
        echo "错误：查询 ${resource_type} 资源列表失败"
        return 1
    fi
    
    # 检查是否有资源需要导出
    if [ ! -s "${list_file}" ]; then
        echo "警告：未找到 ${resource_type} 资源"
        return 0
    fi
    
    # 显示找到的资源数量
    local count=$(wc -l < "${list_file}")
    echo "找到 ${count} 个 ${resource_type} 资源，开始导出..."
    
    # 导出每个资源为yaml文件
    while IFS= read -r resource_path; do
        # 跳过空行
        [ -z "${resource_path}" ] && continue
        
        # 提取资源名称
        resource_name=$(basename "${resource_path}")
        yaml_file="${target_dir}/${resource_name}.yaml"
        
        # 导出资源
        export_cmd="${ETCDCTL_CMD} get \"${resource_path}\" --print-value-only > \"${yaml_file}\""
        if eval "${export_cmd}"; then
            echo "成功导出: ${yaml_file}"
        else
            echo "错误：导出 ${resource_path} 失败"
        fi
    done < "${list_file}"
    
    echo "${resource_type} 资源处理完成"
    echo "----------------------------------------"
}

# 主程序
parse_args "$@"
check_etcdctl

echo "使用基础目录: ${base_dir}"
echo "处理资源类型: ${RESOURCES[*]}"
echo

for res in "${RESOURCES[@]}"; do
    export_resource "${res}"
done

echo "所有资源导出操作已完成"
