# 说明
数据持久化
- 依赖pvc和pv的配置。
- 支持数据持久化的组件：namenode,datanode  
采用statefulset资源类型，持久运行。
service
- 支持集群内访问。例如`namenode-0.namenode.bigdata4:9000`
