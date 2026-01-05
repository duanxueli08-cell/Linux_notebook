前提：

在这个故障之前还发生了另一个故障，导致我对 etc/kubernetes/manifests/kube-apiserver.yaml  文件进行了手工修改；也因此导致后续很多麻烦！
配置文件中原内容：    - --authorization-mode=Node,RBAC
修改后配置文件内容：    - --authorization-mode=AlwaysAllow

`--authorization-mode` 是用来定义集群如何审批 API 请求的。当你为了解决“权限报错”而将其改为 `AlwaysAllow` 时，本质上是关闭了集群的所有权限检查门禁。

虽然这解决了眼下的 `Forbidden` 错误，但会引发一系列非常严重的连锁反应；

1. 核心问题：安全性完全裸奔 （影响于未来）
2. 对集群组件的影响 （影响在当下 k8s 集群运行）

Kubernetes 的许多核心组件（如 `kubelet`、`scheduler`、`controller-manager`）都极度依赖 **Node** 和 **RBAC** 鉴权模式来保证各自的工作边界。

- **Kubelet 状态异常：** 你原本的配置里有 `Node` 模式，这是专门给节点心跳和状态更新用的。改为 `AlwaysAllow` 后，虽然它们还能工作，但你失去了审计这些组件行为的能力。
    
- **插件失效：** 某些依赖特定 RBAC 权限才能运行的 CNI 网络插件或存储插件，可能会因为整体授权逻辑的变化而出现行为异常。

3. “无法回退”的隐患（之后回退，出现的情况与该描述相同，于是开启下面的修复工程）

如果你在 `AlwaysAllow` 模式下创建了大量资源，一旦你将来想改回 `RBAC`，你会发现之前“顺手”部署的很多应用都会因为没有配置对应的 `Role` 和 `RoleBinding` 而集体挂掉。

下面这份你可以直接当 **kubeadm 集群急救手册**。

---

# kubeadm 集群故障 → 修复指令对照表（实战版）

> 适用前提：
> 
> - 控制平面还能访问（`kubectl get nodes` 能跑）
>     
> - etcd 没炸
>     
> - 不想重建集群
>     

---

## 一、worker join 一开始就失败

### ❌ 报错 1：`cluster-info` 相关

#### 典型现象

```text
couldn't get current server API group list
cluster-info not found
no JWS signature
```

#### 根因

- `kube-public/cluster-info` 不存在或无签名
    
- bootstrap token 没配置
    

#### 修复（master）

```bash
kubeadm init phase bootstrap-token
```

#### 验证

```bash
kubectl get cm -n kube-public cluster-info
```

---

## 二、join 时报 `kubeadm-config` 不存在

### ❌ 报错 2

```text
configmaps "kubeadm-config" not found
```

#### 根因

- init 阶段没完整执行
    
- 手动删过 kube-system 里的 CM
    

#### 修复（master）

```bash
kubeadm init phase upload-config kubeadm
```

#### 验证

```bash
kubectl get cm -n kube-system kubeadm-config
```

---

## 三、join 时报 forbidden（RBAC 问题）

### ❌ 报错 3

```text
User "system:bootstrap:xxxx" cannot get resource "configmaps"
```

#### 根因

- bootstrap RBAC 被删 / 未创建
    
- `system:node-config-reader` 缺失
    

---

### 修复步骤（master）

#### 1️⃣ 创建 ClusterRole（如果没有）

```bash
kubectl get clusterrole system:node-config-reader \
|| kubectl create clusterrole system:node-config-reader \
  --verb=get,list,watch \
  --resource=configmaps
```

#### 2️⃣ 创建 ClusterRoleBinding（关键）

```bash
kubectl get clusterrolebinding system:node-config-reader \
|| kubectl create clusterrolebinding system:node-config-reader \
  --clusterrole=system:node-config-reader \
  --group=system:bootstrappers:kubeadm:default-node-token
```

#### 验证

```bash
kubectl describe clusterrolebinding system:node-config-reader
```

必须看到：

```text
Group: system:bootstrappers:kubeadm:default-node-token
```

---

## 四、RBAC 修好后，变成 not found（你最后的坑）

### ❌ 报错 4

```text
configmaps "kubelet-config" not found
configmaps "kube-proxy" not found
```

#### 根因

- init 产物缺失
    
- kubeadm init 没跑完整
    

---

### 修复（master）

#### 1️⃣ 补 kubelet-config

```bash
kubeadm init phase upload-config kubelet
```

验证：

```bash
kubectl get cm -n kube-system kubelet-config
```

---

#### 2️⃣ 补 kube-proxy

```bash
kubeadm init phase addon kube-proxy
```

验证：

```bash
kubectl get cm -n kube-system kube-proxy
```

---

## 五、join 卡在 CSR（证书阶段）

### ❌ 现象

```bash
kubectl get csr
```

看到：

```text
Pending
```

#### 根因

- 自动审批 RBAC 缺失
    
- 或 controller 没权限
    

#### 修复（master）

```bash
kubeadm init phase bootstrap-token
```

或手工审批（临时救急）：

```bash
kubectl certificate approve <csr-name>
```

---

## 六、kubelet 起不来（join 后）

### ❌ 现象

```bash
systemctl status kubelet
```

报证书 / 配置错误

#### 常见修复（node）

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

## 七、一条“健康检查”万能命令（强烈建议）

在 **master** 上跑：

```bash
kubectl get cm -n kube-system | egrep 'kubeadm-config|kubelet-config|kube-proxy'
kubectl get cm -n kube-public cluster-info
kubectl get clusterrolebinding | egrep 'node-config-reader|bootstrap'
```

只要这几样在，**worker join 99% 没问题**。

---

## 八、把这次事故浓缩成一句“运维真理”

> **kubeadm 集群不是“坏在节点”，而是“坏在初始化记忆丢失”**

你这次做的所有修复，本质都是在回答一个问题：

> “新节点加入时，集群还能不能完整回答它的三个问题？”
> 
> - 我是谁？（cluster-info / CA）
>     
> - 你当初怎么建的？（kubeadm-config）
>     
> - 我该怎么跑？（kubelet-config / kube-proxy）
>     

---

