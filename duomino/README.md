duomino的前端启动脚本，用于解决云平台环境部署domino出现network erro的问题。  
执行脚本之前，应修改容器配置部分。配置说明如下，  
```bash
CONTAINER_NAME是容器的名字，需当前环境全局唯一。  
API_URL是domino-rest容器的IP和对应的物理机端口。  
IMAGE是定制容器镜像，可替换为自己定制的前端镜像。  
HOST_PORT是前端容器的物理机端口，部署后可通过IP:端口在浏览器访问。
```
