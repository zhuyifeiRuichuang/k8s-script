#!/bin/bash
# 自动配置mc client
# 定义目标路径
TARGET_DIR="$HOME/minio-binaries"
TARGET_PATH="$TARGET_DIR/mc"
MC_URL="https://dl.min.io/client/mc/release/linux-amd64/mc"

# 函数：安装7zip工具
install_7zip() {
    echo "未检测到7zip解压工具，正在尝试自动安装..."
    
    # 检测包管理器并安装相应的7zip包
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu 系统
        sudo apt-get update -y > /dev/null
        sudo apt-get install -y p7zip-full > /dev/null
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL 系统
        sudo yum install -y p7zip > /dev/null
    elif command -v dnf &> /dev/null; then
        # Fedora 系统
        sudo dnf install -y p7zip > /dev/null
    elif command -v pacman &> /dev/null; then
        # Arch Linux 系统
        sudo pacman -S --noconfirm p7zip > /dev/null
    else
        echo "错误：无法识别的Linux发行版，无法自动安装7zip"
        echo "请手动安装7zip工具（p7zip或p7zip-full）后重试"
        exit 1
    fi
    
    # 验证安装是否成功
    if ! command -v 7z &> /dev/null; then
        echo "错误：7zip安装失败"
        echo "请手动安装7zip工具（p7zip或p7zip-full）后重试"
        exit 1
    fi
    
    echo "7zip工具安装成功"
}

# 首先检查是否已经安装了mc
echo "检查是否已安装mc客户端..."
if command -v mc &> /dev/null; then
    echo "检测到已安装mc客户端，版本信息："
    mc --version
    echo "将跳过下载和安装步骤"
else
    echo "未检测到mc客户端，开始安装流程..."
    
    # 尝试下载mc文件
    echo "正在尝试下载mc客户端..."
    if curl "$MC_URL" --create-dirs -o "$TARGET_PATH"; then
        echo "mc客户端下载成功"
    else
        echo "mc客户端下载失败，尝试使用本地mc.7z文件..."
        
        # 检查当前目录是否有mc.7z（先确认文件存在）
        if [ -f "./mc.7z" ]; then
            echo "发现本地mc.7z文件，准备解压..."
            
            # 确认文件存在后，再检查7zip工具是否存在，不存在则安装
            if ! command -v 7z &> /dev/null; then
                install_7zip
            fi
            
            echo "正在解压mc.7z文件..."
            7z x ./mc.7z -o./ > /dev/null 2>&1 
            if [ $? -ne 0 ]; then
                echo "错误：解压mc.7z失败"
                exit 1
            fi
            
            # 确认解压出了mc文件
            if [ ! -f "./mc" ]; then
                echo "错误：解压mc.7z后未找到mc文件"
                exit 1
            fi
            
            # 确保目标目录存在
            mkdir -p "$TARGET_DIR" 
            if [ $? -ne 0 ]; then
                echo "错误：无法创建目录 $TARGET_DIR"
                exit 1
            fi
            
            # 复制解压后的文件到目标路径
            cp ./mc "$TARGET_PATH"
            if [ $? -ne 0 ]; then
                echo "错误：复制解压后的mc文件失败"
                exit 1
            fi
        else
            echo "错误：当前目录未找到mc.7z文件"
            echo "请手动从以下地址下载mc文件到当前目录："
            echo "$MC_URL"
            exit 1
        fi
    fi

    # 添加执行权限
    echo "设置执行权限..."
    chmod +x "$TARGET_PATH" 
    if [ $? -ne 0 ]; then
        echo "错误：无法设置执行权限"
        exit 1
    fi
fi

# 配置环境变量（持久化）
echo "配置环境变量..."
if ! grep -q "$TARGET_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$TARGET_DIR" >> "$HOME/.bashrc"
    echo "环境变量已添加到 .bashrc"
else
    echo ".bashrc中已存在环境变量配置，无需重复添加"
fi

# 对于使用zsh的用户
if [ -f "$HOME/.zshrc" ] && ! grep -q "$TARGET_DIR" "$HOME/.zshrc"; then
    echo "export PATH=\$PATH:$TARGET_DIR" >> "$HOME/.zshrc"
    echo "环境变量已添加到 .zshrc"
else
    echo ".zshrc中已存在环境变量配置，无需重复添加"
fi

# 立即加载环境变量
export PATH="$PATH:$TARGET_DIR"

# 验证安装
echo "验证mc安装..."
if command -v mc &> /dev/null; then
    echo "mc版本信息："
    mc --version
    echo "配置完成！请重启终端或执行 source ~/.bashrc (或 ~/.zshrc) 使配置生效"
else
    echo "警告：mc命令暂时无法识别，请手动执行 source ~/.bashrc 后重试"
    exit 1
fi
