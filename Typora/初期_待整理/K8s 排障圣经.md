

![image-20251212140226514](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251212140226514.png)

这是一张非常经典、覆盖面极广的 Kubernetes Pod 启动到对外服务全链路故障排查流程图（俗称 K8s 排障圣图），几乎把 95% 以上的 Pod 起不来、访问不通的坑都串起来了。我把它翻译成大白话 + 关键结论，给你拆解一下这张图的逻辑结构和实际使用价值：图的整体结构（从上到下）

1. 开始 → Pod 是否能正常运行（Running + Ready）  
2. 如果不能运行 → 逐层排查 Pod 本身的问题（调度、镜像、资源、崩溃、重启、容器错误等）  
3. 如果 Pod 本身 Running + Ready → 检查能不能对外提供服务
   → 分两路：  
   - Ingress 是否正常  
   - Service 是否正常（含 ClusterIP、NodePort、LoadBalancer）

核心排障路径总结（按出现频率排序）

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

这张图的真正价值

- 几乎所有新人/老鸟遇到 “Pod 起不来” 或 “服务访问不到” 时，都可以照着这张图从上到下一路走过去，基本不会漏掉大坑。
- 很多公司面试 K8s 岗位时，会直接甩这张图问“你能讲完吗？”——能讲完基本过。

我个人最常用顺序（现实中 90% 的问题在这 5 步解决）

1. kubectl get pod → 看状态
2. kubectl describe pod xxx → 看 Events（最快定位 80% 问题）
3. kubectl logs xxx --previous → 看崩溃前日志
4. kubectl get svc + kubectl get ep → 看 Service 和 Endpoint
5. kubectl get ingress + 直接 curl ingress-controller 地址测试

