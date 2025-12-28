# Kubernetes 故障排查完整手册

> **整理日期**: 2025-01-27  
> **来源**: 合并自多个故障排查笔记

---

## 📋 目录

1. [Pod 启动到对外服务全链路故障排查](#pod-启动到对外服务全链路故障排查)
2. [kubeadm 集群故障修复](#kubeadm-集群故障修复)
3. [kubectl 配置问题](#kubectl-配置问题)
4. [常用排查命令](#常用排查命令)

---

## Pod 启动到对外服务全链路故障排查

这是一张非常经典、覆盖面极广的 Kubernetes Pod 启动到对外服务全链路故障排查流程图（俗称 K8s 排障圣图），几乎把 95% 以上的 Pod 起不来、访问不通的坑都串起来了。

### 图的整体结构（从上到下）

1. **开始** → Pod 是否能正常运行（Running + Ready）
2. **如果不能运行** → 逐层排查 Pod 本身的问题（调度、镜像、资源、崩溃、重启、容器错误等）
3. **如果 Pod 本身 Running + Ready** → 检查能不能对外提供服务
   - Ingress 是否正常
   - Service 是否正常（含 ClusterIP、NodePort、LoadBalancer）

### 核心排障路径总结（按出现频率排序）

| 排名 | 问题类型                 | 典型现象                                    | 图中对应位置                   | 一句话解决思路                                               |
| ---- | ------------------------ | ------------------------------------------- | ------------------------------ | ------------------------------------------------------------ |
| 1    | 镜像拉取失败             | ImagePullBackOff / ErrImagePull             | 中间靠左                       | 检查镜像名、Tag、私有仓库 secret、是否拼错                   |
| 2    | 资源超限                 | OOMKilled、Pending                          | 上半部分 ResourceQuota 节点    | 看 limits/requests 是否配错、节点资源是否耗尽                |
| 3    | 存活/就绪探针失败        | CrashLoopBackOff、容器反复重启              | 中间偏右探针部分               | liveness/readiness probe 配置太严格或路径错                  |
| 4    | PVC 挂载失败             | Pending 很久起不来                          | 上半部分 PersistentVolumeClaim | 检查 StorageClass、PV 是否存在、权限                         |
| 5    | 调度失败（节点选不出来） | Pending                                     | 最上面调度部分                 | kubectl describe pod 看 Events（taint、affinity、节点资源不足） |
| 6    | 容器主进程退出           | CrashLoopBackOff、Exited(1)                 | 右下角 RunContainerError       | 查看日志，看业务代码是否启动就退                             |
| 7    | Service 选不到 Pod       | Service 有 Endpoint 但访问不通或无 Endpoint | 右下角 Service 部分            | 检查 selector 是否匹配 Pod 的 labels                         |
| 8    | Ingress 404 / 不通       | Pod 正常但域名访问不到                      | 左下角 Ingress 部分            | 检查 host、path、ingress-class、ingress-controller 是否正常  |
| 9    | 端口映射错               | 能 curl ClusterIP 但外部访问不行            | 最底部 port-forward 那几步     | containerPort、targetPort、nodePort 是否对齐                 |

### 这张图的真正价值

- 几乎所有新人/老鸟遇到 "Pod 起不来" 或 "服务访问不到" 时，都可以照着这张图从上到下一路走过去，基本不会漏掉大坑。
- 很多公司面试 K8s 岗位时，会直接甩这张图问"你能讲完吗？"——能讲完基本过。

### 个人最常用顺序（现实中 90% 的问题在这 5 步解决）

1. `kubectl get pod` → 看状态
2. `kubectl describe pod xxx` → 看 Events（最快定位 80% 问题）
3. `kubectl logs xxx --previous` → 看崩溃前日志
4. `kubectl get svc + kubectl get ep` → 看 Service 和 Endpoint
5. `kubectl get ingress + 直接 curl ingress-controller 地址测试`

---

## kubeadm 集群故障修复

> **适用前提**：
> - 控制平面还能访问（`kubectl get nodes` 能跑）
> - etcd 没炸
> - 不想重建集群

### 一、worker join 一开始就失败

#### ❌ 报错 1：`cluster-info` 相关

**典型现象**：
```text
couldn't get current server API group list
cluster-info not found
no JWS signature
```

**根因**：
- `kube-public/cluster-info` 不存在或无签名
- bootstrap token 没配置

**修复（master）**：
```bash
kubeadm init phase bootstrap-token
```

**验证**：
```bash
kubectl get cm -n kube-public cluster-info
```

---

### 二、join 时报 `kubeadm-config` 不存在

#### ❌ 报错 2

```text
configmaps "kubeadm-config" not found
```

**根因**：
- init 阶段没完整执行
- 手动删过 kube-system 里的 CM

**修复（master）**：
```bash
kubeadm init phase upload-config kubeadm
```

**验证**：
```bash
kubectl get cm -n kube-system kubeadm-config
```

---

### 三、join 时报 forbidden（RBAC 问题）

#### ❌ 报错 3

```text
User "system:bootstrap:xxxx" cannot get resource "configmaps"
```

**根因**：
- bootstrap RBAC 被删 / 未创建
- `system:node-config-reader` 缺失

**修复步骤（master）**：

1. **创建 ClusterRole（如果没有）**：
```bash
kubectl get clusterrole system:node-config-reader || kubectl create clusterrole system:node-config-reader \
  --verb=get,list,watch \
  --resource=configmaps
```

2. **创建 ClusterRoleBinding（关键）**：
```bash
kubectl get clusterrolebinding system:node-config-reader || kubectl create clusterrolebinding system:node-config-reader \
  --clusterrole=system:node-config-reader \
  --group=system:bootstrappers:kubeadm:default-node-token
```

**验证**：
```bash
kubectl describe clusterrolebinding system:node-config-reader
```

必须看到：
```text
Group: system:bootstrappers:kubeadm:default-node-token
```

---

### 四、RBAC 修好后，变成 not found

#### ❌ 报错 4

```text
configmaps "kubelet-config" not found
configmaps "kube-proxy" not found
```

**根因**：
- init 产物缺失
- kubeadm init 没跑完整

**修复（master）**：

1. **补 kubelet-config**：
```bash
kubeadm init phase upload-config kubelet
```

验证：
```bash
kubectl get cm -n kube-system kubelet-config
```

2. **补 kube-proxy**：
```bash
kubeadm init phase addon kube-proxy
```

验证：
```bash
kubectl get cm -n kube-system kube-proxy
```

---

### 五、join 卡在 CSR（证书阶段）

#### ❌ 现象

```bash
kubectl get csr
```

看到：
```text
Pending
```

**根因**：
- 自动审批 RBAC 缺失
- 或 controller 没权限

**修复（master）**：
```bash
kubeadm init phase bootstrap-token
```

或手工审批（临时救急）：
```bash
kubectl certificate approve <csr-name>
```

---

### 六、kubelet 起不来（join 后）

#### ❌ 现象

```bash
systemctl status kubelet
```

报证书 / 配置错误

**常见修复（node）**：
```bash
rm -f /etc/kubernetes/kubelet.conf
systemctl restart kubelet
```

或（极端情况）：
```bash
kubeadm reset -f
rm -rf /etc/cni/net.d /var/lib/cni
```

然后重新 join。

---

### 七、一条"健康检查"万能命令（强烈建议）

在 **master** 上跑：
```bash
kubectl get cm -n kube-system | egrep 'kubeadm-config|kubelet-config|kube-proxy'
kubectl get cm -n kube-public cluster-info
kubectl get clusterrolebinding | egrep 'node-config-reader|bootstrap'
```

只要这几样在，**worker join 99% 没问题**。

---

### 八、把这次事故浓缩成一句"运维真理"

> **kubeadm 集群不是"坏在节点"，而是"坏在初始化记忆丢失"**

你这次做的所有修复，本质都是在回答一个问题：

> "新节点加入时，集群还能不能完整回答它的三个问题？"
> 
> - 我是谁？（cluster-info / CA）
> - 你当初怎么建的？（kubeadm-config）
> - 我该怎么跑？（kubelet-config / kube-proxy）

---

## kubectl 配置问题

### kubectl 如何知道去哪儿

`kubectl` 是一个客户端工具，它需要知道 **Kubernetes API Server 的地址、认证方式和证书** 才能操作集群。这些信息存放在一个 **kubeconfig 文件** 中，默认位置和搜索顺序是这样的：

1. 如果环境变量 `KUBECONFIG` 被设置，kubectl 就用它指向的文件。
2. 如果没有设置，kubectl 会找 `~/.kube/config`。
3. 如果两者都没有，就会尝试访问 **`http://localhost:8080`**（这是 kubelet 的早期兼容行为，通常没用）。

### 为什么要指向 `/etc/kubernetes/admin.conf`

在 `kubeadm init` 初始化 Kubernetes master 后，会生成 `/etc/kubernetes/admin.conf`：

- 里面包含 **API Server 地址**（通常是 `https://<master-ip>:6443`）
- **客户端证书和密钥**
- **CA 证书**

没有这个配置，kubectl 就不知道要去哪里，也没有凭证去访问 API Server，所以它就退回去尝试 `localhost:8080`

### 那么 ~/.kube/config 文件从哪里来？

既然 kubectl 先找这个文件，那就说明是已经设定好的用这个文件；可是既然是用 /etc/kubernetes/admin.conf 文件中的密钥验证等证书信息，为什么不直接指定这个文件，从这个文件中读取信息！

这其实涉及 **Kubernetes 的客户端配置习惯和权限管理**。

- `~/.kube/config` 是 **kubectl 默认的 kubeconfig 文件**，面向 **普通用户**。
- 当你用 `kubectl` 操作集群时，如果没有显式设置 `KUBECONFIG`，它就会去这个文件里找集群信息、证书和凭证。
- 这样做的好处是 **不用每次都指定 KUBECONFIG**，对普通用户透明。

- `/etc/kubernetes/admin.conf` 这是 **kubeadm 初始化 master 时生成的管理员配置文件**，里面有：
  - cluster 信息（API Server 地址）
  - admin 用户的证书和密钥
  - CA 证书
- 这个文件是 **root 权限的管理员专用配置**，不适合普通用户直接写入 `~/.kube/config`，因为涉及敏感凭证。

---

## 常用排查命令

### Pod 排查

```bash
# 查看 Pod 状态
kubectl get pod

# 查看 Pod 详细信息（最重要）
kubectl describe pod <pod-name>

# 查看 Pod 日志
kubectl logs <pod-name>

# 查看 Pod 崩溃前的日志
kubectl logs <pod-name> --previous

# 进入 Pod 容器
kubectl exec -it <pod-name> -- /bin/sh
```

### Service 排查

```bash
# 查看 Service
kubectl get svc

# 查看 Endpoint
kubectl get ep

# 查看 Service 详细信息
kubectl describe svc <service-name>
```

### Ingress 排查

```bash
# 查看 Ingress
kubectl get ingress

# 查看 Ingress 详细信息
kubectl describe ingress <ingress-name>

# 测试 Ingress Controller
curl -H "Host: <host>" <ingress-controller-ip>
```

### 集群健康检查

```bash
# 检查节点状态
kubectl get nodes

# 检查所有 Pod 状态
kubectl get pods -A

# 检查系统组件
kubectl get pods -n kube-system

# 检查 ConfigMap（关键）
kubectl get cm -n kube-system | grep -E 'kubeadm-config|kubelet-config|kube-proxy'
kubectl get cm -n kube-public cluster-info

# 检查 RBAC
kubectl get clusterrolebinding | grep -E 'node-config-reader|bootstrap'
```

---

## 相关链接

- [[Kubernetes 集群启动顺序]]
- [[Kubernetes 安全体系]]

