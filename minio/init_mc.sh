#!/bin/bash
# 自动配置mc client
# 定义目标路径
TARGET_DIR="$HOME/minio-binaries"
TARGET_PATH="$TARGET_DIR/mc"

# 检查本地mc文件是否存在
if [ ! -f "./mc" ]; then
    echo "错误：当前目录下未找到mc文件"
    exit 1
fi

# 创建目标目录（如果不存在）
echo "正在准备安装目录..."
mkdir -p "$TARGET_DIR" || {
    echo "错误：无法创建目录 $TARGET_DIR"
    exit 1
}

# 复制文件
echo "正在复制mc到目标位置..."
cp ./mc "$TARGET_PATH" || {
    echo "错误：复制文件失败"
    exit 1
}

# 添加执行权限
echo "设置执行权限..."
chmod +x "$TARGET_PATH" || {
    echo "错误：无法设置执行权限"
    exit 1
}

# 配置环境变量（持久化）
echo "配置环境变量..."
if ! grep -q "$TARGET_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$TARGET_DIR" >> "$HOME/.bashrc"
    echo "环境变量已添加到 .bashrc"
fi

# 对于使用zsh的用户
if [ -f "$HOME/.zshrc" ] && ! grep -q "$TARGET_DIR" "$HOME/.zshrc"; then
    echo "export PATH=\$PATH:$TARGET_DIR" >> "$HOME/.zshrc"
    echo "环境变量已添加到 .zshrc"
fi

# 立即加载环境变量
export PATH="$PATH:$TARGET_DIR"

# 验证安装
echo "验证mc安装..."
if command -v mc &> /dev/null; then
    echo "mc版本信息："
    mc --version
    echo "安装成功！请重启终端或执行 source ~/.bashrc (或 ~/.zshrc) 使配置生效"
else
    echo "警告：mc命令暂时无法识别，请手动执行 source ~/.bashrc 后重试"
    exit 1
fi