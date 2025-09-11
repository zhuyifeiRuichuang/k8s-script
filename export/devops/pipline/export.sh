#!/bin/bash

# 功能：导出K8s中所有namespace、pipeline信息及pipeline的yaml配置

# 第一步：导出所有namespace信息到export.ns.list
echo "===== 开始导出namespace列表 ====="
if kubectl get ns > export.ns.list; then
  echo "namespace列表已保存到 export.ns.list"
else
  echo "Error: 获取namespace失败，请检查kubectl配置"
  exit 1
fi

# 第二步：创建导出yaml文件的目录
echo -e "\n===== 准备导出pipeline的yaml文件 ====="
export_dir="export.yaml"
if [ ! -d "$export_dir" ]; then
  mkdir -p "$export_dir"
  echo "已创建目录: $export_dir"
else
  echo "目录已存在: $export_dir"
fi

# 第三步：查询所有namespace下的pipeline信息并导出yaml
echo -e "\n===== 开始查询并导出pipeline信息 ====="
> export.pipline.list  # 清空文件（避免重复追加）

# 获取所有namespace名称（仅提取名称字段）
namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

# 循环遍历每个namespace
for ns in $namespaces; do
  echo -e "\n处理namespace: $ns"
  
  # 查询当前namespace下的pipeline，结果追加到列表文件（过滤无资源的提示）
  pipeline_info=$(kubectl get pipelines.devops.kubesphere.io -n "$ns" 2>&1)
  if ! echo "$pipeline_info" | grep -q "No resources found"; then
    echo -e "\n===== Namespace: $ns =====" >> export.pipline.list
    echo "$pipeline_info" >> export.pipline.list
    echo "已记录$ns下的pipeline信息到 export.pipline.list"
  else
    echo "$ns下无pipeline资源，跳过"
  fi

  # 导出当前namespace下的所有pipeline为yaml文件
  # 提取当前namespace下的pipeline名称列表
  pipelines=$(kubectl get pipelines.devops.kubesphere.io -n "$ns" -o jsonpath='{.items[*].metadata.name}')
  for pipeline in $pipelines; do
    yaml_file="${export_dir}/${ns}-${pipeline}.yaml"
    if kubectl get pipelines.devops.kubesphere.io "$pipeline" -n "$ns" -o yaml > "$yaml_file"; then
      echo "已导出yaml: $yaml_file"
    else
      echo "Error: 导出$ns下的$pipeline失败"
    fi
  done
done

echo -e "\n===== 所有操作完成 ====="
echo "1. namespace列表: export.ns.list"
echo "2. pipeline信息列表: export.pipline.list"
echo "3. pipeline yaml文件目录: $export_dir"
