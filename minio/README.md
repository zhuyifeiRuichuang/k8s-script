针对minio的操作脚本，适用于无python的Linux环境。  
受限GitHub上传文件限制，文件`mc`需自行下载。可浏览器访问`https://dl.min.io/client/mc/release/linux-amd64/mc` 下载。也可复制命令下载。
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
  ```
注意：需先初始化minio，登录，再拉取文件。  
init_mc.sh | 用于联网或离线环境初始化mc client | 需先手动下载文件`mc`到脚本所在目录 | 可实现mc client自动配置  
mc_login.sh | 需编辑后使用 | 用于登录minio，配置别名  
mc_get.sh | 需编辑后使用 | 可自动拉取指定文件到当前Linux主机  
mc_cp.sh | 需编辑后使用 | 可拉取指定目录到当前Linux主机  
upload_to_minio | 上传指定文件和目录到minio
