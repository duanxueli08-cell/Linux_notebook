

## 存储

### MinIO

> 企业级自建版 S3，对象存储中的“瑞士军刀”。

#### 背景

过去常用 **NFS** 或 **NAS**，但随着服务增多、容器化普及：

- 共享文件系统易锁死

- 单点问题严重

- 性能差、扩展差

MinIO 刚好解决这些痛点：

✓ 避免文件系统锁问题  
✓ S3 API 天生适合微服务  
✓ 多服务并发访问无压力  
✓ 容器环境极其友好（K8s 推荐方案）



| 类型    | 访问方式         | 协议         | 场景                             | 类比               |
| ------- | ---------------- | ------------ | -------------------------------- | ------------------ |
| **DAS** | 本地直连（块）   | SATA/SAS/USB | 单机                             | “本地硬盘”         |
| **NAS** | 网络访问（文件） | SMB/NFS      | 局域网（文件共享）               | “共享文件夹服务器” |
| **SAN** | 专用网络（块）   | FC / iSCSI   | 企业核心业务<br>（专用光纤网络） | “远程高性能硬盘”   |

| **特点**     | **存储桶 (Bucket)**                                          | **传统文件系统（顶级文件夹）**                              |
| ------------ | ------------------------------------------------------------ | ----------------------------------------------------------- |
| **层级结构** | **扁平结构：** Bucket 内部没有真实的文件夹层级，所有对象都是平级的。 | **树状结构：** 文件夹内部可以嵌套更多文件夹，形成深度层级。 |
| **管理策略** | **面向策略：** 权限、地域、版本控制等策略是针对整个 Bucket 设置的。 | **面向目录：** 权限可以精确到每个文件夹或文件。             |
| **访问方式** | 通过 **HTTP/S API 和唯一的 URL** 访问。                      | 通过文件路径和网络共享协议（如 SMB/NFS）访问。              |
| **容量限制** | 理论上**无限**。                                             | 受限于物理磁盘或文件系统（如 ext4, NTFS）的大小限制。       |

相比块存储，对象存储的成本通常更低，适合存储不常变动的冷数据或备份。
数据不再放在传统的文件夹目录中，而是放在一个巨大的扁平的地址空间 （存储桶）

对象存储，每个对象包含如下三个部分：

- 数据：实际存放数据（比如：图片、视频等）
- 键值：数据全局唯一标识符；
- 元数据：数据对象的描述信息（比如创建日期、类型等）



#### 部署

##### server

- minio server 的 standalone 模式，即单机模式，所有管理的磁盘都在一个主机上；（仅作为实验环境）
- Debian/Ubuntu 二进制安装
- 官方下载链接（两个都行）：
  - [MinIO Download Server](https://dl.min.io/server/minio/release/linux-amd64/archive)
- 安装指定版本,建议使用 minio.RELEASE.2025-04-22T22-12-26Z 学习，注意：minio-05-24T17-08-30Z 版本以后界面功能功能缺失；

###### **包安装（参考）**

```powershell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20250907161309.0.0_amd64.deb
dpkg -i  minio_20250907161309.0.0_amd64.deb
cat /lib/systemd/system/minio.service
ls /etc/default/minio
useradd -M -r -s /sbin/nologin minio-user
cat > /etc/default/minio <<eof
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=12345678
MINIO_VOLUMES="/data/minio{1...4}"
MINIO_OPTS='--console-address :9001'
eof
ls /etc/default &>/dev/null || mkdir -p /etc/default
chown -R minio-user:minio-user /data/
systemctl start minio && systemctl status minio
```

- 上述是包安装的操作，仅作为参考，并不推荐；因为deb、rpm等包不具有通用性，而二进制包只要是Linux系统就可以安装部署使用！
- 在 /lib/systemd/system/minio.service 配置文件中虽然添加了创建用户和用户组，但是实际并没有创建，需要手工创建，并手工修改文件所属主和所属组；
  - useradd -M -r -s /sbin/nologin minio  创建一个没有家目录、不能登录、专门用于服务运行的系统账户：minio-user
  - 创建完成记得修改数据卷的所属组和所属主为：chown -R minio-user:minio-user /data/
- 在 /lib/systemd/system/minio.service 配置文件中看到启动需要两个变量，而这两个变量在配置文件被定义在了 /etc/default/minio 文件中；
  - ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
  - $MINIO_VOLUMES —— MinIO 的数据存储路径（必须）；不指定数据卷路径启动会失败！
  - $MINIO_OPTS —— MinIO 的 Console 控制台端口 ；不指定该参数不影响启动，但是每次启动的控制台端口是随机的；
- 这个文件 /etc/default/minio 需要手动创建，变量也需要手动添加！（这个包安装是不是很鸡肋呀？？？）
  - MINIO_ROOT_USER=admin 				#默认minioadmin
    MINIO_ROOT_PASSWORD=12345678 		#默认minioadmin，密码不能低于8位
    MINIO_VOLUMES="/data/minio{1...4}" 		#必选项
    MINIO_OPTS='--console-address :9001' 		#默认使用随机端口，可以访问9000进行跳转到此随机端口
    MINIO_PROMETHEUS_AUTH_TYPE="public" 	#支持promethues监控：curl -s
- 那么不创建这个文件可以吗？可以！ 只需要在启动时进行存储路径和控制台端口的参数指定
  -  /usr/local/bin/minio server --console-address 0.0.0.0:9001 /data/minio
  -  手动指定数据存放路径；默认账户名和密码：minioadmin
  -  登录：10.0.0.201:9001
  -  这个 /data/minio 文件夹是启动时自动创建的；在网页中创建的存储桶 （Buckets）文件都会永久持续保存在 /data/minio 目录下；



###### **二进制安装**

```powershell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-04-22T22-12-26Z
install minio.RELEASE.2025-04-22T22-12-26Z  /usr/local/bin/minio
minio --version
which minio
useradd -M -r -s /sbin/nologin minio-user
cat > /lib/systemd/system/minio.service <<eof
[Unit]
Description=Minio
After=systemd-networkd.service systemd-resolved.service
Documentation=https://min.io
[Service]
Type=simple
Environment=MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=12345678
ExecStart=/usr/local/bin/minio server /data/minio --console-address ":9001"
Restart=on-failure
User=minio-user
Group=minio-user
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
OOMScoreAdjust=-1000
[Install]
WantedBy=multi-user.target
eof

ls /data &>/dev/null || mkdir -p /data
chown -R minio-user:minio-user /data/  && ll /data
systemctl daemon-reload
systemctl start minio.service && systemctl status minio.service && sleep 1 && ss -tunlp | grep 9001
journalctl -u minio -f
```

> install 安装会自动把文件权限设置为 755 ; 自动创建不存在的目录 ;
>
> 在 minio web 界面创建一个 Buckets （自定义名称 duanxueli），在这个存储桶中上传文件，观察 tree /data/minio/duanxueli 目录下的内容；

###### 模拟多块硬盘

- 也可以添加硬盘（反正也是虚拟硬盘！）

```powershell
rm -rf /data/minio && tree /data
mkdir /data/minio{1..4} && tree /data
systemctl stop minio && systemctl status minio
sed -i 's#/data/minio#/data/minio{1...4}#' /lib/systemd/system/minio.service && grep "ExecStart" /lib/systemd/system/minio.service
systemctl daemon-reload
# 添加四块磁盘（因为是做实验，所以用逻辑卷也可以达到效果）
df -h
lsblk
vgs
lvs
lvcreate -n minio1 -L 2G ubuntu-vg
lvcreate -n minio2 -L 2G ubuntu-vg
lvcreate -n minio3 -L 2G ubuntu-vg
lvcreate -n minio4 -L 2G ubuntu-vg
mkfs.ext4 /dev/ubuntu-vg/minio1
mkfs.ext4 /dev/ubuntu-vg/minio2
mkfs.ext4 /dev/ubuntu-vg/minio3
mkfs.ext4 /dev/ubuntu-vg/minio4
echo "/dev/ubuntu-vg/minio1 /data/minio1 ext4 defaults 0 0" >> /etc/fstab
systemctl daemon-reload && mount -a
df -h
chown -R minio-user:minio-user /data/  && ll /data
systemctl restart minio && systemctl status minio && sleep 2 && ss -tunlp | grep 9001
```

```powershell
for i in {1..4}; do lvcreate -n minio$i -L 2G ubuntu-vg; done

for i in {1..4}; do mkfs.ext4 /dev/ubuntu-vg/minio$i; done

for i in {1..4}; do echo "/dev/ubuntu-vg/minio$i /data/minio$i ext4 defaults 0 0" >> /etc/fstab; done
```

> - 对于重复的指令，我在下面做一个能达到同样效果的 for 循环；
> - 通过指令：df -h && lvs 查看卷组和规划划分多少逻辑卷！
> - fstab 修改后 systemd 不会自动重载配置，需要手动执行 `systemctl daemon-reload` 来更新 systemd 的 mount units，否则 systemd 会继续使用旧的挂载配置。
> - 创建一个 Buckets （自定义名称 library01），在这个存储桶中上传一个文件，查看目录结构 tree /data ，文件被切分成若干数据块和校验块，分布在四个磁盘中，用于容错和数据冗余。
> - 查看这个目录下的数据存储变化，上传 100M 文件后，磁盘占用约 200M，这是因为 MinIO 使用了纠删码，生成了冗余块来保证容错。
> - 模拟故障：删除 /data/minio3 磁盘后，MinIO 仍然可以正常访问对象，因为纠删码允许容忍单个磁盘故障。



###### **Client**

- 下载地址：https://www.min.io/download
- **编程语言API访** —— Python 访问

```powershell
apt update && apt -y install python3-pip
python3 -m pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip3 install minio --break-system-packages
pip3 install minio
```

```powershell
cat > access_minio.py <<eof
#!/usr/bin/python3
import os
from minio import Minio
from minio.error import S3Error
# from minio.error import (ResponseError, BucketAlreadyOwnedByYou, BucketAlreadyExists)
# ↑ 旧版 MinIO SDK 使用 ResponseError，新版已经统一为 S3Error

# 初始化 MinIO 客户端
# endpoint：MinIO 服务监听的地址（服务器IP:端口）
# access_key / secret_key：MinIO 的登录凭据
# secure=False：关闭 https（因为你本地 9000 是 http）
minio_client = Minio(
    endpoint='10.0.0.201:9000',
    access_key="B1veDyVuy1alQjSSorbG",
    secret_key="fLhxFx6mZ4EbjXPbxBklw0dCGsaPGC47T4ayv1HO",
    secure=False
)

# 创建存储桶，定义存储桶名、对象名、本地文件路径
bucket_name = "mybucket"
object_name = "mc"
local_file_path = "/root/mc"       
# 将 /root/mc 上传为 mc

try:
    # 检查 bucket 是否存在
    # 若不存在，创建一个同名 bucket
    if not minio_client.bucket_exists(bucket_name):
        minio_client.make_bucket(bucket_name)
        print(f"Bucket '{bucket_name}' created successfully.")
    else:
        print(f"Bucket '{bucket_name}' already exists.")

    # 使用 fput_object 上传文件
    # 参数：bucket、对象名、本地路径
    minio_client.fput_object(bucket_name, object_name, local_file_path)
    print(f"Successfully uploaded '{local_file_path}' to '{object_name}'.")

except S3Error as e:
    # 捕获 MinIO/S3 API 的通用异常
    print(f"An error occurred: {e}")

# 定义下载后的文件名
downloaded_file_path = "example-object.txt"

try:
    # 从 MinIO 下载对象到本地
    minio_client.fget_object(bucket_name, object_name, downloaded_file_path)
    print(f"Successfully downloaded '{object_name}' to '{downloaded_file_path}'.")

except S3Error as e:
    # 捕获下载失败的异常
    print(f"An error occurred while downloading '{object_name}': {e}")
eof
```

```powershell
python3 access_minio.py
install mc /usr/local/bin/
mc --autocompletion
exit
mc --version
mc alias ls
echo "10.0.0.201 minio.duan.org" >> /etc/hosts
mc alias set minio-server http://minio.duan.org:9000 B1veDyVuy1alQjSSorbG fLhxFx6mZ4EbjXPbxBklw0dCGsaPGC47T4ayv1HO
mc ls minio-server
mc ls minio-server/mybucket
dd if=/dev/zero of=test.img bs=1M count=50
mc cp test.img minio-server/mybucket/test2.img  && mc ls minio-server/mybucket
mc cp minio-server/mybucket/test2.img /root/test3.img   && ll -sh /root/test3.img
mc rm minio-server/mybucket/test2.img  && mc ls minio-server/mybucket
mc admin info minio-server
mc du minio-server/mybucket
```

> - 安装、加速安装、pip3 安装 MinIO Python 客户端库——（二选一：强制安装、标准安装方式）
> - 登录网页，Access Keys —— Create access key —— Create 将 Access Key 和 Secret Key 两个访问秘钥写入上述的 Python 脚本中；
>   - B1veDyVuy1alQjSSorbG
>   - fLhxFx6mZ4EbjXPbxBklw0dCGsaPGC47T4ayv1HO
> - Python 脚本运行成功，服务器查看文件 tree /data/minio/   客户端查看下载地址 ll -sh /root
> - 安装 MC 客户端：install mc /usr/local/bin/
> - 安装 MC 客户端命令自动补全功能：mc --autocompletion   这个指令本质上是修改 .bashrc 文件；安装完成后需要重新登录才能生效！
>   - 查看版本信息：mc --version
>   - 查看默认连接信息：mc alias ls
>   - 查看指定的存储桶已使用的磁盘空间：mc du minio-server/mybucket
>   - 查看 MinIO 服务器或集群的整体状态信息 （重要） ：mc admin info minio-server
> - 创建客户端与10.0.0.201服务器之间的认证指令，指令成功执行后会将信息刷入到 /root/.mc/config.json 文件中，再次查看会看到一个minio-server 模块
>   - 列出指定 MinIO 服务中的所有 Bucket（存储桶）：mc ls minio-server
>   - 上传文件到指定的 Bucket 并命令为 test2.img ：mc cp test.img minio-server/mybucket/test2.img  && mc ls minio-server/mybucket
>   - 下载指定的 Bucket 文件到客户端并命令为 test3.img ：mc cp minio-server/mybucket/test2.img test.img   && mc ls minio-server/mybucket
>   - 删除指定的 Bucket 文件 ：mc rm minio-server/mybucket/test2.img  && mc ls minio-server/mybucket



#### 高可用集群架构部署

- 客户端：10.0.0.200
- 反向代理服务器：10.0.0.100
- Minio1服务器：10.0.0.201
- Minio2服务器：10.0.0.202
- Minio3服务器：10.0.0.203

###### Minio 服务器

```powershell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-04-22T22-12-26Z
install minio.RELEASE.2025-04-22T22-12-26Z  /usr/local/bin/minio
minio --version && which minio
useradd -M -r -s /sbin/nologin minio && id minio
mkdir -p /data/minio{1..4} && tree /data

df -h && vgs && lvs
for i in {1..4}; do lvcreate -n minio$i -L 2G ubuntu-vg; done 
for i in {1..4}; do mkfs.ext4 /dev/ubuntu-vg/minio$i; done 
for i in {1..4}; do echo "/dev/ubuntu-vg/minio$i /data/minio$i ext4 defaults 0 0" >> /etc/fstab; done 
systemctl daemon-reload && mount -a && df -h

cat >> /etc/hosts <<eof
10.0.0.201 minio1.duan.org
10.0.0.202 minio2.duan.org
10.0.0.203 minio3.duan.org
eof
cat > /etc/default/minio <<eof
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=12345678
MINIO_VOLUMES='http://minio{1...3}.duan.org:9000/data/minio{1...4}'
MINIO_OPTS='--console-address :9001'
MINIO_PROMETHEUS_AUTH_TYPE="public"
eof
cat > /lib/systemd/system/minio.service <<'eof'
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target
[Service]
WorkingDirectory=/usr/local
User=minio
Group=minio
EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-1000
[Install]
WantedBy=multi-user.target
eof


systemctl daemon-reload 
chown -R minio:minio /data/minio* && ll /data
systemctl start minio.service ; systemctl status minio.service && sleep 1 && ss -tunlp | grep 9001
journalctl -u minio -f
```

###### 反向代理服务器 

```powershell
apt update && apt -y install haproxy
systemctl  status haproxy.service
cat > /etc/haproxy/haproxy.cfg <<'eof'
listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    stats uri /haproxy-status
    stats realm HAProxy\ Statistics
    stats auth admin:123123

listen minio
    bind 10.0.0.100:9000
    mode http
    log global
    balance roundrobin
    option httpchk
    server minio1 10.0.0.201:9000 check inter 3000 fall 2 rise 5
    server minio2 10.0.0.202:9000 check inter 3000 fall 2 rise 5
    server minio3 10.0.0.203:9000 check inter 3000 fall 2 rise 5

listen minio_console
    bind 10.0.0.100:9001
    mode http
    log global
    balance roundrobin
    option httpchk
    server console1 10.0.0.201:9001 check inter 3000 fall 2 rise 5
    server console2 10.0.0.202:9001 check inter 3000 fall 2 rise 5
    server console3 10.0.0.203:9001 check inter 3000 fall 2 rise 5
eof
```

###### Minio 客户端

```powershell
echo "10.0.0.100 minio.duan.org" >> /etc/hosts
mc alias ls
mc alias set minio-cluster http://minio.duan.org:9000 e9ybiEOnT0tKavOaKjyj uVUJKa3gofMkdIgNMyTqtU0sOkEm15vUvcT4Od4u
mc admin info minio-cluster
mc mb minio-cluster/testbucket
mc mb minio-cluster/testbucket
```

- 集群部署：三个节点，每个节点四块硬盘；
  - 通过指令：df -h && lvs 查看卷组和规划划分多少逻辑卷！
- 准备三台主机,在所有节点上做好名称解析；
- 创建四块硬盘，或者创建四个逻辑卷；每个主机的四块磁盘格式化,并分别挂载到 /data/minio{1..4}
- ExecStartPre 用于 启动前检查 MINIO_VOLUMES 是否已经配置，如果没有配置就阻止 MinIO 启动并给出提示。
- 查看日志：journalctl -xeu minio.service 或者 journalctl -u minio -f
- 查看集群：进入网站 —— Monitoring —— Metrics 
- 配置反向代理,通过 Haproxy 或者 Nginx 实现 minio 的反向代理；
  - 登录：10.0.0.100:9999/haproxy-status
  - 账户密码：admin      123123
- MinIO 客户端 mc 创建别名，用于登录并保存连接信息；
  - mc alias set minio-cluster http://minio.duan.org:9000 e9ybiEOnT0tKavOaKjyj uVUJKa3gofMkdIgNMyTqtU0sOkEm15vUvcT4Od4u
  - 如果有原先的实验残留，记得删除：mc alias ls | grep -q minio-server && mc alias rm minio-server
  - 客户端查看集群信息：mc admin info minio-cluster
  - 客户端以指令方式创建一个存储桶：mc mb minio-cluster/testbucket



#### 模拟故障

```powershell
dd if=/dev/zero of=test.img bs=1M count=50
mc cp test.img minio-cluster/testbucket/test1.img  && mc ls minio-cluster/testbucket
systemctl stop minio && systemctl  status minio
mc admin info minio-cluster
mc cp minio-cluster/testbucket/test1.img test2.img && ll ./
mc cp test.img minio-cluster/testbucket/test3.img  && mc ls minio-cluster/testbucket
```

- 客户端上传文件； 
- 在 Minio3 （10.0.0.203） 节点执行 systemctl stop minio 模拟 Minio 节点故障；
- 客户端下载文件；测试在单节点故障时数据是否受影响；
- 客户端上传文件；测试在单节点故障时的写入功能；

#### 故障恢复

- 如果出现节点故障无法启动，可以直接服务器重置，重新部署 Minio Server 服务；
  - 若 IP 地址发生变动，对应的域名解析也要进行修改；
- 如果其他设备有安装包直接 scp 传输，就不重新下载了！
  - scp  minio.RELEASE.2025-04-22T22-12-26Z  10.0.0.204:/root

二进制部署 Minio Server 服务

```powershell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-04-22T22-12-26Z
install minio.RELEASE.2025-04-22T22-12-26Z  /usr/local/bin/minio
minio --version && which minio
useradd -M -r -s /sbin/nologin minio && id minio
mkdir -p /data/minio{1..4} && tree /data

df -h && vgs && lvs
for i in {1..4}; do lvcreate -n minio$i -L 2G ubuntu-vg; done && sleep 1
for i in {1..4}; do mkfs.ext4 /dev/ubuntu-vg/minio$i; done && sleep 1
for i in {1..4}; do echo "/dev/ubuntu-vg/minio$i /data/minio$i ext4 defaults 0 0" >> /etc/fstab; done 
systemctl daemon-reload && mount -a && df -h

若 IP 地址发生变动，对应的域名解析也要进行修改；对应的 Haproxy 或者 Nginx 反向代理服务配置也需要修改；

cat >> /etc/hosts <<eof
10.0.0.201 minio1.duan.org
10.0.0.202 minio2.duan.org
10.0.0.203 minio3.duan.org
eof
cat > /etc/default/minio <<eof
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=12345678
MINIO_VOLUMES='http://minio{1...3}.duan.org:9000/data/minio{1...4}'
MINIO_OPTS='--console-address :9001'
MINIO_PROMETHEUS_AUTH_TYPE="public"
eof
cat > /lib/systemd/system/minio.service <<'eof'
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target
[Service]
WorkingDirectory=/usr/local
User=minio
Group=minio
EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-1000
[Install]
WantedBy=multi-user.target
eof

systemctl daemon-reload 
chown -R minio:minio /data/minio* && ll /data
systemctl start minio.service ; systemctl status minio.service
```



#### 扩容

##### 基于 LVM 扩容

```powershell
vgs
for i in {1..4}; do lvextend -L +2G -r /dev/mapper/ubuntu--vg-minio$i; done 
df -Th
mc admin info minio-cluster
```

- 查看卷组剩余使用容量空间：vgs
- 逻辑卷增加 2GB，并自动扩容文件系统：lvextend -L +2G -r /dev/mapper/ubuntu--vg-minio1
- 查看磁盘空间、文件系统类型及扩容是否成功：df -Th
- 扩展知识点——删除逻辑卷：
  - 检查是否挂载：df -Th | grep minio
    - 如果有挂载，必须先关闭服务：systemctl stop minio
    - 然后卸载：umount /data/minio1
  - 删除逻辑：for i in {1..4}; do lvremove /dev/ubuntu-vg/minio$i; done 
    - 删除过程中系统会询问：Do you really want to remove active logical volume ...? [y/n]      输入 `y` 即可。
  - 确认删除结果：lvs  &&  vgs

##### 增加节点扩容

- 增加相同规格的集群（如果原有的规模是3个，那么扩容数量必须也是3的倍数）
- IP 地址发生变动，集群所有的节点对应的域名解析都要进行修改；对应的 Haproxy 或者 Nginx 反向代理服务配置也需要修改；
- 修改所有节点 /etc/default/minio 和 /etc/hosts 文件；
- 停止原有集群服务；
- 二进制部署MinIO 实现3节点的分布式高可用集群的环境扩容；
- 这里就用其他节点的安装包，网络下载仅做参考；

```powershell
systemctl stop minio.service

wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2025-04-22T22-12-26Z
install minio.RELEASE.2025-04-22T22-12-26Z  /usr/local/bin/minio
minio --version && which minio
useradd -M -r -s /sbin/nologin minio && id minio
mkdir -p /data/minio{1..4} && tree /data

df -h && vgs && lvs
for i in {1..4}; do lvcreate -n minio$i -L 2G ubuntu-vg; done && sleep 1
for i in {1..4}; do mkfs.ext4 /dev/ubuntu-vg/minio$i; done && sleep 1
for i in {1..4}; do echo "/dev/ubuntu-vg/minio$i /data/minio$i ext4 defaults 0 0" >> /etc/fstab; done 
systemctl daemon-reload && mount -a && df -h

cat >> /etc/hosts <<eof
10.0.0.201 minio1.duan.org
10.0.0.202 minio2.duan.org
10.0.0.203 minio3.duan.org
10.0.0.204 minio4.duan.org
10.0.0.205 minio5.duan.org
10.0.0.206 minio6.duan.org
eof
cat > /etc/default/minio <<eof
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=12345678
MINIO_VOLUMES='http://minio{1...3}.duan.org:9000/data/minio{1...4} http://minio{4...6}.wang.org:9000/data/minio{1...4}'
MINIO_OPTS='--console-address :9001'
MINIO_PROMETHEUS_AUTH_TYPE="public"
eof
cat > /lib/systemd/system/minio.service <<'eof'
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-noline.target
After=network-noline.target
[Service]
WorkingDirectory=/usr/local
User=minio
Group=minio
EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-1000
[Install]
WantedBy=multi-user.target
eof

systemctl daemon-reload 
chown -R minio:minio /data/minio* && ll /data
systemctl start minio.service ; systemctl status minio.service
```

修改haproxy代理配置

```powershell
apt update && apt -y install haproxy
systemctl  status haproxy.service
cat > /etc/haproxy/haproxy.cfg <<'eof'
listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    stats uri /haproxy-status
    stats realm HAProxy\ Statistics
    stats auth admin:123123

listen minio
    bind 10.0.0.100:9000
    mode http
    log global
    balance roundrobin
    option httpchk
    server minio1 10.0.0.201:9000 check inter 3000 fall 2 rise 5
    server minio2 10.0.0.202:9000 check inter 3000 fall 2 rise 5
    server minio3 10.0.0.203:9000 check inter 3000 fall 2 rise 5
    server minio1 10.0.0.204:9000 check inter 3000 fall 2 rise 5
    server minio2 10.0.0.205:9000 check inter 3000 fall 2 rise 5
    server minio3 10.0.0.206:9000 check inter 3000 fall 2 rise 5

listen minio_console
    bind 10.0.0.100:9001
    mode http
    log global
    balance roundrobin
    option httpchk
    server console1 10.0.0.201:9001 check inter 3000 fall 2 rise 5
    server console2 10.0.0.202:9001 check inter 3000 fall 2 rise 5
    server console3 10.0.0.203:9001 check inter 3000 fall 2 rise 5
    server minio1 10.0.0.204:9000 check inter 3000 fall 2 rise 5
    server minio2 10.0.0.205:9000 check inter 3000 fall 2 rise 5
    server minio3 10.0.0.206:9000 check inter 3000 fall 2 rise 5
eof
```

- 登录 Haproxy 查看状态

#### 缩容

- 缩容有数据丢失的风险；
- 如果MinIO不是基于LVM的存储，缩容相当于重新部署集群；
- 缩容前所有节点的数据备份,再在配置中删除上面的添加的节点,只保留部分节点,重启服务后,再恢复数据
- 注意：缩容需要重建数据和Access Key 信息

```powershell
systemctl stop minio && systemctl status minio

vim /etc/default/minio
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=12345678
# MINIO_VOLUMES='http://minio{1...3}.duan.org:9000/data/minio{1...4} http://minio{4...6}.wang.org:9000/data/minio{1...4}'
MINIO_VOLUMES='http://minio{1...3}.duan.org:9000/data/minio{1...4}'
MINIO_OPTS='--console-address :9001'
MINIO_PROMETHEUS_AUTH_TYPE="public"

systemctl restart minio ; systemctl status minio
```

```powershell
mc admin info minio-cluster
```

- 备份数据：略
- 还原数据：略







