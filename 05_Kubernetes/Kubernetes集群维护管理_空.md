

# Kubernetes集群维护管理笔记

## 1 Kubernetes集群节点管理
### 1.1 节点增操作

#### 📌 前提条件
- 现有集群是用 kubeadm 初始化的。
- 网络插件（如 Calico、Flannel）已正确安装。
- 新节点满足 k8s 节点要求（关闭 swap、安装 container runtime、kubeadm/kubelet/kubectl 等）。
- 已有集群的控制平面未使用外部 etcd（如果是外部 etcd，流程略有不同）。

#### 步骤概览
- 准备新 master 节点环境
- 在原 master 上生成用于加入控制平面的 join 命令
- 在新节点上执行 join 命令加入控制平面
- 验证新 master 是否就绪
- （可选）配置负载均衡器（如 HAProxy + Keepalived）供 kube-apiserver 访问
- 更新 worker 节点的 kubeconfig（如果使用 LB 地址）

#### 具体步骤

**第一步：准备新 master 节点**
在新机器（例如 master2）上执行：

```
# 1. 关闭 swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2. 安装 container runtime（以 containerd 为例）
sudo apt update && sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

# 3. 安装 kubeadm, kubelet, kubectl（版本需与原集群一致！）
kubeadm version
kubelet --version
kubectl version

VERSION=1.34.1  # 替换为你的集群版本
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet=$VERSION-00 kubeadm=$VERSION-00 kubectl=$VERSION-00
sudo apt-mark hold kubelet kubeadm kubectl

# 4. 启动 kubelet
sudo systemctl enable --now kubelet
```

> ⚠️ 注意：确保新节点能解析原 master 主机名，或使用 IP；时间同步（NTP）也应开启。

**第二步：在原 master 上生成 control-plane join 命令**
在 原 master 节点 执行：
```
# 生成加入控制平面的 token 和证书 key
kubeadm init phase upload-certs --upload-certs

# 输出类似于这样的信息
I0104 17:58:27.167244   11086 version.go:260] remote version is much newer: v1.35.0; falling back to: stable-1.34
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
73171e59d018d2621c456910ae8f860b333bda07b84cec72d79877250444ce3a
```
该命令会输出一个 certificate-key（有效期 2 小时，可使用 --ttl 指定更长）。

然后生成 join 命令：
```
kubeadm token create --print-join-command

# 输出类似于这样的信息
kubeadm join kubeapi.wang.org:6443 --token eziet4.2l08uk6wctkaj3k8 --discovery-token-ca-cert-hash sha256:59f295053e6017ef2324c61d290e4f4d0652aad58fbd43f685e85ddc83b7f922
```

**第三步：在新 master 节点执行 join 命令**

手动加上 control-plane 相关参数，在新 master 节点执行该指令，完整 join 命令如下：
```
kubeadm join 10.0.0.101:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:59f295053e6017ef2324c61d290e4f4d0652aad58fbd43f685e85ddc83b7f922 \
  --control-plane \
  --certificate-key 73171e59d018d2621c456910ae8f860b333bda07b84cec72d79877250444ce3a
```
等待完成（可能需要几分钟）。成功后会提示：

>This node has joined the cluster and a new control plane instance was created...

> 注意：该挂梯子该市要挂梯子，不要忘了，不然镜像拉不下来！！！



**第四步（强烈推荐）：配置负载均衡器（LB）**

因为现在有多个 API Server，客户端（包括 kubelet、kubectl、worker 节点）应通过 统一入口 访问。

**第六步：更新 worker 节点 kubeconfig（如果使用了 LB）**

编辑每个 worker 节点上的 /etc/kubernetes/kubelet.conf，将 server: 改为 LB 地址：
```
clusters:
- cluster:
    server: https://<LB-VIP>:6443
```
然后重启 kubelet：
```
sudo systemctl restart kubelet
```

**第五步：授权 Master 管理功能**

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**第六步：验证新 master 是否就绪**

检查节点：
```
kubectl get nodes
```

检查 etcd 成员是否增加：
```
kubectl exec -n kube-system etcd-master1 -- etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  --endpoints=https://127.0.0.1:2379 \
  member list -w table
```

#### 故障问题

**问题**：在已有单 master Kubernetes 集群中添加第二个 master 节点时，`kubeadm join --control-plane` 失败，报错：

```
unable to add a new control plane instance to a cluster that doesn't have a stable controlPlaneEndpoint address
```

**根本原因**：  
原始集群初始化时**未配置 `controlPlaneEndpoint`**（如 `kubeapi.wang.org:6443`），导致 kubeadm 拒绝加入新的 control-plane 节点（多 master 必须有统一 API 入口）。

**解决步骤**：
1. 在原 master 节点导出并编辑 `kubeadm.yaml`，**添加 `controlPlaneEndpoint: "kubeapi.wang.org:6443"`**。
2. 使用 **`kubeadm init phase upload-config kubeadm --config kubeadm.yaml`**（非 `kubectl apply`）更新集群配置。
3. 确保新 master 能解析该域名，并执行正确的 `kubeadm join --control-plane` 命令。

**关键点**：  
- `controlPlaneEndpoint` 是多 master 高可用的前提。  
- kubeadm 配置必须通过 `kubeadm` 命令更新，不能用 `kubectl apply`。

```
# 导出现有 kubeadm 配置
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' > kubeadm.yaml

# 编辑 kubeadm.yaml，添加 controlPlaneEndpoint
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
controlPlaneEndpoint: "kubeapi.wang.org:6443"   # ← 添加这一行

# 重新上传配置到集群
kubeadm init phase upload-config kubeadm --config kubeadm.yaml

# 验证是否生效
kubectl -n kube-system get cm kubeadm-config -o yaml | grep -A 5 "kind: ClusterConfiguration"

# 回到 master2，这次执行 join 命令就能生效了
kubeadm join kubeapi.wang.org:6443 \
  --token eziet4.2l08uk6wctkaj3k8 \
  --discovery-token-ca-cert-hash sha256:59f295053e6017ef2324c61d290e4f4d0652aad58fbd43f685e85ddc83b7f922 \
  --control-plane \
  --certificate-key 73171e59d018d2621c456910ae8f860b333bda07b84cec72d79877250444ce3a
```


### 1.2 节点删操作




## 2 Kubernetes集群备份与还原
### 2.1 容灾架构与方案
- 明确容灾目标与策略，覆盖备份恢复、主备（Active-Standby）、双活（Active-Active）架构设计。

### 2.2 备份还原方法
- 提供4类备份方案：
  - 备份指定Kubernetes资源；
  - 备份ETCD（核心存储）；
  - 备份持久化存储数据；
  - 工具自动化备份（如Velero）。

### 2.3 ETCD备份与还原
- **ETCD基础**：详解特性、应用场景、版本、架构、核心组件及工作原理（含Leader选举、数据一致性、读写流程等）。
- **工具操作**：etcdctl/etcdutill的安装（二进制/包安装注意事项）、使用说明。
- **实战案例**：etcdctl实现ETCD备份还原的流程说明，及kubesasz项目的备份范例。

### 2.4 Velero工具应用
- **Velero简介**：功能（集群备份/恢复/迁移）、与ETCD备份的差异、组件架构、工作流程及存储后端支持。
- **部署与配置**：
  - Velero CLI二进制安装、命令使用；
  - 集成MinIO存储（单机单磁盘/容器化部署范例、Bucket创建、权限配置）；
  - Velero Server安装/卸载流程。
- **备份恢复案例**：
  - 数据备份（命令说明、测试应用备份支持范围、定时备份）；
  - 数据恢复（模拟灾难、资源恢复验证）；
  - 跨集群迁移（迁移前准备、新集群Velero配置、数据恢复验证）。

## 3 Kubernetes证书管理
### 3.1 证书机制与有效期
- 证书分类：根CA、API Server、ETCD、Kubelet、前端代理、用户配置等证书。
- 证书查看：默认证书有效期的查询方法。

### 3.2 证书续期（未过期时）
- 提供证书续期的流程与操作步骤。

### 3.3 证书过期故障解决
- Kubelet证书过期处理：含“证书已过期”场景的修复范例。
- 终极方案：“永久有效”证书配置（需结合合规性需求）。

## 4 Kubernetes版本升级
### 4.1 升级流程
- 准备工作：集群版本检查、升级路径确认、集群备份。
- 控制平面升级：kubeadm升级流程。
- 工作节点升级：驱逐节点、升级二进制、验证版本。
- 验证与问题处理：集群状态/组件版本检查、升级失败/节点无法加入集群的解决方案。

### 4.2 升级范例
- **Master节点**：下线服务、验证版本、升级kubeadm/kubectl、执行升级计划、开始升级、验证完成、升级其他Master节点。
- **Worker节点**：冻结驱逐请求、升级二进制、执行升级、恢复节点调度、逐个升级验证。



## 5 Kubernetes 集群性能优化

可以在每个worker节点都配置各自的负载均衡服务，从而避免集中的负载均衡器的性能瓶颈
