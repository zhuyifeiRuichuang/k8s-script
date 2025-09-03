上传和下载  
针对minio的操作脚本
受限GitHub上传文件限制，文件`mc`需自行下载。可浏览器访问`https://dl.min.io/client/mc/release/linux-amd64/mc` 下载。也可复制命令下载。
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
  ```
init_mc.sh | 用于离线环境 | 需先手动下载文件`mc`到脚本所在目录 | 可实现mc client自动配置
mc_get.sh | 需编辑后使用 | 可实现自动拉取指定文件到当前Linux主机
