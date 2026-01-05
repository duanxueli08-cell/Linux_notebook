
# Kubernetes集群维护管理笔记

## 1 Kubernetes集群节点管理
### 1.1 Master 节点增操作

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
I0105 11:54:48.629882   44784 version.go:260] remote version is much newer: v1.35.0; falling back to: stable-1.34
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
106fe9dd03c90daea172d29a775baa8867a8a326a6e04bbf8522028e20c2de7a
```
该命令会输出一个 certificate-key（有效期 2 小时，可使用 --ttl 指定更长）。

然后生成 join 命令：
```
kubeadm token create --print-join-command

# 输出类似于这样的信息
kubeadm join kubeapi.wang.org:6443 --token nq9vzk.x08k4e417s48wzk6 --discovery-token-ca-cert-hash sha256:65b75caa165d8bace6bd59cf7d306eb002658b179e8062ac67f8a31010733cb6 
```

**第三步：在新 master 节点执行 join 命令**

手动加上 control-plane 相关参数，在新 master 节点执行该指令，完整 join 命令如下：
```
kubeadm join kubeapi.wang.org:6443 \
  --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:65b75caa165d8bace6bd59cf7d306eb002658b179e8062ac67f8a31010733cb6  \
  --control-plane \A
  --certificate-key 106fe9dd03c90daea172d29a775baa8867a8a326a6e04bbf8522028e20c2de7a
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


### 1.2 Master 节点删操作

- 应用场景：当一个Master出现故障时,需要添加或删除Master节点操作,从而修复节点后, 再重新加入集群,避免 ETCD 错误
- 注意：删除Master节点后，要保留至少半数以上个Master节点，否则集群失败。

#### 操作步骤

**在原 master 节点（master1）上驱逐新 master 上的 Pod 并删除节点**
```
# 1. 查看节点状态（确认 master2 已加入）
kubectl get nodes

# 2. 驱逐 master2 上的 Pod（包括系统组件）
kubectl cordon master2  # 标记节点不可调度
kubectl drain master2 --ignore-daemonsets --delete-emptydir-data

# 3. 删除节点
kubectl delete node master2
```

**在要删除的 master 节点（master2）上执行 kubeadm reset**
```
# 停止 kubelet 并重置 k8s 配置
sudo kubeadm reset -f

# 停止 kubelet 服务
sudo systemctl stop kubelet

# 清理配置文件
sudo rm -rf /etc/kubernetes/
sudo rm -rf ~/.kube/

# 清理 CNI 网络配置
sudo rm -rf /etc/cni/net.d/
sudo rm -rf /var/lib/cni/

# 清理 iptables 规则
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# 重启 container runtime
sudo systemctl restart containerd   # 或 docker
```

**在原 master 节点（master1）上从 etcd 集群中移除该节点**

>🔑 关键步骤：确保 etcd 成员也被清理

```
# 1. 获取 etcd pod 名称（通常在 master1 上）
kubectl -n kube-system get pods | grep etcd

# 2. 检查 etcd 成员列表
kubectl exec -n kube-system etcd-master1.wang.org -- etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  --endpoints=https://127.0.0.1:2379 \
  member list -w table
```

找到 master2 对应的 etcd 成员 ID，然后删除：
```
kubectl exec -n kube-system etcd-master1.wang.org -- etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  --endpoints=https://127.0.0.1:2379 \
  member remove <member-id-of-master2>
```

>💡 <member-id-of-master2> 是上一步 member list 中 master2 对应的 ID（如 8a8a8a8a8a8a8a8a）

**验证集群状态**
```powershell
# 1. 检查节点数量
kubectl get nodes
# 应该只有 master1 + 3 个 worker

# 2. 检查 etcd 成员
kubectl exec -n kube-system etcd-master1.wang.org -- etcdctl \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  --endpoints=https://127.0.0.1:2379 \
  member list -w table
# 应该只显示 master1 的 etcd 成员
```

#### 🛠️ 补充说明

- kubectl drain：确保该节点上的 Pod 被安全迁移（对于 control-plane Pod，实际上会直接删除）
- kubeadm reset：清理 kubelet、证书、manifests 等，恢复到未加入集群状态
- etcd member remove：必须手动执行，否则 etcd 集群中仍有该节点的记录，可能影响健康状态

### 2 添加和删除 Worker 节点

#### 添加新节点（worker）

📌 总结流程
-	新节点安装 containerd 并配置 systemd cgroup
-	禁用 swap，加载内核模块
-	安装 kubelet/kubeadm（版本匹配）
-	Master 生成 kubeadm join 命令
-	新节点执行 join 命令
-	验证 kubectl get nodes

准备步骤参考：[[Kubernetes 大笔记#containerd 安装（主流）]] 



在 master 节点添加新节点的域名解析；

在 master 节点生成 join 命令
```
kubeadm token create --print-join-command
```

在新节点执行 join 命令
```
kubeadm join kubeapi.wang.org:6443 --token 4jvw0r.bbuo12wdw3kdwxgp \
        --discovery-token-ca-cert-hash sha256:65b75caa165d8bace6bd59cf7d306eb002658b179e8062ac67f8a31010733cb6
```

验证节点加入
```
kubectl get nodes &&  kubectl get pod -A -o wide
```

可选：打标签或污点（按需）
```
kubectl label node new-worker-node role=worker
# 或
kubectl taint node new-worker-node key=value:NoSchedule
```


#### 删除工作节点（worker）
步骤 1：将节点标记为不可调度（cordon）
> 防止新 Pod 被调度到该节点：

```
kubectl cordon node4
```


步骤 2：驱逐节点上的所有 Pod（drain）
将该节点上所有可驱逐的 Pod 安全迁移到其他节点（StatefulSet、DaemonSet 等需特殊处理）：
```
kubectl drain node4 --ignore-daemonsets --delete-emptydir-data
```
1. --ignore-daemonsets：跳过 DaemonSet 管理的 Pod（如 Calico、kube-proxy），它们会在节点删除后自动消失。
2. --delete-emptydir-data：允许删除使用 emptyDir 的临时数据（K8s 默认拒绝驱逐这类 Pod，除非明确允许）。
3. 如果有本地存储或关键应用，建议先确认业务容忍度。


步骤 3：从集群中删除节点对象
```
kubectl delete node node4
```


步骤 4：在被删除的节点上重置 kubeadm（可选但推荐）
>目的：清理 kubelet、containerd 中残留的 Kubernetes 状态，便于重用或彻底退役。

登录到该 node4 节点，执行：
```
# 重置 kubeadm 状态
sudo kubeadm reset --cri-socket unix:///run/containerd/containerd.sock

# 清理 iptables 规则（可选）
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# 清理 CNI 配置（可选）
sudo rm -rf /etc/cni/net.d/

# 重启 containerd（可选）
sudo systemctl restart containerd
```
- 💡 注意：--cri-socket 参数指定 containerd 的 socket 路径（默认为 /run/containerd/containerd.sock），kubeadm v1.24+ 必须显式指定（因不再默认使用 Docker）。


步骤 5：验证
回到 master 节点：
```
kubectl get nodes
```




## Kubernetes集群备份与还原
### 容灾架构与方案

Kubernetes 集群的容灾架构旨在保障在发生节点故障、区域中断或灾难性事件时，应用服务仍能持续运行或快速恢复。根据业务连续性要求的不同，常见的容灾方案包括：

> 💡 实际生产中常采用 “双活 + 备份” 组合策略：双活保障高可用，备份应对逻辑错误（如误删、勒索软件）。

一、主备（Active-Standby）架构
> ⚠️ 注意：主备模式下需解决数据同步延迟和**脑裂（Split-brain）**问题。

1. 架构说明
- 主集群：承载全部生产流量，正常对外提供服务。
- 备用集群：处于待命状态，不处理业务流量（或仅同步数据），当主集群发生故障时接管服务。
2. 适用场景
- 对 RTO（恢复时间目标）有一定容忍度（分钟级到小时级）。
- 成本敏感型业务，希望节省备用资源开销。
3. 主流解决方案
Velero + 多集群部署：使用 Velero 定期备份主集群资源，在备用集群中恢复。
Rancher Fleet / Argo CD：通过 GitOps 工具保证主备集群配置一致性。


二、双活（Active-Active）架构
> 优势：无缝故障转移、提升资源利用率。
> 挑战：数据一致性、网络延迟、复杂调试。

1. 架构说明
- 两个或多个集群同时处理生产流量，互为备份。
- 要求应用具备无状态性或分布式一致性机制（如多主数据库）。
2. 适用场景
- 高可用性要求极高（RTO ≈ 0，RPO ≈ 0）。
- 全球化部署，需就近服务用户。
3. 主流解决方案
- Istio Multi-Cluster Mesh：通过服务网格实现跨集群服务发现与流量管理，支持 locality-aware routing。
- Linkerd Multi-Cluster：轻量级服务网格，支持跨集群通信。


三、备份与恢复（Backup & Restore）
1. 架构说明
- 不依赖实时备用集群，而是定期对集群配置（YAML）、PV 数据、etcd 状态等进行快照备份。
- 在灾难发生后，从备份中重建集群或恢复关键应用。
2. 适用场景
- 中小企业或非核心业务系统。
- 合规性要求（如 GDPR、等保）需保留历史快照。
- 作为主备/双活架构的补充手段。
3. 主流解决方案
Velero（原 Heptio Ark）：
- 支持集群资源（Deployments、Services 等）和持久卷（PV）的备份与恢复。
- 可跨云/跨集群迁移。
- 支持定时备份、增量备份、钩子脚本（pre/post backup hooks）。
etcd snapshot + kubeadm restore：
- 直接备份 etcd 数据，适用于控制平面灾难恢复。
- 操作复杂，需精确匹配 Kubernetes 版本。
Restic / Rclone + 自定义脚本：用于备份 PV 中的文件数据。





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
