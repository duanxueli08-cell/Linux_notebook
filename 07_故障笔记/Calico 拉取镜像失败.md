
---

# 🧾 故障复盘总结：`node3` 上 Calico Pod 因镜像拉取失败无法启动

## 一、故障现象

- **时间**：2025年12月30日  
- **影响节点**：`node3`（仅此节点）  
- **受影响组件**：`calico-node-c9sgd`（`kube-system` 命名空间）  
- **Pod 状态**：`ImagePullBackOff`  
- **错误日志关键信息**：
  ```
  Failed to pull image "quay.io/calico/cni:v3.31.3": 
  proxyconnect tcp: dial tcp 10.0.0.1:7897: connect: connection refused
  ```

> 其他节点（如 `node1`、`node2`）运行完全正常，相同镜像可成功拉取。

---

## 二、根因分析（Root Cause）

✅ **根本原因**：  
`node3` 节点上的 `containerd` 服务被 **通过 systemd 配置了无效的 HTTP/HTTPS 代理**，指向 `http://10.0.0.1:7897`，而该代理服务 **未运行或已关闭**，导致所有通过 containerd 拉取外网镜像的操作失败。

🔧 **配置位置**：
```bash
/etc/systemd/system/containerd.service.d/http-proxy.conf
```

内容示例：
```ini
[Service]
Environment="HTTP_PROXY=http://10.0.0.1:7897"
Environment="HTTPS_PROXY=http://10.0.0.1:7897"
Environment="NO_PROXY=localhost,127.0.0.1,..."
```

> ⚠️ 此配置 **仅作用于 containerd 进程**，不影响 shell 环境变量或 `curl` 等命令，因此造成“`curl` 能通但 `crictl pull` 失败”的迷惑现象。

---

## 三、排查过程（关键步骤）

| 步骤 | 操作 | 发现 |
|------|------|------|
| 1 | 对比 `node2`（正常）与 `node3`（异常）的环境变量 | `env \| grep -i proxy` 均为空 → 排除 shell 层代理 |
| 2 | 检查 containerd 配置文件 | 两者 `/etc/containerd/config.toml` 无 proxy 相关配置 |
| 3 | 手动测试网络连通性 | `curl https://quay.io/v2/` 在两节点均成功 → 网络/DNS/TLS 正常 |
| 4 | 手动拉取镜像 | `crictl pull` 在 `node2` 成功，在 `node3` 报代理连接拒绝 |
| 5 | 检查 containerd 的 systemd 环境 | `systemctl show --property=Environment containerd` → **发现 node3 有代理设置** |
| 6 | 定位配置文件 | 发现 `/etc/systemd/system/containerd.service.d/http-proxy.conf` |

🔍 **排查方法亮点**：  
采用 **横向对比法**（正常 vs 异常节点），快速缩小范围至节点本地配置差异。

---

## 四、解决方案

### ✅ 操作步骤
```bash
# 1. 删除无效代理配置
sudo rm /etc/systemd/system/containerd.service.d/http-proxy.conf

# 2. 重载 systemd 并重启 containerd
sudo systemctl daemon-reload
sudo systemctl restart containerd

# 3. 验证环境变量已清除
systemctl show --property=Environment containerd  # 应返回空

# 4. 验证镜像拉取
crictl pull quay.io/calico/cni:v3.31.3  # 应成功

# 5. 触发 Pod 重建
kubectl delete pod -n kube-system calico-node-c9sgd
```

### ✅ 验证结果
- `crictl pull` 成功；
- 新 Pod 状态变为 `Running`；
- 节点网络功能恢复正常。

---

## 五、经验教训

1. **容器运行时代理配置具有隐蔽性**  
   - systemd 服务级的 `Environment` 不会反映在用户 shell 的 `env` 中；
   - Go 编写的程序（如 containerd）会读取这些环境变量，而传统工具（如 curl）不会。

2. **单节点故障优先排查本地配置差异**  
   - 当集群中仅一个节点异常时，应重点对比其与正常节点的：
     - systemd override 配置
     - `.docker/config.json`
     - 容器运行时配置
     - 内核参数/网络策略

3. **代理配置应统一管理，避免手动残留**  
   - 临时调试用的代理配置必须及时清理；
   - 建议通过基础设施即代码（IaC）工具（如 Ansible、Terraform）统一管理节点配置。

---

## 六、改进建议（Prevention）

| 类别 | 建议 |
|------|------|
| **配置管理** | 禁止手动修改节点 systemd 配置；所有变更需通过 GitOps 或配置管理工具实施 |
| **镜像策略** | 生产环境应使用 **私有镜像仓库（如 Harbor）**，避免直接依赖 `quay.io`、`docker.io` 等公网源 |
| **监控告警** | 增加对 `ImagePullBackOff` 事件的监控（如 Prometheus + kube-state-metrics + Alertmanager） |
| **健康检查** | 在节点加入集群前，执行预检脚本，检查：<br> - containerd 是否能拉取关键镜像<br> - 是否存在意外代理配置 |
| **文档记录** | 建立《Kubernetes 节点标准化配置清单》，明确禁止项与必选项 |

---

## 七、附录：关键命令速查

```bash
# 查看 containerd 实际运行环境
systemctl show --property=Environment containerd

# 查看 systemd override 配置目录
ls /etc/systemd/system/containerd.service.d/

# 手动拉取镜像（验证 CRI）
crictl pull <image>

# 清理卡住的 Pod
kubectl delete pod -n <namespace> <pod-name>
```

---

✅ **结论**：  
本次故障由 **单节点残留的无效代理配置** 引起，通过系统性对比排查快速定位并修复。后续可通过 **标准化配置 + 私有镜像仓库 + 自动化监控** 避免同类问题复发。

--- 
