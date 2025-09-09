针对minio的操作脚本，适用于无python的Linux环境。  

使用脚本前，应先下载`mc client`最新版本到本目录，浏览器访问`https://dl.min.io/client/mc/release/linux-amd64/mc` 下载。或执行以下命令，
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
  ```

`init_mc.sh`,在当前系统初始化mc client，使当前环境可用命令`mc`  
`mc_login.sh`,需编辑,用于登录minio，配置别名  
`mc_get.sh`,需编辑,可拉取指定文件到当前Linux主机  
`upload_to_minio`,需编辑，上传指定文件和目录到指定的minio  
