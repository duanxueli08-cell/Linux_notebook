


### 1️⃣ kubectl 如何知道去哪儿

`kubectl` 是一个客户端工具，它需要知道 **Kubernetes API Server 的地址、认证方式和证书** 才能操作集群。这些信息存放在一个 **kubeconfig 文件** 中，默认位置和搜索顺序是这样的：

1. 如果环境变量 `KUBECONFIG` 被设置，kubectl 就用它指向的文件。
    
2. 如果没有设置，kubectl 会找 `~/.kube/config`。
    
3. 如果两者都没有，就会尝试访问 **`http://localhost:8080`**（这是 kubelet 的早期兼容行为，通常没用）。


### 2️⃣ 为什么要指向 `/etc/kubernetes/admin.conf`

在 `kubeadm init` 初始化 Kubernetes master 后，会生成 `/etc/kubernetes/admin.conf`：

- 里面包含 **API Server 地址**（通常是 `https://<master-ip>:6443`）
    
- **客户端证书和密钥**
    
- **CA 证书**
    

没有这个配置，kubectl 就不知道要去哪里，也没有凭证去访问 API Server，所以它就退回去尝试 `localhost:8080`


那么 ~/.kube/config 文件从哪里来？
既然 kubectl 先找这个文件，那就说明是已经设定好的用这个文件；
可是既然是用 /etc/kubernetes/admin.conf 文件中的密钥验证等证书信息，为什么不直接指定这个文件，从这个文件中读取信息！

这其实涉及 **Kubernetes 的客户端配置习惯和权限管理**。
- `~/.kube/config` 是 **kubectl 默认的 kubeconfig 文件**，面向 **普通用户**。
    
- 当你用 `kubectl` 操作集群时，如果没有显式设置 `KUBECONFIG`，它就会去这个文件里找集群信息、证书和凭证。
    
- 这样做的好处是 **不用每次都指定 KUBECONFIG**，对普通用户透明。

- /etc/kubernetes/admin.conf  这是 **kubeadm 初始化 master 时生成的管理员配置文件**，里面有：
    
    - cluster 信息（API Server 地址）
        
    - admin 用户的证书和密钥
        
    - CA 证书
        
- 这个文件是 **root 权限的管理员专用配置**，不适合普通用户直接写入 `~/.kube/config`，因为涉及敏感凭证。


![[Pasted image 20251216220543.png]]