

---

## 1️⃣ 控制平面组件启动顺序

控制平面主要有 **etcd、kube-apiserver、kube-controller-manager、kube-scheduler** 四大核心组件。

### **(1) etcd**

- **功能**：Kubernetes 的核心数据库，存储集群状态、配置、Secrets 等。
    
- **启动顺序**：最先启动。
    
- **原因**：其他控制平面组件（API Server、Controller）都依赖 etcd 读取和写入状态。
    
- **端口**：
    
    - 客户端访问：2379
        
    - 集群内部通信：2380
        

> ⚠️ 如果 etcd 没启动，API Server 会报 `etcd unreachable` 错误。

---

### **(2) kube-apiserver**

- **功能**：Kubernetes 的“前门”，所有请求都通过它。
    
- **启动顺序**：etcd 启动后启动。
    
- **依赖**：etcd 必须可用。
    
- **端口**：默认 6443（HTTPS）
    
- **证书**：Server Cert + Client CA
    
- **作用**：
    
    - 提供 REST API
        
    - 验证客户端证书
        
    - 写入/读取 etcd 数据
        

> ⚠️ 如果 API Server 没启动，kubectl、Controller、Scheduler 都无法工作。

---

### **(3) kube-controller-manager**

- **功能**：执行各种控制循环（Controller）：
    
    - Node Controller
        
    - Replication Controller
        
    - Endpoint Controller 等
        
- **启动顺序**：API Server 启动后。
    
- **依赖**：必须能访问 API Server（通常在 127.0.0.1:10257）。
    
- **作用**：
    
    - 监控资源状态
        
    - 调整实际状态使其符合期望状态
        

---

### **(4) kube-scheduler**

- **功能**：为未调度的 Pod 选择合适的 Node。
    
- **启动顺序**：API Server 启动后。
    
- **依赖**：API Server
    
- **作用**：
    
    - 读取未调度 Pod
        
    - 根据调度策略（资源、亲和性）选择 Node
        
    - 写回 API Server
        

---

## 2️⃣ 节点组件启动顺序

在控制平面启动后，开始工作节点的启动顺序：

### **(1) kubelet**

- **功能**：节点代理，管理 Pod 生命周期，注册节点信息。
    
- **启动顺序**：节点启动时。
    
- **依赖**：
    
    - API Server 必须可用（获取 Pod 任务）
        
    - 容器运行时（containerd 或 Docker）必须可用
        
- **证书**：
    
    - 节点证书（kubelet.kubeconfig）
        
    - CA 证书
        

---

### **(2) kube-proxy**

- **功能**：维护节点网络规则，实现 Service 转发。
    
- **启动顺序**：kubelet 启动后，由 kubelet 管理。
    
- **依赖**：
    
    - API Server
        
    - 节点网络插件（如 Flannel、Calico）配置
        

---

### **(3) CNI 网络插件**

- **功能**：实现 Pod 间网络互通。
    
- **启动顺序**：
    
    - kube-apiserver + kubelet 启动后，由 kubectl 或 DaemonSet 部署
        
- **作用**：
    
    - 创建 Pod 网络
        
    - 配置 IP 分配和路由
        
- **注意**：
    
    - 网络插件必须在 Pod 能互通前完成，否则 Service/ClusterIP 无法访问。
        

---

## 3️⃣ kubectl 使用顺序（客户端）

- **依赖**：API Server 启动
    
- **作用**：
    
    - 查看节点状态
        
    - 部署 Pod/Service
        
    - 检查网络和调度情况
        

> ⚠️ 如果 kubectl 尝试访问 localhost:8080 而 API Server 在 6443，就会报错

---

## 4️⃣ 总结顺序图（简化版）

```
etcd --> kube-apiserver --> kube-controller-manager
                               \
                                --> kube-scheduler
kubelet (节点) --> CNI 网络插件
          \
           --> kube-proxy
kubectl (客户端) --> kube-apiserver
```

---

## 5️⃣ 核心原则

1. **先有数据存储（etcd）** → 再启动 API Server → 控制循环和调度器才能正常工作。
    
2. **节点组件必须等 API Server 可访问** → kubelet 才能注册，kube-proxy 才能配置网络。
    
3. **网络插件必须在 Pod 创建前就准备好** → 保证 Pod 能互通。
    
4. **kubectl 依赖 KUBECONFIG 或 admin.conf** → 确保能访问 API Server。
    

---

