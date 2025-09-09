> 脚本默认用于联网环境，默认机器可访问minio官网

可解压文件`mc.7z`在当前目录。或下载mc client:
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
  ```
> 离线环境 

中国地区可参考离线环境。
在联网环境先下载`mc client`最新版本，浏览器访问`https://dl.min.io/client/mc/release/linux-amd64/mc`。也可解压文件`mc.7z`在当前目录。

> 文件介绍
`init_mc.sh`,在当前系统初始化mc client，使当前环境可用命令`mc`，应将`mc`文件放在当前目录。  
`mc_login.sh`,需编辑,用于登录minio，配置别名  
`mc_get.sh`,需编辑,可拉取指定文件到当前Linux主机  
`upload`,用于上传指定文件和目录到指定的minio存储
`mc.7z`,mc client的压缩文件
