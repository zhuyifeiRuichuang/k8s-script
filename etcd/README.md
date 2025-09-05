关于etcd的操作脚本。

> 业务场景1：  
k8s集群故障，仅数据留存，软件均被破坏，需导出旧数据到新k8s集群。

`start_etcd.sh`,用于启动etcd并读取指定目录的数据。需编辑后使用。
`export_etcd_resources.sh`，读取`resources.txt`中的资源类型，导出资源类型下所有资源为yaml文件，存放在指定位置。

查询可选的资源类型的方法  
```bash
ETCDCTL_API=3 ./etcdctl \
  --endpoints=http://127.0.0.1:2389 \
  get --prefix "" --keys-only | awk -F '/' '{if(NF >= 2) print $(NF-1)}' | sort | uniq -c
```
