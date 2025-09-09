关于etcd的操作脚本。

> 业务场景1：  
k8s集群故障，`kubectl`和`etcdctl`软件均被破坏，仅部分磁盘数据留存，需导出k8s集群内部分旧数据到新k8s集群继续使用。旧数据默认路径`/var/lib/etcd/`

`start_etcd.sh`
- 自动检测etcd安装状态。
- 自动配置etcdctl环境变量。
- 自动安装指定版本etcd。
- 自动读取指定目录的etcd数据，针对snap和wal后缀文件。
- 需编辑`--data-dir`,指定旧数据存放的目录。`ETCD_VERSION`指定使用的etcd版本。
- 应在全新操作环境处理，避免影响在用的etcd环境。

查询旧数据中可选的资源类型:  
```bash
ETCDCTL_API=3 ./etcdctl \
  --endpoints=http://127.0.0.1:2389 \
  get --prefix "" --keys-only | awk -F '/' '{if(NF >= 2) print $(NF-1)}' | sort | uniq -c
```
