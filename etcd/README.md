关于etcd的操作脚本。

> 业务场景1：  
k8s集群故障，仅数据留存，软件均被破坏，需导出旧数据到新k8s集群。

可编辑`start_etcd.sh`在全新机器，读取指定的etcd数据存档目录。编辑`export_etcd_resources.sh`，指定导出的资源和存档资源的目录。将导出的yaml文件导入新集群，可实现特定资源的数据恢复。  
`export_etcd_resources_v1.sh`将读取`resources.txt`实现业务场景1需求，需编辑`resources.txt`指定资源。
