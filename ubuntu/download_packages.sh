#!/bin/bash

# 初始化变量
package_name=""
download_dir=""

# 解析命令行参数
while getopts "n:d:" opt; do
  case $opt in
    n)
      package_name="$OPTARG"
      ;;
    d)
      download_dir="$OPTARG"
      ;;
    \?)
      echo "无效的选项: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "选项 -$OPTARG 需要一个参数。" >&2
      exit 1
      ;;
  esac
done

# 检查参数是否完整
if [ -z "$package_name" ] || [ -z "$download_dir" ]; then
  echo "使用方法: $0 -n <软件包名称> -d <下载目录>"
  exit 1
fi

# 创建下载目录（如果不存在）
mkdir -p "$download_dir"
if [ $? -ne 0 ]; then
  echo "无法创建目录 $download_dir"
  exit 1
fi

# 兼容处理：不依赖_apt组，直接放宽目录权限（允许所有用户读写）
# 解决"invalid group: '_apt:_apt'"错误
sudo chmod -R 777 "$download_dir"
if [ $? -ne 0 ]; then
  echo "无法设置目录 $download_dir 权限"
  exit 1
fi

# 切换到下载目录
cd "$download_dir" || {
  echo "无法进入目录 $download_dir"
  exit 1
}

# 更新包索引
echo "正在更新包索引..."
sudo apt update > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "更新包索引失败"
  exit 1
fi

# 下载软件包及其所有依赖
echo "正在下载 $package_name 及其依赖包到 $download_dir..."
sudo apt download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends \
  "$package_name" | grep "^\w" | sort -u)

# 检查下载是否成功
if [ $? -eq 0 ]; then
  echo "下载完成。所有包已保存到 $download_dir"
else
  echo "下载过程中出现错误"
  exit 1
fi
