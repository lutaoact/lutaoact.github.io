
## 启动服务

```bash
# 运行开发环境，此命令会安装依赖并构建服务，产生对应的html文件
make dev
# 开发环境启动后，可以通过http://127.0.0.1:4000看到页面效果。代码通过volume挂载进容器，编辑主机上的本地文件，可以看到实时效果

# 开发完成后，执行make build_server构建blogserver:latest镜像，此镜像可用于部署

# 执行make run_server可以启动镜像，默认导出4000端口
```
