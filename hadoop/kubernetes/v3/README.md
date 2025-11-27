基于v2，更新对hive的支持，支持tez  
遗留问题：更新配置文件后，datanode会因为hadoop cluster的namespaceID变化与namenode断连。创建后资源，不修改config文件，则可规避该问题。
