

# 1. Pod 基础概念（必须背会的定义）

### Pod 是什么？

Pod 是 **Kubernetes 调度的最小单位**，由至少两个容器组成：

- **Pause 容器（基础容器）**
    
    - 负责创建 Pod 的所有共享 Namespace（网络、IPC、UTS）
        
    - 永远最先启动，永远最后退出
        
- **业务容器（你的应用）**
    
    - 真正跑业务代码
        

👉 **所以一个 Pod 最少有两个容器，这是 Kubernetes 的设计。**

### Kubernetes 里的重启不是 Restart，而是 Re-create

凡是容器退出，它就消失了，所谓重启就是“删除老容器 → 创建新容器”。

---

# 2. Pod 的状态与生命周期（面试高频）

## 2.1 Pod 的五种状态（kubectl get pod 可见）

|状态|含义|
|---|---|
|**Pending**|Pod 已提交，调度未完成；或镜像拉取中|
|**Running**|已调度 + 容器正在运行|
|**Succeeded**|所有容器以 0 退出码结束（任务类 Pod）|
|**Failed**|有容器异常退出（非 0），或被 OOM/Kill|
|**Unknown**|Kubelet 与 APIServer 失联，状态未知|

---

## 2.2 Pod 启动流程（condition，面试常考）

`kubectl describe pod` 可看到 Condition

|Condition|含义|
|---|---|
|**PodScheduled**|调度器已将 Pod 分配给某节点|
|**Initialized**|Init 容器全部执行完成|
|**ContainersReady**|业务容器全部 Ready|
|**Ready**|Pod 对外提供服务，加入 Service LB|

👉 **“Unschedulable”** 是调度失败事件，不是 Condition。

---

# 3. Pod 的健康检查（核心考点）

Kubernetes 提供三种探针（Health Probe）：

|Probe|用途|失败结果|
|---|---|---|
|**LivenessProbe**|判断容器是否存活|重启容器|
|**ReadinessProbe**|判断是否可对外提供服务|从 Service 中摘除|
|**StartupProbe**|判断是否完成启动|未通过前不执行 liveness/readiness|

---

## 3.1 探针的三种实现方式（必须背）

|类型|描述|
|---|---|
|**Exec**|执行命令，返回 0 表示通过|
|**HTTPGet**|访问 HTTP(Https) URL，2xx/3xx 成功|
|**TCPSocket**|端口能连通即成功|

---

# 4. Pod 的资源限制（高频：生产配置 + 面试底层原理）

Pod 的资源控制分为两个维度：

|资源|request|limit|
|---|---|---|
|**CPU**|调度依据|运行上限（节流）|
|**Memory**|优先分配标识|运行上限（超出直接 OOM）|

---

## 4.1 配置示例（requests 与 limits）

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

---

## 4.2 CPU 限制原理（CGroup）

CPU 超 limit → **被节流（throttle）**

底层使用：

- cpu.shares（对应 request）
    
- cpu.cfs_quota_us（对应 limit）
    
- cpu.cfs_period_us
    

CPU 不会被杀。

---

## 4.3 Memory 限制原理（CGroup）

超 limit：

- Linux 内核 OOM Killer 杀掉容器
    
- Pod 状态显示：`OOMKilled`
    

内存不是限速，是“撞线就死”。

---

## 4.4 LimitRange（生产常用）

作用：

1. **控制资源最小值 / 最大值**
    
2. **给 Pod 自动注入默认 requests/limits**
    

如果业务方提交一个空资源 Pod：

- LimitRange 会自动填充值
    
- 避免把节点资源用光
    

生产最佳实践：

- 每个 Namespace 必须配置 **LimitRange + ResourceQuota**
    
- 建议 request ≈ limit（更好调度，也更稳定）
    

---

# 5. Pod 生命周期钩子（Hooks）

两种钩子：

|Hook|时机|常见用途|
|---|---|---|
|**postStart**|容器启动后立即执行|预热、注册、准备环境|
|**preStop**|容器退出前执行|优雅退出、清理任务、同步状态|

执行流程：

1. 运行 preStop
    
2. 发 SIGTERM
    
3. 等待 terminationGracePeriodSeconds（默认 30s）
    
4. 超时未退出 → SIGKILL
    

---

# 6. Pod 与 Docker Namespace 的区别（面试常考）

**K8s Namespace：集群资源逻辑隔离（管理层）**  
**Docker Namespace：Linux 内核隔离机制（运行层）**

Docker 六大 Namespace：

- PID
    
- UTS
    
- IPC
    
- Mount
    
- Network
    
- User
    

---

# 7. Pod 创建流程（完整链路）

**这是面试必问，必须顺口能讲**

1. 用户发送 `kubectl apply`
    
2. API Server 校验 → 写入 etcd
    
3. Scheduler 监听到新 Pod → 选择节点 → 写回 API Server
    
4. 节点 kubelet 监听到任务 → 调用 containerd/cri-o
    
5. 拉镜像、启动 pause → 启动业务容器
    
6. kubelet 上报状态 → API Server → etcd
    
7. 用户查询 Pod 状态（来自 etcd）
    

---

# 8. Pod 排错思路（生产非常有用）

常用命令：

```
kubectl get pod -A
kubectl describe pod xxx
kubectl logs xxx
kubectl exec -it xxx -- sh
kubectl get pod xxx -o yaml
```

Pending 常见原因：

- request 资源太大，无节点可调度
    
- 镜像拉取失败（仓库、鉴权）
    
- 缺 CNI 插件（Flannel/Cilium）
    
- 节点 taint 但无对应 toleration
    

---
