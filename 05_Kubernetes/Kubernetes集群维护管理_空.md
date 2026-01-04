

# Kubernetes集群维护管理笔记

## 1 Kubernetes集群节点管理
### 1.1 节点增删操作
- **Master节点**：覆盖添加/删除流程，含删除Master时的etcd信息清理、添加Master的命令获取、节点重新加入集群及权限授权。
- **Worker节点**：明确新增/删除流程，含“删除后重新加入Worker节点”的实操范例。
- **Token管理**：提供查看当前token、重生token的操作方法。

#### 删除其中一个 Master 节点
注意：删除Master节点后，要保留至少半数以上个Master节点，否则集群失败
~~~powershell
# 在保留的其中一个节点上 master1 执行下面操作，指定删除master3.wang.org 节点
kubectl drain master3.wang.org --ignore-daemonsets
kubectl delete node master3.wang.org
# 在 master3 执行删除本机上面的信息
kubeadm reset -f --cri-socket=unix:///run/cri-dockerd.sock
rm -rf /etc/cni/net.d/ ~/.kube /etc/kubernetes
apt -y remove kubeadm kubelet kubectl
# 建议重启清理环境
reboot
~~~


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
