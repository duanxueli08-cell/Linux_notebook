
### 首先准备“钥匙” (Personal Access Token)

> GitHub 不让你用登录密码推镜像。

- 去 GitHub 设置：`Settings` -> `Developer settings` -> `Personal access tokens (classic)`。
    
- 生成一个 Token，勾选 `write:packages` 和 `read:packages`。**保存好这个 Token**。

### 终端登录 ( 尽量用虚拟机 )
```
# 这里的 TOKEN 就是你刚才保存的字符串
export CR_PAT=YOUR_TOKEN
echo $CR_PAT | docker login ghcr.io -u duanxueli08-cell --password-stdin
```

### 拉取、打标并推送 （ 选一台稳定的虚拟机 ）
```
# 拉取官方镜像 
docker pull mysql:8.4

# 打标（别忘了全小写，GitHub 仓库名不喜欢大写）
docker tag mysql:8.4 ghcr.io/duanxueli08-cell/mysql:8.4

# 登录 GitHub 容器仓库
docker login ghcr.io -u duanxueli08-cell -p 你的令牌(PAT)

# 推送
docker push ghcr.io/duanxueli08-cell/mysql:8.4
```

如何拉取？
```
docker pull ghcr.io/duanxueli08-cell/mysql:8.4
```

密钥存放位置：Bitwarden 软件；
上传的代码文档中不能出现密钥等敏感信息，所以这里就不写了！


GitHub 的镜像并不在代码文件列表里。它是通过 **GitHub Packages** 托管的。

- 访问路径：`https://github.com/duanxueli08-cell?tab=packages`
    
- 拉取路径：`docker pull ghcr.io/duanxueli08-cell/my-mysql:8.4`


官方网址：https://hub.docker.com/
查询 bitnami chart 对应的镜像版本 
- 比如说我想用 MySQL 8.4 ，那么对应的 Chart 版本就是 11.0.0 或 11.1.0 或 11.1.1 等
- ```
  helm search  repo mysql --versions | grep mysql 
  ```
下载 chart 并上传 github （也是虚拟机中完成）
```
helm push mysql-11.0.0 tgz oci://duanxueli08-cell/my-k8s-charts
helm pull oci://ghcr.io/duanxueli08-cell/charts/my-k8s-charts
```

