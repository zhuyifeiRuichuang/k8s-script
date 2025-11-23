#!/bin/bash

# ==========================================================
# Ubuntu 22.04 (Jammy Jellyfish) 软件源自动替换脚本
# 使用前请确保您了解其作用
# ==========================================================

# 1. 定义变量
SOURCES_FILE="/etc/apt/sources.list"
BACKUP_FILE="${SOURCES_FILE}.bak_$(date +%Y%m%d%H%M%S)"

# 清华大学 (TUNA) 镜像站的 Ubuntu 22.04 官方源内容
# !!! 请根据您的需求替换此处的源内容 !!!
NEW_SOURCES="
# 默认主源 (清华大学 TUNA 镜像站)
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# 源码源
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse

# 稳定版更新源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

# 安全更新源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

# 反向移植源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
"

echo "=== 🚀 Ubuntu 22.04 软件源替换脚本开始执行 ==="

# 2. 检查是否具有 root 权限
if [ "$EUID" -ne 0 ]; then
  echo "❌ 错误: 此脚本需要 root 权限才能执行。"
  echo "请使用 'sudo bash $0' 运行。"
  exit 1
fi

# 3. 备份旧的 sources.list 文件
echo "✅ 备份旧文件: ${SOURCES_FILE} -> ${BACKUP_FILE}"
cp "${SOURCES_FILE}" "${BACKUP_FILE}"

# 4. 写入新的软件源内容
echo "✅ 正在写入新的软件源内容到 ${SOURCES_FILE}"
echo "${NEW_SOURCES}" > "${SOURCES_FILE}"

# 5. 清理和更新软件包列表
echo "✅ 正在执行 'sudo apt update' 更新软件包列表..."
apt update

# 6. 检查更新结果
if [ $? -eq 0 ]; then
  echo "🎉 恭喜! 软件源已成功更换并更新。"
  echo "旧文件已备份至: ${BACKUP_FILE}"
else
  echo "⚠️ 警告: 软件源已替换，但 apt update 过程中出现错误，请检查新的源内容是否正确。"
fi

echo "=== 🏁 脚本执行完毕 ==="
