# 🛡️ Kubernetes 安全体系全流程手册

> 目标：从零构建一个具备认证、授权、准入控制的完整安全访问模型

---

## 第一章：认证

认证（Authentication）—— “你是谁？”

K8s 支持多种认证方式，最常用的是 **X509 证书** 和 **静态 Token**。所有认证方式最终都会映射为 **User + Groups**。

### 1.1 基于 X509 证书创建用户（UA）

```powershell
# 创建 test 用户证书（属于 ops 组）
mkdir -p pki
(umask 077; openssl genrsa -out pki/test.key 4096)
# 生成证书申请 （ 加入的 ops 组只具有普通权限 ）
openssl req -new -key pki/test.key -out pki/test.csr -subj "/CN=test/O=ops"
# 使用 kubernetes-ca 颁发证书
openssl x509 -req -days 3650 \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -in pki/test.csr -out pki/test.crt

# 测试（无权限）
curl --cert pki/test.crt --key pki/test.key \
  --cacert /etc/kubernetes/pki/ca.crt \
  https://kubeapi.wang.org:6443

# 若需管理员权限，重新签发（加入 system:masters 组）
openssl req -new -key pki/test.key -out pki/test.csr -subj "/CN=test/O=system:masters"
# 重签证书...
openssl x509 -req -days 3650 -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -in pki/test.csr -out pki/test.crt
# 测试 (访问应该成功)
curl --cert pki/test.crt --key pki/test.key --key-type PEM --cacert /etc/kubernetes/pki/ca.crt https://kubeapi.wang.org:6443
```

> 💡 **关键原理**：  
> - `CN=test` → 用户名是 `test`  
> - `O=ops` 或 `O=system:masters` → 用户组  
> - K8s 内置 `ClusterRoleBinding` 将 `system:masters` 绑定到 `cluster-admin`，故拥有全权

---

### 1.2 基于静态 Token 创建用户（UA）

基于静态 token 令牌向 API Server 添加认证用户

```powershell
# 创建 token 文件
mkdir -p /etc/kubernetes/auth
# 创建静态令牌文件并添加用户信息
echo "$(openssl rand -hex 3).$(openssl rand -hex 8),wang,1001,system:masters" > /etc/kubernetes/auth/token.csv
echo "$(openssl rand -hex 3).$(openssl rand -hex 8),test,1002,dev" >> /etc/kubernetes/auth/token.csv

# 修改 apiserver 启动加载文件 ( 最好做个备份 ) ( 不要将下面的注释复制进去 )
cp /etc/kubernetes/manifests/kube-apiserver.yaml /root/
vi /etc/kubernetes/manifests/kube-apiserver.yaml
spec:
  containers:
  - command:
    - kube-apiserver
    - --token-auth-file=/etc/kubernetes/auth/token.csv # 加一行，指定前面创建文件的路径

  volumeMounts:o
    - mountPath: /etc/kubernetes/auth			# 添加三行,实现数据卷的挂载配置,注意：此处是目录
      name: static-auth-token
      readOnly: true

  volumes:
  - hostPath: 						# 添加四行数据卷定义
      path: /etc/kubernetes/auth 	# 注意：此处是目录
      type: DirectoryOrCreate
    name: static-auth-token

# 测试
TOKEN="xxx.yyy"
curl -k -H "Authorization: Bearer $TOKEN" https://kubeapi.wang.org:6443
kubectl --server=https://kubeapi.wang.org:6443 \
        --token="$TOKEN" \
        --insecure-skip-tls-verify=true \
        get pods -A
```

```powershell
ps aux | grep auth
# 查看生成的 token
cat /etc/kubernetes/auth/token.csv
# 测试
TOKEN="fd9745.e454c4f5f57bd54b";
curl -k -H "Authorization: Bearer $TOKEN" https://kubeapi.wang.org:6443 
# 在 node 节点拿到 token 就可以访问 kube apiserver 了
TOKEN="1a2dab.6895748fd9e46182" 
kubectl --server=https://kubeapi.wang.org:6443 \
        --token="$TOKEN" \
        --insecure-skip-tls-verify=true \
        get pods -A
或者不指定认证
kubectl -s "https://kubeapi.wang.org:6443" --token="$TOKEN" --insecure-skip-tls-verify=true get pod -A
```

```powershell
进一步测试
# 可以看到 kebectl 是独立的二进制程序
ll /usr/bin/kubectl 
# 传到集群外的主机中
scp /usr/bin/kubectl 10.0.0.107:/usr/local/bin/
# 进入 107 这个主机；定义 token ；
TOKEN="fd9745.e454c4f5f57bd54b";
kubectl -s "https://10.0.0.101:6443" --token="$TOKEN" --insecure-skip-tls-verify=true get pod -A
# 由此可以看出在 k8s 集群外管理 k8s 集群的前景，并且可以延伸到在 Windows 系统通过图形界面管理 k8s 集群
# 用户一多，那么证书、token 管理就是麻烦，这就不得不说 kubeconfig 管理了！
```

> ⚠️ 注意：静态 Token 已被官方标记为 **legacy**，生产环境推荐使用 **OIDC** 或 **Webhook Token**。

---

### 1.3 理解 kubeconfig —— 认证的“配置中心”

- `admin.conf` 本质上是一个 **Kubeconfig** 文件。它就像是你进出 K8s 集群的“通关文牒”和“私钥大礼包”。
- `admin.conf` 拥有集群的 **最高权限（Root）**
- 当你把这个文件拿到从节点，执行 `kubectl` 命令时，它会读取这些信息，证明“我是谁”以及“我要去哪”，API Server 验明正身之后，就会放行。

`admin.conf` 是 kubeconfig 的典型例子，包含三要素：

#### Clusters（你要去哪？）
```yaml
clusters:
- cluster:
    certificate-authority-data: LS0t...  # Base64 编码的 CA 证书
    server: https://kubeapi.wang.org:6443
  name: kubernetes
```

> -  **server**: 这是最关键的。它告诉 `kubectl`：你要访问的集群“大门”在 `kubeapi.wang.org` 的 6443 端口。如果你在办公网环境，这个域名必须能解析到你 Master 节点的 IP，否则就会报 `getsockopt: connection refused`。
> -  **certificate-authority-data**: 这是集群 CA 根证书的 Base64 编码。它的作用是**“验证服务器”**。当你访问 API Server 时，`kubectl` 会用这段数据去验证服务端给出的证书合不合法，防止你连到了黑客伪造的 API Server 上（防中间人攻击）。

#### Users（你是谁？）

```yaml
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0t...   # 客户端证书（含 CN/O）
    client-key-data: LS0t...           # 私钥
```

> 🔍 解码证书查看身份：
> ```bash
> echo "LS0t..." | base64 -d | openssl x509 -text -noout
> # Subject: O = system:masters, CN = kubernetes-admin
> ```
>
> 1. **name**: 叫 `kubernetes-admin`。
> 2. **client-certificate-data**: 你的“身份证”。API Server 拿到这个后，会解密看里面的内容。
> 3. **重点（用户组和用户）**： 虽然你在 YAML 里看到名字叫 `kubernetes-admin`，但 K8s 内部真正识别你权限的，是**签发这个证书时写进里面的 CN (Common Name) 和 O (Organization)**。
>
> 
>
> - **CN (kubernetes-admin)** 就是**用户名**。
> - **O (system:masters)** 就是**用户组**。
> - **为什么权限这么大？** 因为 K8s 内置了一个默认的 RBAC 策略（ClusterRoleBinding），把 `system:masters` 这个组绑定到了 `cluster-admin` 这个最高权限的角色上。所以，**只要你拿着这个证书，你就是集群的 Root。**

#### Contexts（身份 + 集群 的组合）
```yaml
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
```

> - **Context** 就像是一个“拨号配置”。你可以定义很多个 Context（比如一个连生产环境，一个连测试环境），通过 `kubectl config use-context` 像切换频道一样在不同集群间切换。
> - **current-context**: 决定了当你直接敲 `kubectl get pod` 时，默认走哪个配置。

#### 手动生成 kubeconfig（给 token 用户）

```powershell
kubectl config set-cluster myk8s \
  --server=https://10.0.0.101:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig ./mykube.conf
# 确认之前创建的 token 用户信息
cat /etc/kubernetes/auth/token.csv
# 定义User:添加身份凭据，使用静态令牌文件认证的wang用户的令牌令牌
TOKEN="xxx.yyy"
mkdir $HOME/kubeconfig-test
kubectl config set-credentials wang --token="$TOKEN" --kubeconfig $HOME/kubeconfig-test/mykube.conf
# 定义Context:为用户wang的身份凭据与kube-test集群建立映射关系
kubectl config set-context wang@myk8s \
  --cluster=myk8s --user=wang --kubeconfig .$HOME/kubeconfig-test/mykube.conf
# 查看生成的信息 （其实我认为手动修改更方便）
cat $HOME/kubeconfig-test/mykube.conf
```

```powershell
# 测试：将文件传到 107 主机
scp /root/kubeconfig-test/mykube.conf 10.0.0.107:/root
# 进入 107 主机访问 kube apiserver
kubectl config use-context wang@myk8s --kubeconfig /root/mykube.conf
# 将文件放入默认路径下，这样每次访问就不用手动指定文件了
mkdir $HOME/.kube  ; cp $HOME/mykube.conf $HOME/.kube/config
# 通过指令或者编辑文件，将对应的用户 myk8s 设为默认值
vi $HOME/.kube/config
current-contest: myk8s
# 如此这般……这般，就可以这样了！( 实现并管理 k8s 集群外访问 k8s 的用户 )
kubectl get pod -A
```

> **结论**：kubeconfig 是 **UA 用户访问集群的标准载体**。
>
> ```powershell
> kubectl / helm / k9s ————> kubeconfig ————> api-server
> ```

---

## 第二章：授权

授权（Authorization）—— “你能做什么？”

K8s 默认启用 **RBAC**（基于角色的访问控制）。

### 2.1 RBAC 四大对象

| 对象               | 作用                           | 范围         |
| ------------------ | ------------------------------ | ------------ |
| Role               | 定义命名空间内权限             | Namespaced   |
| ClusterRole        | 定义集群级权限                 | Cluster-wide |
| RoleBinding        | 绑定用户到 Role（限 ns）       | Namespaced   |
| ClusterRoleBinding | 绑定用户到 ClusterRole（全局） | Cluster-wide |

### 案例一：role 绑定

创建 Role（命名空间权限模板）

```powershell
# 命令式创建（dry-run 生成 YAML）
kubectl create role pods-viewer \
  --verb=get,list,watch \
  --resource=pods,services,deployments \
  --namespace=dev \
  --dry-run=client -o yaml > role-pods-viewer.yaml
```

常见 verbs 含义：
| verb                       | 含义         |
| -------------------------- | ------------ |
| get                        | 获取单个资源 |
| list                       | 列出资源     |
| watch                      | 监听变更     |
| create/update/patch/delete | 增删改       |

绑定用户到权限（RoleBinding）

```yaml
cat > rolebinding-wang.yaml <<'eof'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: wang-pod-reader
  namespace: dev
subjects:
- kind: User
  name: wang       # ← 来自 token.csv 或证书 CN
  apiGroup: ""
roleRef:
  kind: Role
  name: pods-viewer
  apiGroup: rbac.authorization.k8s.io
eof
```
```bash
kubectl apply -f role-pods-viewer.yaml
kubectl apply -f rolebinding-wang.yaml
```

> **最佳实践**：用 `ClusterRole` 定义通用权限模板，用 `RoleBinding` 在各 ns 中引用（降权复用）

### 案例二：混合绑定

使用 `ClusterRole` + `RoleBinding`（推荐生产方式）

> 优势：  
>
> - `ClusterRole` 可被多个命名空间复用（例如 dev/staging/prod 都可绑定同一个 ClusterRole）  
> - 权限集中管理，避免重复定义 Role  
> - 符合最小权限原则（通过 RoleBinding 限制作用域）

1. 创建 ClusterRole（集群范围的角色定义）

```yaml
cat > clusterrole-pods-viewer.yaml <<'eof'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pods-viewer-cluster  # 全局唯一名称
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
eof
```

> 📌 注意：
>
> - `ClusterRole` 没有 `namespace` 字段（它是集群级别的）
> - 资源分组：`pods/services` 属于核心 API 组（`""`），`deployments` 属于 `apps` 组

2. 在 `dev` 命名空间中创建 RoleBinding，绑定用户到该 ClusterRole

```yaml
cat > rolebinding-wang-dev.yaml <<'eof'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: wang-pods-reader-in-dev
  namespace: dev  # ← 权限仅在此命名空间生效
subjects:
- kind: User
  name: wang      # 必须与 kubeconfig 中 user.name 或认证系统中的用户名一致
  apiGroup: ""
roleRef:
  kind: ClusterRole        # ← 关键：引用的是 ClusterRole
  name: pods-viewer-cluster
  apiGroup: rbac.authorization.k8s.io
eof
```

> 🔒 安全提示：虽然 ClusterRole 是全局的，但通过 **RoleBinding** 绑定后，权限**仅限于 `dev` 命名空间**，不会泄露到其他 namespace。

3. 应用配置

```bash
kubectl  create ns dev
kubectl apply -f clusterrole-pods-viewer.yaml
kubectl apply -f rolebinding-wang-dev.yaml
```

🆚 对比说明

| 项目         | Role + RoleBinding         | ClusterRole + RoleBinding（推荐） |
| ------------ | -------------------------- | --------------------------------- |
| 权限定义位置 | 每个 namespace 单独定义    | 全局定义一次                      |
| 复用性       | 差（dev/staging 需重复写） | 高（所有 ns 可共用）              |
| 管理成本     | 高                         | 低                                |
| 适用场景     | 单一、隔离环境             | 多环境、生产集群                  |

🔁 如果需要跨多个命名空间？

只需为每个命名空间创建一个 RoleBinding，指向同一个 ClusterRole：

```bash
# 例如再给 staging 命名空间授权
kubectl create rolebinding wang-pods-reader-in-staging \
  --clusterrole=pods-viewer-cluster \
  --user=wang \
  --namespace=staging
```

💡 补充：如何验证权限？

```bash
# 使用你的 kubeconfig 测试
kubectl auth can-i list pods --namespace=dev 
kubectl auth can-i get deployments --namespace=dev
kubectl auth can-i list nodes   # 应该返回 no
```



---

### SA

**ServiceAccount（SA）—— Pod 的身份证**

- 每个命名空间默认有 `default` SA
- Pod 通过 `spec.serviceAccountName` 指定 SA
- K8s 自动将 SA 对应的 Secret 挂载到 `/var/run/secrets/kubernetes.io/serviceaccount/`

创建 Pod 查看挂载的 SA 文件Kubernetes 会**自动**将 ServiceAccount 的相关凭证挂载到每个 Pod 的固定路径下（除非显式禁用）：

> **挂载路径：`/var/run/secrets/kubernetes.io/serviceaccount/`**

#### 创建 POD YAML 文件

```powershell
cat > pod-with-sa.yaml <<'eof'
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: dev
spec:
  serviceAccountName: my-sa
  containers:
  - name: app
    image: nginx
eof
```

#### 执行步骤

1. 确保 SA 存在（如果还没创建）

```bash
kubectl create serviceaccount my-sa -n dev
```

2. 应用你的 Pod

```bash
kubectl apply -f pod-with-sa.yaml
```

3. 进入 Pod 查看挂载内容

```bash
kubectl exec -it my-app -n dev -- ls /var/run/secrets/kubernetes.io/serviceaccount/
```

你应该看到三个文件：

```
ca.crt          # 集群 CA 证书，用于验证 API Server 身份
namespace       # 当前 Pod 所在的命名空间（这里是 "dev"）
token           # Bearer Token，用于向 API Server 证明身份（即 SA 的凭证）
```

你可以进一步查看内容：

```sh
kubectl exec -it my-app -n dev -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
kubectl exec -it my-app -n dev -- cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
kubectl exec -it my-app -n dev -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

> 🔍 这个 `token` 就是该 ServiceAccount 对应的 Secret 中的 `token` 字段（通常是 `my-sa-token-xxxxx` 类型的 secret）。

---

####  总结

| 目标             | 操作                                                |
| ---------------- | --------------------------------------------------- |
| 查看 SA 挂载文件 | `ls /var/run/secrets/kubernetes.io/serviceaccount/` |
| 理解 SA 身份     | token = SA 的“密码”                                 |
| 理解权限控制     | RBAC 绑定决定能做什么                               |
| 安全实践         | 按需授权，最小权限，可禁用挂载                      |



---



## 第三章：准入控制

- 准入控制（Admission Control）—— “你做的事合规吗？”
- 作用范围：在对象写入 etcd 前进行拦截。


启用 Pod Security Admission（K8s ≥ 1.23）

```bash
# 为命名空间启用 restricted 策略
# 测试目标：验证 Pod Security Admission（PSA）在 restricted 模式下是否能阻止不合规的 Pod 创建。
kubectl label ns dev \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=restricted
```

测试违规 Pod

```yaml
cat > bad-pod.yaml <<'eof'
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
  namespace: dev
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true   # ← 违反 restricted 策略
eof
```
```bash
kubectl apply -f bad-pod.yaml
# Error: violates PodSecurity "restricted:latest"
```

> PSA 是 PSP 的现代化替代，无需复杂 webhook。

```powershell
回退
# 注意：标签名末尾的 - 表示“删除该标签”。
kubectl label namespace dev \
  pod-security.kubernetes.io/enforce- \
  pod-security.kubernetes.io/warn-
# 验证是否已删除：
kubectl get namespace dev --show-labels
```



---

## 第四章：调试与最佳实践

### 权限调试命令

```bash
# 查看当前用户能做什么
kubectl auth can-i list pods --namespace=dev

# 模拟其他用户
kubectl auth can-i create deployments --as=wang --namespace=dev

# 查看所有内置 ClusterRole
kubectl get clusterrole
kubectl describe clusterrole view
```

### 最佳实践

1. **最小权限原则**：不要随便给 `cluster-admin`
2. **用 Group 管理用户**：通过 O 字段归组，绑定 RoleBinding 到组
3. **避免静态 Token**：生产环境用 OIDC 或外部认证系统
4. **Pod 使用专用 SA**：不要用 default SA
5. **启用 PSA**：防止高危配置入集群

---

## 🎯 总结流程图（文字版）

```
[Client] 
   │
   ├───(1) Authentication ───► [User: alice, Groups: dev-team]
   │        (X509 / Token / SA)
   │
   ├───(2) Authorization ─────► [RBAC Engine]
   │        Role/ClusterRole + Binding → 允许? 
   │
   └───(3) Admission Control ─► [Mutating/Validating Webhooks]
            (e.g., PodSecurity) → 合规?
                     │
                     ▼
                [etcd: Persist]
```

---

