import importlib
import subprocess
import sys
import os
import time
import threading
import datetime
import random
import string

# 生成日志文件名：日期+随机编码+upload_minio.log
def generate_log_filename():
    date_str = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    random_str = ''.join(random.choices(string.ascii_letters + string.digits, k=6))
    return f"{date_str}_{random_str}_upload_minio.log"

# 全局日志文件路径
log_file = generate_log_filename()

# 写入日志到文件
def log(message):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, 'a', encoding='utf-8') as f:
        f.write(f"[{timestamp}] {message}\n")

# 全局进度状态
progress_steps = ["检查系统环境", "安装pip", "安装minio模块", "读取配置文件", "连接MinIO服务", "准备上传", "执行上传"]
current_step = 0
progress_complete = False
total_files = 0  # 总文件数（文件+目录中的文件）
uploaded_files = 0  # 已上传文件数

def update_progress():
    """更新进度条显示"""
    global current_step, progress_complete, total_files, uploaded_files
    symbols = ['-', '\\', '|', '/']
    symbol_index = 0
    
    while not progress_complete:
        display_step = current_step if current_step < len(progress_steps) else len(progress_steps) - 1
        sys.stdout.write('\r')
        
        # 计算总体进度
        if current_step < 6:  # 上传前的步骤
            percent = (current_step / len(progress_steps)) * 100
        else:  # 上传阶段
            base_percent = (6 / len(progress_steps)) * 100
            if total_files > 0:
                file_percent = (uploaded_files / total_files) * (100 - base_percent)
            else:
                file_percent = 0
            percent = base_percent + file_percent
            if percent > 100:
                percent = 100
        
        bar_length = 30
        filled_length = int(bar_length * percent // 100)
        bar = '#' * filled_length + '-' * (bar_length - filled_length)
        
        # 显示进度
        if current_step == 6 and total_files > 0:
            sys.stdout.write(f"[{bar}] {percent:.1f}% {symbols[symbol_index]} 当前步骤: {progress_steps[display_step]} ({uploaded_files}/{total_files})")
        else:
            sys.stdout.write(f"[{bar}] {percent:.1f}% {symbols[symbol_index]} 当前步骤: {progress_steps[display_step]}")
        
        sys.stdout.flush()
        symbol_index = (symbol_index + 1) % len(symbols)
        time.sleep(0.2)
    
    sys.stdout.write('\r')
    sys.stdout.write(f"[{'#' * bar_length}] 100.0% 所有步骤已完成!")
    sys.stdout.write('\n')
    sys.stdout.flush()

def set_step(step_index):
    """更新当前步骤"""
    global current_step
    if step_index <= len(progress_steps):
        current_step = step_index
    log(f"进入步骤: {progress_steps[current_step]}")
    time.sleep(0.5)

def get_package_manager():
    """检测操作系统包管理器"""
    log("开始检测操作系统包管理器")
    if os.path.exists('/etc/redhat-release') or os.path.exists('/etc/centos-release'):
        log("检测到RedHat/CentOS系统，使用yum包管理器")
        return 'yum'
    elif os.path.exists('/etc/debian_version') or os.path.exists('/etc/lsb-release'):
        log("检测到Debian/Ubuntu系统，使用apt包管理器")
        return 'apt'
    else:
        log("无法识别操作系统类型")
        return None

def check_and_install_pip():
    """检查并安装pip"""
    log("开始检查pip是否已安装")
    try:
        importlib.import_module('pip')
        log("pip已安装")
        return True
    except ImportError:
        log("未找到pip，准备安装...")
    
    pkg_manager = get_package_manager()
    if not pkg_manager:
        log("无法识别操作系统，无法安装pip")
        return False
    
    try:
        log(f"使用{pkg_manager}执行更新操作")
        if pkg_manager == 'yum':
            result = subprocess.run(['sudo', 'yum', 'update', '-y'], capture_output=True, text=True)
            log(f"yum update stdout: {result.stdout}")
            log(f"yum update stderr: {result.stderr}")
            if result.returncode != 0:
                log(f"yum update 失败，返回码: {result.returncode}")
                return False
                
            log("开始安装python3-pip")
            result = subprocess.run(['sudo', 'yum', 'install', 'python3-pip', '-y'], capture_output=True, text=True)
            log(f"yum install python3-pip stdout: {result.stdout}")
            log(f"yum install python3-pip stderr: {result.stderr}")
            if result.returncode != 0:
                log(f"yum install python3-pip 失败，返回码: {result.returncode}")
                return False
        else:  # apt
            log("开始执行apt update")
            result = subprocess.run(['sudo', 'apt', 'update', '-y'], capture_output=True, text=True)
            log(f"apt update stdout: {result.stdout}")
            log(f"apt update stderr: {result.stderr}")
            if result.returncode != 0:
                log(f"apt update 失败，返回码: {result.returncode}")
                return False
                
            log("开始安装python3-pip")
            result = subprocess.run(['sudo', 'apt', 'install', 'python3-pip', '-y'], capture_output=True, text=True)
            log(f"apt install python3-pip stdout: {result.stdout}")
            log(f"apt install python3-pip stderr: {result.stderr}")
            if result.returncode != 0:
                log(f"apt install python3-pip 失败，返回码: {result.returncode}")
                return False
        
        try:
            importlib.import_module('pip')
            log("pip安装成功并验证通过")
            return True
        except ImportError:
            log("pip安装成功但无法导入")
            return False
            
    except Exception as e:
        log(f"安装pip时发生异常: {str(e)}")
        return False

def check_and_install_minio():
    """检查并安装minio模块"""
    log("开始检查minio模块是否已安装")
    try:
        importlib.import_module('minio')
        log("minio模块已安装")
        return True
    except ImportError:
        log("未找到minio模块，开始安装...")
        try:
            result = subprocess.run([sys.executable, "-m", "pip", "install", "minio"], capture_output=True, text=True)
            log(f"pip install minio stdout: {result.stdout}")
            log(f"pip install minio stderr: {result.stderr}")
            if result.returncode != 0:
                log(f"安装minio模块失败，返回码: {result.returncode}")
                return False
                
            log("minio模块安装完成")
            return True
        except Exception as e:
            log(f"安装minio模块时发生异常: {str(e)}")
            return False

def read_config(config_file):
    """读取配置文件"""
    log(f"开始读取配置文件: {config_file}")
    if not os.path.exists(config_file):
        error_msg = f"配置文件 {config_file} 不存在"
        log(error_msg)
        raise Exception(error_msg)
    
    config_data = {}
    try:
        with open(config_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"')
                    if value.lower() == 'true':
                        value = True
                    elif value.lower() == 'false':
                        value = False
                    config_data[key] = value
                    log(f"读取配置项: {key} = {value}")
    except Exception as e:
        error_msg = f"读取配置文件时发生错误: {str(e)}"
        log(error_msg)
        raise Exception(error_msg)
    
    required_keys = [
        'minio_client.endpoint', 'minio_client.access_key', 
        'minio_client.secret_key', 'minio_client.secure',
        'bucket_name'
    ]
    for key in required_keys:
        if key not in config_data:
            error_msg = f"配置文件缺少必要项: {key}"
            log(error_msg)
            raise Exception(error_msg)
    
    for key in ['local_file', 'object_name', 'local_dir', 'remote_dir']:
        if key not in config_data:
            config_data[key] = ""
            log(f"配置项 {key} 未设置，使用默认值: {config_data[key]}")
    
    return config_data

def get_all_files_in_dir(local_dir):
    """获取目录下所有文件的路径"""
    log(f"开始获取目录 {local_dir} 下的所有文件")
    if not os.path.isdir(local_dir):
        error_msg = f"{local_dir} 不是有效的目录"
        log(error_msg)
        raise Exception(error_msg)
    
    file_paths = []
    for root, _, files in os.walk(local_dir):
        for file in files:
            file_path = os.path.join(root, file)
            file_paths.append(file_path)
            log(f"找到文件: {file_path}")
    
    log(f"在目录 {local_dir} 中共找到 {len(file_paths)} 个文件")
    return file_paths

def upload_file(minio_client, bucket_name, local_file, object_name):
    """上传单个文件"""
    global uploaded_files
    log(f"准备上传单个文件: {local_file} 到 {bucket_name}/{object_name}")
    if not os.path.isfile(local_file):
        error_msg = f"{local_file} 不是有效的文件"
        log(error_msg)
        raise Exception(error_msg)
    
    if not object_name:
        object_name = os.path.basename(local_file)
        log(f"未指定object_name，使用默认值: {object_name}")
    
    try:
        minio_client.fput_object(bucket_name, object_name, local_file)
        uploaded_files += 1
        log(f"文件 {local_file} 上传成功，累计上传: {uploaded_files}")
    except Exception as e:
        error_msg = f"文件上传失败: {str(e)}"
        log(error_msg)
        raise Exception(error_msg)

def upload_directory(minio_client, bucket_name, local_dir, remote_dir):
    """上传目录"""
    global uploaded_files
    files = get_all_files_in_dir(local_dir)
    dir_file_count = len(files)
    
    if dir_file_count == 0:
        log(f"警告: 目录 {local_dir} 中没有文件")
        return
    
    log(f"开始上传目录 {local_dir} 到 {bucket_name}/{remote_dir}，共 {dir_file_count} 个文件")
    for local_file in files:
        relative_path = os.path.relpath(local_file, local_dir)
        if remote_dir:
            object_name = f"{remote_dir}/{relative_path}"
        else:
            object_name = relative_path
        
        object_name = object_name.replace(os.sep, '/')
        
        try:
            minio_client.fput_object(bucket_name, object_name, local_file)
            uploaded_files += 1
            log(f"已上传 {uploaded_files} 个文件: {local_file} -> {object_name}")
        except Exception as e:
            error_msg = f"文件 {local_file} 上传失败: {str(e)}"
            log(error_msg)
            raise Exception(error_msg)
    
    log(f"目录 {local_dir} 上传完成，该目录共上传 {dir_file_count} 个文件")

def main():
    global progress_complete, total_files, uploaded_files, log_file
    
    print(f"详细日志将输出到: {log_file}")
    log("===== 脚本开始执行 =====")
    
    progress_thread = threading.Thread(target=update_progress)
    progress_thread.daemon = True
    progress_thread.start()
    
    try:
        set_step(0)
        pkg_manager = get_package_manager()
        if not pkg_manager:
            raise Exception("不支持的操作系统")
        
        set_step(1)
        if not check_and_install_pip():
            raise Exception("无法安装pip")
        
        set_step(2)
        if not check_and_install_minio():
            raise Exception("无法安装minio模块")
        
        set_step(3)
        config = read_config('upload_minio.conf')
        
        set_step(4)
        from minio import Minio
        from minio.error import S3Error
        
        log(f"尝试连接MinIO服务: {config['minio_client.endpoint']}")
        minio_client = Minio(
            endpoint=config['minio_client.endpoint'],
            access_key=config['minio_client.access_key'],
            secret_key=config['minio_client.secret_key'],
            secure=config['minio_client.secure']
        )
        
        if not minio_client.bucket_exists(config['bucket_name']):
            log(f"桶 {config['bucket_name']} 不存在，创建新桶")
            minio_client.make_bucket(config['bucket_name'])
        else:
            log(f"桶 {config['bucket_name']} 已存在")
        
        set_step(5)
        # 检查是否有文件和目录需要上传
        has_local_file = config['local_file'] and config['local_file'].strip()
        has_local_dir = config['local_dir'] and config['local_dir'].strip()

        if not has_local_file and not has_local_dir:
            log("未配置任何要上传的文件或目录")
            print("\n未配置任何要上传的文件或目录，不执行上传操作")
            progress_complete = True
            log("===== 脚本正常退出 =====")
            sys.exit(0)

        # 计算总文件数
        total_files = 0
        dir_files = []
        if has_local_dir:
            dir_files = get_all_files_in_dir(config['local_dir'])
            total_files += len(dir_files)
            log(f"目录 {config['local_dir']} 包含 {len(dir_files)} 个文件")
        
        if has_local_file:
            total_files += 1
            log(f"检测到单个文件上传: {config['local_file']}")

        # 初始化已上传计数
        uploaded_files = 0

        set_step(6)
        # 执行上传
        result_msg = []
        if has_local_file:
            upload_file(minio_client, config['bucket_name'], config['local_file'], config['object_name'])
            result_msg.append(f"文件 {config['local_file']} 上传成功")
        
        if has_local_dir:
            upload_directory(minio_client, config['bucket_name'], config['local_dir'], config['remote_dir'])
            result_msg.append(f"目录 {config['local_dir']} 上传成功（{len(dir_files)} 个文件）")
        
        result_msg = "; ".join(result_msg)

    except Exception as e:
        progress_complete = True
        error_msg = f"操作失败: {str(e)}"
        log(error_msg)
        print(f"\n{error_msg}")
        log("===== 脚本异常退出 =====")
        sys.exit(1)
    
    set_step(len(progress_steps) - 1)
    progress_complete = True
    time.sleep(1)
    print(result_msg)
    log("===== 脚本成功执行完毕 =====")

if __name__ == "__main__":
    main()
