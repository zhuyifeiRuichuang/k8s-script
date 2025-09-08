关于etcd的操作脚本。

> 业务场景1：  
k8s集群故障，`kubectl`和`etcdctl`软件均被破坏，仅部分磁盘数据留存，需导出k8s集群内部分旧数据到新k8s集群继续使用。旧数据默认路径`/var/lib/etcd/`

`start_etcd.sh`,用于启动etcd并读取指定目录的数据。需编辑`--data-dir`,指定旧数据存放的目录。应在全新操作环境处理，避免干扰其他k8s集群。  
`export_etcd_resources.sh`，读取`resources.txt`中的资源类型，导出资源类型下所有资源为yaml文件，存放在指定位置。可使用 `--help`查看使用方法。

查询旧数据中可选的资源类型:  
```bash
ETCDCTL_API=3 ./etcdctl \
  --endpoints=http://127.0.0.1:2389 \
  get --prefix "" --keys-only | awk -F '/' '{if(NF >= 2) print $(NF-1)}' | sort | uniq -c
```
