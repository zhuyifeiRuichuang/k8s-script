#!/bin/bash

# 初始化变量
package_name=""
download_dir=""
dist=""

# 显示帮助信息
usage() {
  echo "使用方法: $0 [选项]"
  echo "选项:"
  echo "  -n, --name <软件包名称>   指定要下载的软件包名称（必需）"
  echo "  -d, --dir <下载目录>      指定下载目录（可选，默认: /tmp/<软件包名称>/）"
  echo "  -h, --help                显示此帮助信息"
  exit 1
}

# 获取当前系统的发行版版本代号
get_distribution() {
  # 检查是否存在os-release文件
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    # 返回版本代号，如果不存在则返回发行版名称
    if [ -n "$VERSION_CODENAME" ]; then
      echo "$VERSION_CODENAME"
    else
      echo "$ID$VERSION_ID" | tr '[:upper:]' '[:lower:]'
    fi
  else
    #  fallback方案
    echo "$(lsb_release -cs 2>/dev/null || echo "unknown")"
  fi
}

# 解析命令行参数（支持长选项）
OPTIONS=$(getopt -o n:d:h --long name:,dir:,help -n "$0" -- "$@")

if [ $? -ne 0 ]; then
  echo "解析参数错误，请使用 -h 查看帮助" >&2
  exit 1
fi

eval set -- "$OPTIONS"

while true; do
  case "$1" in
    -n|--name)
      package_name="$2"
      shift 2
      ;;
    -d|--dir)
      download_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "内部错误" >&2
      exit 1
      ;;
  esac
done

# 检查必需参数是否完整
if [ -z "$package_name" ]; then
  echo "错误：软件包名称为必需参数" >&2
  usage
fi

# 设置默认下载目录
if [ -z "$download_dir" ]; then
  download_dir="/tmp/$package_name/"
  echo "未指定下载目录，将使用默认目录: $download_dir"
fi

# 获取发行版信息
dist=$(get_distribution)
if [ -z "$dist" ] || [ "$dist" = "unknown" ]; then
  echo "警告：无法识别操作系统发行版，将使用'unknown'作为发行版标识" >&2
  dist="unknown"
fi

# 创建下载目录（如果不存在）
mkdir -p "$download_dir"
if [ $? -ne 0 ]; then
  echo "无法创建目录 $download_dir" >&2
  exit 1
fi

# 兼容处理：放宽目录权限
sudo chmod -R 777 "$download_dir"
if [ $? -ne 0 ]; then
  echo "无法设置目录 $download_dir 权限" >&2
  exit 1
fi

# 切换到下载目录
cd "$download_dir" || {
  echo "无法进入目录 $download_dir" >&2
  exit 1
}

# 更新包索引
echo "正在更新包索引..."
sudo apt update > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "更新包索引失败" >&2
  exit 1
fi

# 获取依赖包列表
echo "正在解析 $package_name 的依赖关系..."
dependencies=$(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends \
  "$package_name" | grep "^\w" | sort -u)

if [ -z "$dependencies" ]; then
  echo "无法解析 $package_name 的依赖关系" >&2
  exit 1
fi

# 下载软件包及其所有依赖
echo "正在下载 $package_name 及其依赖包到 $download_dir..."
sudo apt download $dependencies

# 检查下载是否成功
if [ $? -ne 0 ]; then
  echo "下载过程中出现错误" >&2
  exit 1
fi

# 打包下载的软件包
archive_name="${package_name}_${dist}.tar.gz"
echo "正在将下载的软件包打包为: $archive_name"
tar -zcvf "$archive_name" *.deb > /dev/null 2>&1

# 检查打包是否成功
if [ $? -eq 0 ] && [ -f "$archive_name" ]; then
  echo "打包完成: $download_dir$archive_name"
  # 可选：删除原始deb文件，只保留压缩包
  # rm -f *.deb
else
  echo "打包过程中出现错误" >&2
  exit 1
fi

echo "操作完成。最终包已保存到: $download_dir$archive_name"
