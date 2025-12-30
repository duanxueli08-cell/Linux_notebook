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

```powershell
# 通过集群角色绑定到不同的名称空间
kubectl create deploy myapp -n 65 --image registry.cn-beijing.aliyuncs.com/wangxiaochun/pod-test:v0.1 --replicas 2
kubectl create rolebinding -n demo rolebinding-demo-admin --clusterrole cluster-admin --serviceaccount=demo:prometheus
kubectl create rolebinding -n m65 rolebinding-m65-admin --clusterrole cluster-admin --serviceaccount=demo:prometheus
```



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

或者指令式发布

```powershell
kubectl create clusterrole pods-viewer-cluster \
  --verb=get,list,watch \
  --resource=pods,services \
  --verb=get,list,watch \
  --resource=deployments.apps
kubectl create rolebinding wang-pods-reader-in-dev \
  --namespace=dev \
  --clusterrole=pods-viewer-cluster \
  --user=wang
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



## Dashboard

- 下载地址：https://github.com/kubernetes/dashboard
- 注意:v2.7.0以后版本只支持Helm安装

以下是通过 token 认证登录的方式，还有一个 kubeconfig 认证方式，但是非常繁琐，不推荐！这里就不做相关的笔记了！

```powershell
# 获取官方的yaml文件,下载并修改配置文件
VERSION=v2.7.0
# 通过代理下载
wget https://mirror.ghproxy.com/https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION}/aio/deploy/recommended.yaml
# 部署
mv recommended.yaml recommended_2.7.0.yaml
kubectl apply -f recommended_2.7.0.yaml

# 创建专用的SA服务账户,注意SA所在名称空间并不决定可以管理的Pod所在名称空间
kubectl create serviceaccount dashboard-admin -n kube-system
# 将SA帐号利用集群角色绑定至集群角色cluster-admin
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
```

```powershell
# 创建SA帐号后不会自动创建secret,需要手动创建secret
cat > security-dashboard-admin-secret.yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: dashboard-admin-secret
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "dashboard-admin"

kubectl apply -f security-dashboard-admin-secret.yaml
# 查看创建的Secret
kubectl get secret -A | grep dashboard-admin
# 查看Secret关联的Token 
kubectl get secrets dashboard-admin-secret -n kube-system -o yaml
# 需要 base34 转码，得到真正的 token
echo 你的 token | base64 -d
# 直接查看真正的 token （不用转码）
kubectl describe secrets -n kube-system dashboard-admin-secret
```

```powershell
# 查看暴露的 IP
kubectl get -n kubernetes-dashboard all
浏览器：https://10.0.0.11	————>	输入 token	————>	登录

```



## Kuboard

官网： https://kuboard.cn/

在线体验

```powershell
https://demo.kuboard.cn
用 户： demo
密 码： demo123
```

安装方法介绍

- 基于 Docker 安装：官方推荐
- 基于 Kubernetes 集群中安装

支持Storage Class 持久化安装kuboard

```powershell
# 环境准备，提前准备一个名称为sc-nfs的storageClass
kubectl get sc
# 注意:官方yaml文件有bug,需要修改
curl -o kuboard-v3.yaml https://addons.kuboard.cn/kuboard/kuboard-v3-storage-class.yaml
vim kuboard-v3.yaml
data:
  #KUBOARD_ENDPOINT: 'http://your-node-ip-address:30080' #注释此行
  KUBOARD_ENDPOINT: 'http://kuboard.wang.org' #添加此行
  KUBOARD_AGENT_SERVER_UDP_PORT: '30081'
  KUBOARD_AGENT_SERVER_TCP_PORT: '30081'
往下面找，填写一个有效的 StorageClass name 
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
    #storageClassName: please-provide-a-valid-StorageClass-name-here #修改此处
    storageClassName: sc-nfs # 如果配置了默认的sc，此行可以不添加，上面行注释即可
继续往下面找
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kuboard-data-pvc
  namespace: kuboard #注意:官方的bug会导致 pod/kuboard-v3-xxx 处于 pending 状态，需要加此行指定名称空间
spec:
  #storageClassName: please-provide-a-valid-StorageClass-name-here # 修改此处
  storageClassName: sc-nfs # 如果配置了默认的sc，此行可以不添加，上面行注释即可
```

```powershell
kubectl apply -f kuboard-v3.yaml
# 此时就可以通过集群内任意 IP 加端口号在浏览器登录访问了！  10.0.0.101:30000

# 如果想通过ingress暴Kuboard露，可以执行下面操作，注意：需要提前部署ingress-nginx(可选)
cat > ingress-kuboard.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuboard
  namespace: kuboard
spec:
  ingressClassName: nginx
  rules:
  - host: kuboard.wang.org
    http:
      paths:
      - path: /
        backend:
          service:
            name: kuboard-v3
            port:
              number: 80
        pathType: Prefix

kubectl apply -f ingress-kuboard.yaml
kubectl get ingress -n kuboard
# 做域名解析
kuboard.wang.org 10.0.0.11

# 安装后访问 Kuboard
# 在浏览器中打开链接 http://kuboard.wang.org
# 输入初始用户名和密码，并登录
# 用户名： admin
# 密码： Kuboard123
方法一：Token
#  API server 地址：https://10.0.0.101:6443
# 后面可以根据官方指导生成 token
方法二：KubeConfig
# 将集群中的 .kube/config 文件复制到里面，然后修改下面的域名为 IP
```







# Kubernetes  网络





CNI 网络插件的主要功能：

为 pod 分配 ip 地址，管理 IP 地址池和回收

配置网络命名空间；

设置路由和网桥，提供跨界点通信能力；

支持多网络和网络策略 （部分插件）





常见 CNI 插件：

flannel：简单易用，基于 overlay 网络；

calico：高性能，支持 BGP 路由和 NetworkPolicy；（主流）

cilium：基于 eBPF，提供 L3-L7 层安全和可观测性；



k8s 目前常用实现 pod 网络的方案有两类：承载网络 （underlay） 和叠加网络 （overlay）

| 特性              | Underlay                  | Overlay                        |
| ----------------- | ------------------------- | ------------------------------ |
| **网络模型**      | 直接使用物理网络          | 虚拟网络叠加在物理网络上       |
| **Pod IP 可见性** | 对物理网络可见            | 仅在集群内可见                 |
| **性能**          | 更优（无封装）            | 略低（有封装开销）             |
| **部署复杂度**    | 高（需网络配合）          | 低（自包含）                   |
| **跨节点通信**    | 依赖底层路由（如 BGP）    | 自动通过隧道实现               |
| **典型代表**      | Calico (BGP), AWS VPC CNI | Flannel, Weave, Cilium (VXLAN) |

一、Underlay（承载网络）

核心思想

- 直接利用底层物理网络基础设施（如交换机、路由器）来实现 Pod 之间的通信。
- Pod 的 IP 地址通常是真实存在于物理网络中的可路由地址，无需封装或隧道。

🔧 典型实现：

- Calico（BGP 模式）
- 某些云厂商 VPC 原生网络（如 AWS VPC CNI、阿里云 Terway）

✨ 侧重点：

| 维度           | 说明                                                         |
| -------------- | ------------------------------------------------------------ |
| **性能**       | 极高，无封装开销，延迟低，吞吐高                             |
| **网络可见性** | Pod IP 对物理网络可见，便于监控、排障和安全策略部署          |
| **扩展性**     | 依赖底层网络设备能力（如 BGP 支持），大规模部署需网络团队配合 |
| **配置复杂度** | 较高，需对物理网络有控制权（如配置 BGP 路由）                |



二、Overlay（叠加网络）

核心思想：

- 在现有物理网络之上构建一个虚拟网络层，通过封装技术（如 VXLAN、Geneve、IPIP）将 Pod 流量封装在物理网络传输。
- Pod IP 是虚拟地址，仅在 overlay 网络内有效，物理网络看不到 Pod IP。

🔧 典型实现：

- Flannel（VXLAN / Host-gw 模式）
- Calico（IPIP 模式）
- Weave Net
- Cilium（VXLAN / Geneve）

✨ 侧重点：

| 维度           | 说明                                               |
| -------------- | -------------------------------------------------- |
| **性能**       | 有一定封装/解封装开销，但现代 CPU 优化后影响较小   |
| **部署便捷性** | 高，不依赖底层网络改造，适合任意 IaaS 或裸金属环境 |
| **跨子网通信** | 天然支持，无需底层网络支持 L3 路由                 |
| **隔离性**     | 虚拟网络与物理网络解耦，更易实现多租户隔离         |



容器接入网络的方式：

实现方式有三种：虚拟以太网设备 （veth）、多路复用以及硬件交换；

- MACVLAN：通过 MAC 地址 多路复用物理接口
- IPVLAN：通过 IP 地址 多路复用物理接口

   



Flannel

简单介绍；

原理；

案例；vxlan、vxlan directrouting 模式



calico

介绍

网络机制

网络模型：BGP、ipip、vxlan 等



## VXLAN 通信过程

```bash
容器中的应用发送数据 → 
从容器内 eth0 发出 → 
经 veth pair 到达宿主机端的 vethxxx → 
被接入 cni0 网桥 → 
cni0 根据二层/三层规则将包交给宿主机协议栈 → 
内核查路由表，发现目标 Pod IP 属于远端子网 → 
将包转发给 flannel.1（VXLAN 接口）→ 
内核 VXLAN 模块封装该包（加上 VXLAN 头 + 外层 UDP/IP）→ 
封装后的包经物理网卡（如 eth0）发送到目标节点。
```

- **封装发生在宿主机内核网络栈中，由 VXLAN 虚拟接口触发**
- **cni0 只是二层交换，不参与封装**
- **Flannel 本身（用户态进程）只负责下发路由和 FDB 表，不处理数据面**
- 💡 补充：VXLAN 使用 **UDP 封装**（目的端口通常是 8472）

| 概念          | 说明                                                 |
| ------------- | ---------------------------------------------------- |
| **VXLAN**     | 一种网络隧道技术，用来在物理网络上传输虚拟网络的数据 |
| **VNI**       | VXLAN 的唯一标识，防止不同网络混淆                   |
| **flannel.**  | 虚拟隧道接口，负责封装/解封装 VXLAN 包               |
| **cni0**      | 虚拟网桥，连接容器和 VXLAN 隧道                      |
| **veth pair** | 容器与主机之间的“虚拟网线”                           |



**Host-gw 模式**

- 数据包从容器出来后，经过 veth → cni0 → 宿主机路由 → 直接从物理网卡发出，全程不封装，靠路由表指路。
- 只要所有节点在同一个二层网络，Host-gw 是最简单、最高效的 CNI 后端之一。

```powershell
kubectl get cm kube-flannel-cfg -o yaml -n kube-flannel > /tmp/kube-flannel.yml
vim /tmp/kube-flannel.yml
# 开启 flannel 的 host-gw 直连路由模型
net-conf.json: |
  {
      "Network": "10.244.0.0/16",
      "Backend": {
          "Type": "host-gw"		# 修改此行的 vxlan 为 host-gw
      }
  }

kubectl apply -f /tmp/kube-flannel.yml

# 或者在线编辑修改
kubectl edit cm kube-flannel-cfg -n kube-flannel
# 删除旧的flannel相关Pod才能使配置生效
kubectl delete pod -n kube-flannel -l app=flannel
# 自动重新创建 pod
kubectl get pod -A |grep flannel
# 重启所有节点（物理主机）,可以看到flannel.1接口不再存在
ip a
# 查看路由效果，
route -n

# 所有的路由转发，都不再使用flannel了，直接进行路由转发了
# 如果是第一次安装flannel的时候，使用这种模式，flannel.1网卡不会生成
# 显示的路表由表和VXLAN DirectRouting 模式一样
```



VXLAN DirectRouting 模式

这个可以理解为自适应模式！根据实际情况变更模式为 Host-gw 或 VXLAN 

```powershell
# 修改 flannel 为直连路由模型
方法一：
# 在线修改 CM
kubectl edit cm kube-flannel-cfg -n kube-flannel
net-conf.json: |
  {
      "Network": "10.244.0.0/16",
      "Backend": {
          "Type": "vxlan", 			# 注意:最后需要添加一个逗号
          "DirectRouting": true 	# 添加此行
      }
  }

方法二：
kubectl get cm kube-flannel-cfg -o yaml -n kube-flannel > /tmp/kube-flannel.yml
vim /tmp/kube-flannel.yml
net-conf.json: |
  {
      "Network": "10.244.0.0/16",
      "Backend": {
          "Type": "vxlan", 			# 注意:最后需要添加一个逗号
          "DirectRouting": true 	# 添加此行
      }
  }
  
# 重启 flannel 相关的 pod
kubectl apply -f kube-flannel.yml
# 删除旧的flannel相关Pod,才能生效

# 配置生效
方法1
kubectl rollout restart daemonset kube-flannel-ds -n kube-flannel
方法2
kubectl delete pod -n kube-flannel -l app=flannel

# 如果节点间没有跨网段的环境,查看路由效果和host-gw模式相同
route -n
# 结果显示：所有的路由转发，都不再使用flannel，直接进行路由转发,这是因为当前环境没有涉及到跨网段的主机节点
```



# 🧱 Calico 

------

## 一、Calico 简介（介绍）

**Calico** 是一个开源的、高性能的容器网络和网络安全解决方案，广泛用于 Kubernetes、OpenShift、Docker 等容器编排平台。它提供以下核心能力：

- **Pod 之间三层（L3）网络通信**：无需 overlay 封装（默认模式），直接使用 BGP 协议实现高效路由。
- **网络策略（NetworkPolicy）**：支持细粒度的流量控制，实现零信任安全模型。
- **IP 地址管理（IPAM）**：自动为 Pod 分配 IP，并支持灵活的地址池配置。
- **多集群/混合云支持**：可跨多个 Kubernetes 集群甚至物理/虚拟机统一组网。

Calico 由 Tigera 公司主导开发，是 CNCF（云原生计算基金会）的毕业项目之一，被大量生产环境采用。

------

## 二、Calico 的工作机制

Calico 的核心设计理念是 **“基于纯三层的网络模型”**，避免传统 overlay（如 VXLAN、GRE）带来的性能损耗和复杂性。其工作机制主要包括以下几个组件：

### 1. **Felix**

- 每个节点上运行的代理（agent）。
- 负责配置路由表、iptables 规则、ACL（访问控制列表）等。
- 监听 Calico 控制平面的变化（如新 Pod 创建、策略更新），并实时应用到本地。

### 2. **etcd（或 Kubernetes API）**

- 存储 Calico 的配置数据，如 IP 地址分配、网络策略、节点信息等。
- 在 Kubernetes 中，Calico 可以直接使用 Kubernetes API 作为数据存储（称为 “KDD 模式”，即 Kubernetes Datastore Driver），无需独立 etcd。

### 3. **BIRD（BGP 守护进程）**

- 实现 BGP（边界网关协议）路由分发。
- 各节点通过 BGP 互相通告自己所管理的 Pod CIDR，使整个集群形成一个扁平的三层网络。
- 支持与物理网络设备（如 Top-of-Rack 交换机）建立 BGP 对等体，实现无缝集成。

### 4. **CNI 插件**

- Calico 提供符合 CNI（Container Network Interface）规范的插件。
- 当 Kubernetes 调度 Pod 时，kubelet 调用 Calico CNI 为容器创建虚拟网卡（veth pair），并配置 IP 和路由。

### 5. **Typha（可选）**

- 用于大规模集群中减轻 API Server 压力。
- 作为 Felix 与 API Server 之间的代理，聚合和缓存状态变更。

> ✅ **关键特点**：默认使用 **BGP 路由模式**，Pod IP 在整个集群内可达，无需 NAT 或隧道封装，性能接近物理网络。

------

## 三、Calico 的主要网络模型

Calico 支持多种网络部署模式，适应不同规模和网络环境的需求：

### 1. **BGP 模式（默认，推荐）**

- **原理**：每个节点通过 BGP 协议广播自己负责的 Pod CIDR。
- **优点**：
  - 无 overlay 封装，低延迟、高吞吐。
  - 路由清晰，便于排错和监控。
- **适用场景**：数据中心网络支持 BGP（如使用 Cumulus、Arista、Cisco 等支持 BGP 的交换机）。
- **子模式**：
  - **Node-to-Node Mesh**：所有节点两两建立 BGP 对等（适合小集群，<100 节点）。
  - **Route Reflector（RR）模式**：引入 BGP Route Reflector 集中管理路由，适合大规模集群。

### 2. **IPIP 模式（Overlay）**

- **原理**：当底层网络不支持 BGP 或跨子网通信时，Calico 会将 Pod 流量封装在 IPIP（IP in IP）隧道中传输。
- **特点**：
  - 跨子网通信可行。
  - 性能略低于纯 BGP（因有封装开销）。
  - 仍保留 Calico 的网络策略能力。
- **典型场景**：公有云环境（如 AWS、阿里云）中节点分布在不同子网，且无法修改底层路由。

### 3. **VXLAN 模式（Calico v3.17+ 支持）**

- 类似 Flannel 的 VXLAN 模式，但结合了 Calico 的策略引擎。
- 适用于不能使用 BGP 且希望比 IPIP 更高效（硬件加速支持）的场景。

### 4. **混合模式（Hybrid）**

- 可在同一集群中对部分节点使用 BGP，部分使用 IPIP/VXLAN。
- 通过配置 `ippool` 的 `natOutgoing` 和 `vxlanMode/ipipMode` 实现灵活调度。

------

## 补充：Calico 与 Flannel 对比

| 特性     | Calico                | Flannel                        |
| -------- | --------------------- | ------------------------------ |
| 网络模型 | L3 BGP / IPIP / VXLAN | 主要 Overlay（VXLAN、Host-gw） |
| 网络策略 | ✅ 原生支持            | ❌ 需配合其他组件（如 Canal）   |
| 性能     | 高（BGP 模式无封装）  | 中（VXLAN 有封装开销）         |
| 复杂度   | 较高（需理解 BGP）    | 简单易用                       |
| 适用场景 | 生产级、安全要求高    | 快速搭建、测试环境             |

相较于 flannel 来说 ， calico 主要优势在于支持网络策略 network policy

------

## 总结

- **Calico = 高性能网络 + 强大安全策略**。
- 默认使用 **BGP 三层路由**，避免 overlay 开销。
- 支持 **IPIP/VXLAN** 以适应复杂网络环境。
- 是构建 **安全、可扩展、可观测** 的 Kubernetes 网络的首选方案之一。

------

在现网（生产环境）中，Kubernetes（K8s）集群的主流网络模式主要围绕 **Overlay 网络** 展开，以实现跨节点 Pod 通信。这是因为 K8s 的核心网络模型要求：

> “所有 Pod 之间必须能够通过 Pod IP 直接通信，无需 NAT。”

为满足这一要求，业界广泛采用以下几种 **主流、通用的跨节点通信网络模式/方案**：

---

## 一、主流网络模式分类

### 1. **Overlay 模式（覆盖网络）** ← **最主流**
- **原理**：在底层物理网络（Underlay）之上构建一个虚拟网络层，通过“隧道封装”（如 VXLAN、IPIP）将 Pod 流量封装后跨节点传输。
- **代表插件**：
  - **Flannel**（默认使用 VXLAN）
  - **Calico**（支持 VXLAN、IPIP、BGP）
  - **Weave Net**
- **优点**：
  - 不依赖底层网络拓扑（节点可跨子网）
  - 部署简单，兼容性强
  - 支持大规模集群（尤其 Calico + BGP 或 eBPF 模式）
- **缺点**：
  - 封装/解封装带来一定性能开销（VXLAN 约 5~10%）
  - 排查网络问题稍复杂

> 📌 **适用场景**：绝大多数公有云、混合云、私有云生产环境。

---

### 2. **Underlay / Host-GW 模式（路由直通）**
- **原理**：不封装数据包，而是在每个节点上配置静态或动态路由（如通过 BGP），使 Pod 流量像普通 IP 流量一样直接路由到目标节点。
- **代表方案**：
  - **Calico（BGP 模式）**
  - **纯 Host-GW（Flannel 的 host-gw backend）**
- **优点**：
  - **零封装开销，性能接近物理网络**
  - 网络路径清晰，便于监控和排障
- **缺点**：
  - 要求所有节点在**同一二层网络**（或支持 BGP 的三层网络）
  - 公有云中部分厂商限制自定义路由（如 AWS 需启用 VPC 路由表权限）

> 📌 **适用场景**：对性能敏感的私有数据中心、裸金属集群；或支持 BGP 的云环境（如 GCP、部分 OpenStack）。

---

### 3. **CNI 插件生态（标准化接口）**
- 所有上述方案都通过 **CNI（Container Network Interface）** 标准接入 K8s。
- CNI 本身不是网络模式，而是**插件规范**，使得 Flannel、Calico、Cilium 等可以即插即用。

---

## 二、跨节点通信的主流通用模式总结

| 模式                    | 技术实现               | 是否主流   | 性能 | 部署复杂度 | 适用环境                     |
| ----------------------- | ---------------------- | ---------- | ---- | ---------- | ---------------------------- |
| **Overlay (VXLAN)**     | Flannel / Calico-VXLAN | ✅ 极主流   | 中等 | 低         | 公有云、混合云、测试/生产    |
| **BGP 路由 (Underlay)** | Calico-BGP             | ✅ 生产推荐 | 高   | 中高       | 私有数据中心、支持 BGP 的云  |
| **Host-GW**             | Flannel-host-gw        | ⚠️ 有限使用 | 高   | 低         | 同一子网内的小集群           |
| **eBPF（新兴）**        | Cilium / Calico-eBPF   | 🔺 快速增长 | 极高 | 中         | 高性能、可观测性要求高的场景 |

> 💡 **当前行业共识**：
> - **中小集群 / 快速上线** → **Flannel（VXLAN）**
> - **生产环境 / 安全合规 / 大规模** → **Calico（VXLAN 或 BGP）**
> - **极致性能 / 云原生可观测性** → **Cilium（基于 eBPF）**

---

## 结论

> **现网 K8s 集群的主流跨节点通信模式是 Overlay 网络（尤其是 VXLAN 封装），以 Flannel 和 Calico 为代表；而在高性能或可控网络环境中，Calico 的 BGP 模式（Underlay）正成为生产首选。**



------

## 一、Calico 安装配置示例

### 1. 前提条件

- 已部署 Kubernetes 集群（v1.20+ 推荐）
- 节点间网络互通（特别是 BGP 模式需开放 TCP 179 端口）
- 推荐关闭防火墙或放行必要端口（如 IPIP 使用协议号 4）

------

### 2. 快速安装（使用官方 YAML）

查看calico版本的k8s 版本的兼容性

```powershell
https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements
```

查看安装方法

```powershell
https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises
```

由于之前我用的 flannel 插件，所以需要先清理一下环境!

```powershell
kubectl delete -f kube-flannel.yml
rm -f /etc/cni/net.d/* && ls /etc/cni/net.d/
kubectl get pod -n kube-system | grep flannel
# 确认 flannel 的相关 Pod 被删除，最后重启；否则路由表信息不会刷新！
ip a
```

Calico 官方提供了一键部署的 YAML 文件：

```bash
curl https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/calico.yaml -O
```

> ⚠️ 注意：该 YAML 默认启用 **IPIP 模式**（`ipipMode: Always`），适用于跨子网或公有云环境。

```powershell
# 可以直接使用原文件，如果修改可以先备份原文件(可选)
cp calico.yaml file/calico.yaml.bak
# 可以直接使用原来的flannel的网络配置，测试环境也可以做下面配置修改CIDR，(可选)
vim calico.yaml
# 官网推荐的修改内容(基于kubeadm安装可不做修改,其它安装方式,需要修改，可选)
# 指定Pod的网段,如果使用当前默认配置，即保留当前注释,Pod的IP将使用安装k8s时的 --pod-network-cidr 选项指定IP网段(可选)
	- name: CALICO_IPV4POOL_CIDR 	# 删除注释可以覆盖安装k8s时的--pod-network-cidr选项，使用指定Pod网段
	  value: "192.168.0.0/16" 		# 默认值为 value: "192.168.0.0/16"
# 开放默认注释的CALICO_IPV4POOL_CIDR变量，此处改为24,生产环境可不用修改，当前为测试环境建议
# 默认没有下面内容,手动加下面两行,调大单个节点上的Pod所在网段,默认使用/26,即255.255.255.192的子网掩码，每个节点只有62个Pod的地址
	- name: CALICO_IPV4POOL_BLOCK_SIZE
	  value: "24"
```

```powershell
kubectl apply -f calico.yaml
```

```powershell
ethtool -i tunl0

tcpdump -i echo0 -nn host 192.168.144.20
```



------

###  3. 自定义配置（以纯 BGP 模式为例）

如果在私有数据中心，希望使用 **高性能 BGP 模式（无 IPIP 封装）**，需要修改 Calico 的 IP Pool 配置。

#### 步骤 1：下载并编辑 YAML

```bash
wget https://docs.projectcalico.org/manifests/calico.yaml -O calico-bgp.yaml
```

#### 步骤 2：修改 IP Pool 配置

找到 `kind: IPPool` 的部分，修改如下：

```yaml
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: default-ipv4-ippool
spec:
  cidr: 192.168.0.0/16        # Pod 使用的 IP 段
  ipipMode: Never             # 关闭 IPIP（BGP 模式）
  vxlanMode: Never            # 关闭 VXLAN
  natOutgoing: true           # 出站流量做 SNAT（访问外网必需）
  nodeSelector: all()
```

> ✅ `ipipMode: Never` + `natOutgoing: true` 是典型 BGP 生产配置。

#### 步骤 3：应用配置

```bash
kubectl apply -f calico-bgp.yaml
```

------

### 4. 验证安装

```bash
# 查看 Calico 组件是否 Running
kubectl get pods -n kube-system | grep calico

# 查看节点 BGP 状态（需安装 calicoctl）
calicoctl node status
```

输出示例（BGP 模式）：

```
IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 10.0.0.2     | node-to-node mesh | up    | 10:23:45 | Established |
| 10.0.0.3     | node-to-node mesh | up    | 10:23:46 | Established |
+--------------+-------------------+-------+----------+-------------+
```

> 💡 若未安装 `calicoctl`，可使用以下命令快速部署：

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calicoctl.yaml
```

------

## 二、Calico 网络策略（NetworkPolicy）编写

Kubernetes 原生支持 NetworkPolicy，但**只有 Calico、Cilium 等插件真正实现了它**。Calico 的策略引擎非常强大。

### 1. 基本概念

- 默认情况下，**所有 Pod 可互相通信**（“允许所有”）。
- 一旦为某个 Namespace 或 Pod 应用 NetworkPolicy，**默认变为拒绝所有**，只放行策略中明确允许的流量。

------

### 2. 示例 1：只允许前端访问后端

假设：

- 前端 Pod 标签：`app=frontend`
- 后端 Pod 标签：`app=backend`，监听 8080 端口

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend          # 策略作用于带此标签的 Pod
  policyTypes:
  - Ingress                 # 控制入站流量
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend     # 只允许 frontend 访问
    ports:
    - protocol: TCP
      port: 8080
```

> ✅ 应用后，只有 `app=frontend` 的 Pod 能访问 `app=backend:8080`，其他全部拒绝。

------

### 3. 示例 2：禁止所有出站（egress）流量，仅允许 DNS 和 HTTP

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress
  namespace: secure-app
spec:
  podSelector:
    matchLabels:
      app: secure-pod
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector: {}   # 允许访问任何命名空间的 kube-dns
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0     # 允许访问公网 HTTP/HTTPS
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
```

> 🔒 这是典型的“零信任”策略：最小权限原则。

------

### 4. 高级功能（Calico 特有）

Calico 还支持更强大的策略，如：

- **全局网络策略（GlobalNetworkPolicy）**：跨命名空间生效
- **基于 CIDR、服务账户、FQDN 的规则**
- **日志记录（logAccepted/Rejected）**

示例：记录所有被拒绝的流量

```yaml
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: log-all-deny
spec:
  order: 2000
  selector: "all()"
  types:
  - Ingress
  - Egress
  ingress:
  - action: Log
  egress:
  - action: Log
```

------

## 三、Calico 常见排错技巧

### 1. Pod 无法获取 IP

- **现象**：Pod 卡在 `ContainerCreating`

- **排查**：

  ```bash
  kubectl describe pod <pod-name>
  # 查看是否有 "failed to allocate IP" 错误
  ```

- **原因**：

  - IP 地址池耗尽（检查 `calicoctl get ippool -o wide`）
  - CNI 配置缺失（检查 `/etc/cni/net.d/` 是否有 10-calico.conflist）

------

### 2. Pod 之间无法通信

- **步骤 1**：确认是否启用了 NetworkPolicy

  ```bash
  kubectl get networkpolicy --all-namespaces
  ```

  如果有策略，先临时删除测试。

- **步骤 2**：检查路由表（在源节点执行）

  ```bash
  ip route show
  # 应包含目标 Pod 所在节点的 CIDR，下一跳为对端节点 IP
  ```

- **步骤 3**：检查 BGP 状态

  ```bash
  calicoctl node status
  # 确保所有对等体状态为 "Established"
  ```

- **步骤 4**：抓包分析

  ```bash
  # 在源节点抓包（查看是否发出）
  tcpdump -i any host <目标PodIP>
  
  # 在目标节点抓包（查看是否收到）
  tcpdump -i any host <源PodIP>
  ```

------

### 3. IPIP 模式下跨节点不通

- **可能原因**：底层网络屏蔽了 **IP 协议号 4（IPIP）**

- **验证**：

  ```bash
  # 在节点上测试是否能发 IPIP 包
  ping -I tunl0 <目标节点IP>
  ```

- **解决**：

  - 公有云：确保安全组允许 **协议 4**（不是 TCP/UDP！）
  - 或改用 VXLAN 模式（使用 UDP 封装，通常更友好）

------

### 4. Calico 组件 CrashLoopBackOff

- **常见原因**：

  - etcd/Kubernetes API 连接失败
  - 节点 hostname 不唯一（Calico 要求 hostname 全局唯一）
  - 内核版本过低（建议 ≥ 4.10）

- **排查命令**：

  ```bash
  kubectl logs -n kube-system calico-node-xxxxx -c calico-node
  ```

------

## 总结

| 主题     | 关键点                                                       |
| -------- | ------------------------------------------------------------ |
| **安装** | 默认用 `calico.yaml`；BGP 模式需设 `ipipMode: Never`         |
| **策略** | NetworkPolicy 默认 deny-all；Calico 支持全局策略、日志等高级功能 |
| **排错** | 从 IP 分配 → 路由 → BGP → iptables → 抓包 逐层排查           |

------















准备环境

```powershell
kubectl delete -f kube-flannel.yaml
rm -rf /etc/cni/net.d/10-flannel.conflist
```



## 网络指令

```powershell
# 显示名为 docker0 的网络接口的驱动程序和固件（firmware）相关信息。
ethtool -i docker0
# 列出系统中所有网桥（bridge）及其所连接的接口（端口）。
brctl show
# 查看路由表
route -n
```



