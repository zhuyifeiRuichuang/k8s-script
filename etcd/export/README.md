说明  
用于导出etcd数据文件内指定资源为yaml文件，用于导入到其他k8s或etcd环境。  

`export_etcd_resources.sh`
- 读取`export.conf`中配置，指定数据导出存放的目录，指定其他配置。详见文件中说明。  
- 读取`resources.txt`中的资源类型，导出资源类型下所有资源为yaml文件，存放在指定位置。可使用 `--help`查看使用方法。

查询旧数据中可选的资源类型:  
```bash
ETCDCTL_API=3 ./etcdctl \
  --endpoints=http://127.0.0.1:2389 \
  get --prefix "" --keys-only | awk -F '/' '{if(NF >= 2) print $(NF-1)}' | sort | uniq -c
```
