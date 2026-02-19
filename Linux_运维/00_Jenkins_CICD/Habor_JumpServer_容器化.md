## Docker

### Docter安装方法

#### APT安装（Ubuntu）

```bash
# 安装前环境准备：
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
# 写入软件源信息
add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# 更新并安装docker-ce
apt-get update 
# 查找docker-ce的版本
apt-cache madison docker-ce
# 指定版本安装
apt-get -y install docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic
```

#### 二进制安装

```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-28.5.1.tgz
tar xvf docker-28.5.1.tgz
chmod +x  docker/*
cp docker/* /usr/local/bin/
ls /usr/local/bin

# 创建systemd服务
vi /lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target

systemctl daemon-reload && systemctl restart docker

如果docker启动失败，检查自己的docker的依赖包是不是有所缺少，比如iptables
iptables --version
apt install -y iptables
```

#### 命令自动补全

```bash
curl -L https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
wc -l /etc/bash_completion.d/docker.sh
# exit #重新登录生效
```

### 

## **Docker-compose**

- 准备：下载程序docker-compose  ;  配置文件 docker-compose.yaml
- 创建一个容器项目相关的文件；
- 创建一个自定义网络，以此规划相关的容器网络；
- 按照项目自动管理容器；
- 生产中运用较少，常用与测试环境，因为所有容器都运行在同一个主机；
- 支持json文件，但是基本上都是用yaml文件

### 安装方法之离线安装 （推荐）

下载网址: https://github.com/docker/compose/releases

- 通过科学力量进入上述的网址，找到适合自己版本的docker-compose文件下载到本地（相信大家都是windows系统的电脑吧！）然后通过远程工具（比如：SecureCRT）将本地文件拷贝到虚拟机中！
  - mv docker-compose-linux-x86_64 docker-compose
  - chmod +x docker-compose 
  - mv docker-compose /usr/local/bin/
  - ll /usr/local/bin/docker-compose

- **也可以通过国内官方软件源下载 (不推荐，理论上可以，实践中我没有成功！！！)**

```powershell
# 使用阿里云镜像（推荐）
sudo curl -L https://aliyun-docker-compose.oss-cn-hangzhou.aliyuncs.com/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

# 给docker-compose添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
ll /usr/local/bin/
```

![img](https://cdn.nlark.com/yuque/0/2025/png/61781121/1762680526524-1242b197-5af7-49f6-b20c-5db7db65d27e.png)



### Harbor 分布式仓库 

- 准备环境：docker服务和docker-compose

#### 安装方法之离线安装 （推荐）

下载地址: https://github.com/vmware/harbor/releases

- 通过科学力量进入上述的网址，找到适合自己版本的harbor文件下载到本地，然后通过远程工具（比如：SecureCRT）将本地文件拷贝到虚拟机中！

![img](https://cdn.nlark.com/yuque/0/2025/png/61781121/1762684244894-3122f67e-9cfe-4dcf-be48-bd6bc09d4d88.png)

10.0.0.147 harbor.duan.org

```powershell
# 解压文件
tar xvf harbor-offline-installer-v2.14.0.tgz -C /usr/local/

# 进入解压后的harbor文件, 顺便创建一个目录
cd /usr/local/harbor/  & mkdir -p /data/harbor
# 加载harbor文件 （其实就是加载文件中的一堆镜像堆砌）
docker load -i harbor.v2.14.0.tar.gz
# 修改harbor范例文件
mv  harbor.yml.tmpl  harbor.yml
vi harbor.yml
hostname: 10.0.0.147			# 改为宿主机地址
# https related config		# 将https注释 ， 因为https还需要配置证书验证 ，没必要的话就关掉它！
#https:
  # https port for harbor, default is 443
  # port: 443
  # The path of cert and key files for nginx
  #certificate: /your/certificate/path
  #private_key: /your/private/key/path
  # enable strong ssl ciphers (default: false)
  # strong_ssl_ciphers: false
harbor_admin_password: 123123		# 修改密码，输入方便，也好记！
data_volume: /data/harbor				# 设置harbor镜像存放位置，如果有一块磁盘专门存放更好！

#　执行harbor程序
cd /usr/local/harbor  &&　./install.sh
# 执行结束会自动生成一个docker-compose.yml文件，编辑修改其中的network模块
root@ubuntu2404-147:/usr/local/harbor# tail -n6 docker-compose.yml 
networks:
  harbor:
    ipam:
      driver: default
      config:
      - subnet: 172.27.0.0/24

# 在该目录下启动docker-compose
docker-compose up -d
# 关闭harbor程序，则是对该项目的yaml文件进行down
docker-compose down 
# 注意，必须在docker-compose.yaml文件所在位置，启动或者关闭

# 配置文件中默认设置开机自启，但要实现还是需要编辑一个service文件 (可选)
cat > /lib/systemd/system/harbor.service << eof
[Unit]
Description=Harbor
After=docker.service systemd-networkd.service systemd-resolved.service
Requires=docker.service
Documentation=http://github.com/vmware/harbor
[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/bin/docker-compose -f /usr/local/harbor/docker-compose.yml up
ExecStop=/usr/bin/docker-compose -f /usr/local/harbor/docker-compose.yml down
[Install]
WantedBy=multi-user.target
eof
# 加载并重启
systemctl daemon-reload
systemctl restart docker		

# 浏览器输入宿主机IP   10.0.0.147  访问 ；
# 账户：admin   密码：123123
# 设置项目为公开（根据实际需求变化）
# 新建账户，用户名：duan 密码： Duan0714
# 选择一个项目，在成员中添加新创建的用户，如果只是上传下载，角色定位在开发者；
# 在项目的镜像仓库查看上传的镜像文件；

# 上传前先打标签
docker tag nginx:1.1 10.0.0.147/example/nginx:1.1
# 然后就是登陆，但是登陆之前添加宿主机ip为不安全可通过策略中 ，修改json文件
more /etc/docker/daemon.json 
    {
["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"],
      "insecure-registries": ["harbor.wang.org","10.0.0.147"],
      "data-root": "/data/docker"
     }

# 登陆开发者账号（第一次需要，除非账号存储文件丢失！）
docker login 10.0.0.147 -u duan -p Duan0714
docker login 10.0.0.147 -u admin -p 123123
docker login harbor.duan.org -u admin -p 123123
#扩展# 弹出提示，信息保存在/root/.docker/config.json 文件中 ， 查看该文件
cat /root/.docker/config.json 
{
        "auths": {
                "10.0.0.147": {
                        "auth": "ZHVhbjpEdWFuQDA3MTQ="
                }
        }
# 这个加密可以轻松解密，所以不要不把他不当回事！
root@ubuntu2404-147:~#  echo ZHVhbjpEdWFuQDA3MTQ= | base64 -d
duan:Duan@0714
# 查看harbor仓库大小
du -sh /data/harbor
# 上传镜像到harbor仓库
docker push 10.0.0.147/library/nginx:1.1
# 再次查看harbor仓库大小
du -sh /data/harbor

# 图示：在浏览器进入harbor项目-->镜像仓库-->(选择一个镜像)点击-->(artifactl列中的文件)点击
# 客户端若需要拉取harbor仓库中的镜像，需要添加harbor服务器的ip到不安全策略中
more /etc/docker/daemon.json 
    {
      "registry-mirrors": ["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"],
      "insecure-registries": ["harbor.wang.org","10.0.0.147"]
     }
# 客户端拉取镜像
docker pull 10.0.0.147/library/nginx:1.1
```



![img](https://cdn.nlark.com/yuque/0/2025/png/61781121/1762688325576-36d84283-86b2-405b-b8d4-0c2e0149e2ff.png)

### Harbor 双向复制（高可用 ）

重复上面 Harbor 离线安装，在两台设备中分别部署一套 Harbor 服务

环境：

- 宿主机都是ubuntu2404系统；（可变）
- 宿主机A是10.0.0.147/24；容器harbor做上传push使用 ；容器harbor网段172.27.0.0/24
- 宿主机B是10.0.0.148/24；容器harbor网段172.28.0.0/24

>  进入浏览器输入：10.0.0.147:80 ---> 登陆账号admin密码123123 
>
>  用户管理 ---> 创建用户        进入项目中的成员添加用户并授权
>
>  仓库管理 ---> 新建目标 ---> 配置仓库地址，是否选验证证书根据仓库主机的http与https协议勾选
>
>  复制管理 ---> 新建图形 ---> 如图所示配置目标仓库和事件驱动 ---> 点击 ‘复制’ （仅首次点一下，后续自动增量复制）

![image-20251111100612149](C:\Program Files\Obsidian\data\Obsidian_Vault\image-20251111100612149.png)



![image-20251111100539917](C:\Program Files\Obsidian\data\Obsidian_Vault\image-20251111100539917.png)

![](C:\Program Files\Obsidian\data\Obsidian_Vault\image-20251111095040002.png)

![image-20251111094630770](C:\Program Files\Obsidian\data\Obsidian_Vault\image-20251111094630770.png)



### Harbor 双向复制 + 负载均衡

> 设备：负载均衡--10.0.0.10  ； 客户端测试-- 10.0.0.100
>
> 服务：主机10.0.0.10，docker中运行容器 nginx:1.24 （在宿主机中运行nginx也可以）
>
> 服务：主机10.0.0.100，因为要做上传测试，所以也需要做docker服务

```powershell
创建负载均衡配置文件
vi harbor.duan.org.conf
upstream harbor {
#     ip_hash $remote_addr;				# 根据ip的前三位进行哈希运算
     hash $remote_addr;					# 根据整个ip进行哈希运算
     server 10.0.0.147;
     server 10.0.0.148;
}

server {
     listen 80;
     server_name harbor.duan.org;
     client_max_body_size 10g;			# 默认传输1M ，所以需要优化
     location / {
      proxy_pass http://harbor;
     }
}

启动容器并加载配置文件
docker run -d --name harbor-proxy -p 80:80 -v ./harbor.duan.org.conf:/etc/nginx/conf.d/harbor.duan.org.conf nginx:1.24

电脑主机添加域名解析
C:\Windows\System32\drivers\etc\hosts
10.0.0.10 harbor.duan.org
harbor服务器hostname修改为域名
vi /usr/local/harbor/harbor.yml
hostname: harbor.duan.org
为客户机添加域名解析
vi /etc/hosts
10.0.0.10 harbor.duan.org
客户机添加域名到不安全策略中
cat /etc/docker/daemon.json 
    {
      "insecure-registries": ["harbor.duan.org"],
      "data-root": "/data/docker"
     }

浏览器输入域名：harbor.duan.org  登陆harbor网页
在客户机：打标签--登陆--上传
```

==搞不定==

> root@100:~# docker login harbor.duan.org -u duan -p Duan0714
> WARNING! Using --password via the CLI is insecure. Use --password-stdin.
> Error response from daemon: Get "http://harbor.duan.org/v2/": Get "http://harbor/service/token?account=duan&client_id=docker&offline_token=true&service=harbor-registry": dial tcp: lookup harbor on 127.0.0.53:53: server misbehaving

没办法，试一试四层代理--haproxy

```powershell
负载均衡服务器
apt install haproxy
systemctl status haproxy
vi /etc/haproxy/haproxy.cfg
listen harbor
    bind 10.0.0.10:80
    balance roundrobin
    server harbor1 10.0.0.147:80 check
    server harbor2 10.0.0.148:80 check
查看IP和端口有没有监听
ss -tunlp | grep 10.0.0.10:80
在客户端测试，打完标签后登陆
docker login harbor.duan.org -u admin -p 123123
上传
docker push harbor.duan.org/library/nginx:mainline-alpine3.22 
```



### Harbor 安全 Https 配置

官方文档：[Harbor docs | Configure HTTPS Access to Harbor](https://goharbor.io/docs/2.12.0/install-config/configure-https/)

 **生成 Harbor 服务器证书** （在harbor服务器中）

```powershell
#创建证书相关数据的目录
mkdir -p /data/harbor/certs
cd /data/harbor/certs

#生成ca的私钥
openssl genrsa -out ca.key 4096

#生成ca的自签名证书
openssl req -x509 -new -nodes -sha512 -days 3650 \
-subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=ca.duan.org" \
-key ca.key \
-out ca.crt

#生成harbor主机的私钥
openssl genrsa -out harbor.duan.org.key 4096

#生成harbor主机的证书申请，注意：CN的名称一定是访问harbor的主机域名
openssl req -sha512 -new \
-subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.duan.org" \
-key harbor.duan.org.key \
-out harbor.duan.org.csr

#创建x509 v3 扩展文件(新版新增加的要求)
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=harbor.duan.org #此处必须和和harbor的网站名称一致
# DNS.2=duan #可选
# DNS.3=duan.org #可选
EOF

#给harbor主机颁发证书
openssl x509 -req -sha512 -days 3650 \
-extfile v3.ext \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-in harbor.duan.org.csr \
-out harbor.duan.org.crt

openssl x509 -in harbor.duan.org.crt -noout -text

#最终文件列表如下
root@ubuntu2404-147:/data/harbor/certs# ls
ca.crt  ca.key  ca.srl  harbor.duan.org.crt  harbor.duan.org.csr  harbor.duan.org.key  v3.ext
```

 **配置 Harbor 服务器使用证书** （在harbor服务器中）

```powershell
编辑harbor配置文件
hostname: harbor.wang.org
# 注意：此行必须是网站的域名，而且harbor主机的/etc/hosts可以不解析此域名，不能是IP地址，否则登录时会报错;
vi /usr/local/harbor/harbor.yml 
https:
  port: 443
  certificate: /data/harbor/certs/harbor.duan.org.crt
  private_key: /data/harbor/certs/harbor.duan.org.key
  
#使上面的配置生效
cd /usr/local/harbor/
./prepare
docker-compose down -v
docker-compose up -d
```

**配置 Docker 客户端使用证书文件**

```powershell
#转换harbor的crt证书文件为cert后缀,docker识别crt文件为CA证书,cert为客户端证书
openssl x509 -inform PEM -in harbor.duan.org.crt -out harbor.duan.org.cert
#比较crt与cert两个文件的不同
diff harbor.duan.org.crt harbor.duan.org.cert
md5sum harbor.duan.org.crt harbor.duan.org.cert		# 更严谨的判断
#会发现crt与cert两个文件内容相同，所以也可以cp拷贝
cp -a harbor.wang.org.crt harbor.wang.org.cert

——————分割线——————

电脑主机添加域名解析(不同于负载均衡)
C:\Windows\System32\drivers\etc\hosts
10.0.0.147 harbor.duan.org
10.0.0.148 harbor.duan.org
在客户端中编辑域名缓存文件
vi /etc/hosts
10.0.0.147 harbor.duan.org
10.0.0.148 harbor.duan.org
清楚登陆信息文件
rm -rf /root/.docker/config.json
关闭docker中的不安全策略，使流量走https协议
cat  /etc/docker/daemon.json 
    {
      "registry-mirrors": ["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"]
     }
     
——————分割线——————

方法一：
# 创建文件夹
mkdir -p /etc/docker/certs.d/harbor.duan.org
# 获取crt文件
cd /etc/docker/certs.d/harbor.duan.org && scp 10.0.0.148:/data/harbor/certs/harbor.duan.org.crt .
方法二：
# 获取crt文件
cd /etc/ssl/certs  && scp 10.0.0.148:/data/harbor/certs/ca.crt  .
cat ca.crt >>  /etc/ssl/certs/ca-certificates.crt
ll /etc/ssl/certs/ca-certificates.crt

重启docker服务
systemctl  restart docker

每个客户端都是如此部署操作！
客户端测试
docker login harbor.duan.org -u duan  -p Duan0714
浏览器测试
输入：harbor.duan.org
```





### JumpServer

#### 基于 docker  安装

- 部署docker与docker-compose ， 具体参考上述笔记；
- 如果是早期的mysql ， 还需要在mysqld.cnf配置文件中指定字符集character-set-server=utf8

```powershell
# 拉取镜像
docker pull jumpserver/jms_all:v4.10.12
docker pull mysql:8.0.29-oracle
docker pull redis:7.2.5
# 创建自定义网络
docker network create --subnet 172.30.0.0/24 jumpserver-net
# MySQL8.0需要修改验证插件
cat mysqld.cnf
[mysqld]
default_authentication_plugin=mysql_native_password
# 启动MySQL容器
docker run --name mysql \
  -e MYSQL_ROOT_PASSWORD=123123 \
  -e MYSQL_DATABASE=jumpserver \
  -e MYSQL_USER=jumpserver \
  -e MYSQL_PASSWORD=123123 \
  -v ./mysqld.cnf:/etc/mysql/conf.d/mysqld.cnf \
  -v /data/mysql:/var/lib/mysql \
  --restart always \
  --network jumpserver-net \
  -d \
  mysql:8.0.29-oracle
# 启动Redis容器
docker run -d --name redis \
  --restart always \
  --network jumpserver-net \
  -v /data/redis:/data \
  redis:7.4 \
  redis-server --requirepass 123123
 # 生成相关key (为后续启动jumpserver做准备)
 cat /dev/urandom | tr -dc '[:alnum:]' | head -c50		# 生成 SECRET_KEY（50位）
 cat /dev/urandom | tr -dc '[:alnum:]' | head -c30		# 生成 BOOTSTRAP_TOKEN（32位）
 tail -n2 .bashrc
 # 运行jumpserver
 docker run --name jms_all -d \
  -p 80:80 \
  -p 2222:2222 \
  -p 30000-30003:30000-30003 \
  -e SECRET_KEY=aWigujYvOh3ODFjb0qLUCyTGxh7SjRGCDKccMPScZBySjG6T08 \
  -e BOOTSTRAP_TOKEN=dHHmKjXtNDNmDoebn0S8PDFZiZlp48 \
  -e LOG_LEVEL=ERROR \
  -e DB_ENGINE=mysql \
  -e DB_HOST=mysql \
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=123123 \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=123123 \
  --privileged=true \
  -v /opt/jumpserver/core/data:/opt/jumpserver/data \
  -v /opt/jumpserver/koko/data:/opt/koko/data \
  -v /opt/jumpserver/lion/data:/opt/lion/data \
  -v /opt/jumpserver/kael/data:/opt/kael/data \
  -v /opt/jumpserver/chen/data:/opt/chen/data \
  -v /opt/jumpserver/web/log:/var/log/nginx \
  --network jumpserver-net \
  jumpserver/jms_all:v4.10.12
# 查看jumpserver日志确认成功
docker logs -f jms_all
#  查看 MySQL 中生成相关表 （验证失败）
docker exec -it mysql sh
mysql -ujumpserver -p123123 
# 查看端口 (30001-30003,2222,80)
ss -tunlp 
# 查看内存
free -h
# 默认账户：admin
# 默认密码：ChangeMe			修改密码：123123

```

#### 扩展芝士

##### 镜像打包

```powershell
前言：
	将主机A中的镜像打包传给主机B ；主机B加载镜像包
方法一：
# 打包镜像为 tar 文件
docker save -o jumpserver-v4.10.12.tar 63eaf6028b7b
# 查看打包的文件
ls -lh jumpserver-v4.10.12.tar
# 传输文件到目标主机
scp jumpserver-v4.10.12.tar 10.0.0.201:/root
# 在目标主机上加载镜像
docker load -i jumpserver-v4.10.12.tar
# 验证镜像
docker images | grep jumpserver
# 为镜像打上名称和标签
docker tag 63eaf6028b7b jumpserver:v4.10.12
——————分割线——————
方法二：
# 打包并压缩
docker save jumpserver/jms_all:v4.10.12 | gzip > jumpserver-v4.10.12.tar.gz
#　传输压缩文件
scp jumpserver-v4.10.12.tar.gz user@target-host:/path/
# 在目标主机加载（也可以先解压再加载）
docker load -i jumpserver-v4.10.12.tar.gz
# 检查镜像ID是否一致
docker images --no-trunc | grep 63eaf6028b7b
——————分割线——————
# vim编辑器中查看隐藏字符
:set list
```

##### **同步系统时间** 

```powershell
# 方法一：使用 timedatectl
# 安装 NTP 服务（如果未安装）
sudo apt install systemd-timesyncd
# 启用并启动时间同步
sudo timedatectl set-ntp true
# 检查状态
timedatectl status

#方法二：使用 ntpdate 强制同步（推荐）
# 安装 ntpdate
sudo apt install ntpdate
# 强制同步时间（使用阿里云NTP服务器）
sudo ntpdate -u ntp.aliyun.com
```

##### 设置时区

```powershell
# 设置时区为上海
sudo timedatectl set-timezone Asia/Shanghai
# 验证设置
timedatectl
```



查看当前系统架构

```powershell
uname -m
dpkg --print-architecture
```



##### 离线下载安装软件包

```powershell
# 在 A 主机上先下载但不安装
apt download maven
# 拷贝 deb 包到 B 主机
scp maven_3.8.7-2_all.deb  10.0.0.200:/root/
# 在 B 主机上安装
dpkg -i maven_3.8.7-2_all.deb
# 如果出现依赖问题，运行以下命令修复
sudo apt-get install -f
# 检查 Maven 版本
mvn -version
# 检查安装路径
which mvn
```

##### 指令

```powershell
# 导出/导入镜像（离线迁移）
docker save -o [文件名].tar [镜像名]:[标签]
docker load -i [文件名].tar
# 为镜像打上名称和标签
docker tag 63eaf6028b7b jumpserver:v4.10.12
# 查看文件数量，以及文件中有多少行
root@ubuntu2404-203:~# find RuoYi/  -name  "*.java" | wc -l
271
root@ubuntu2404-203:~# find RuoYi/  -name  "*.java" | xargs cat | wc -l
35992
# 显示当前用户的所有资源限制;
ulimit -a 
# 对于传统方式（绝对路径启动关闭）编辑limits.conf
tail -n2 /etc/security/limits.conf 
root soft nofile 66666
root hard nofile 66666
# 对于主流方式（systemctl启动关闭）编辑ruoyi.service文件
cat /lib/systemd/system/ruoyi.service  | grep LimitNOFILE
LimitNOFILE=10000
# 查看服务进程优化数据（根据进程id查询）
ss -tunlp 
cat /proc/1129/limits
# harbor登陆
docker login harbor.wang.org -u magedu -p Magedu123

&&：与操作符 - 只有前面成功才执行后面
||：或操作符 - 只有前面失败才执行后面
;：顺序执行 - 无论前面成功与否都执行后面
```

##### lrzsz

```powershell
sudo apt install lrzsz
```



#### 基于 docker-compose 安装

```powershell
# 准备工作
vi mysqld.cnf
[mysqld]
default_authentication_plugin=mysql_native_password
# 根据docker run生成docker-compose.yaml文件
vi docker-compose.yaml
name: jumpserver
services:
    mysql:
        container_name: mysql
        environment:
            - MYSQL_ROOT_PASSWORD=123123
            - MYSQL_DATABASE=jumpserver
            - MYSQL_USER=jumpserver
            - MYSQL_PASSWORD=123123
        volumes:
            - ./mysqld.cnf:/etc/mysql/conf.d/mysqld.cnf
            - /data/mysql:/var/lib/mysql
        restart: always
        networks:
            - jumpserver-net
        image: mysql:8.0.29-oracle

    redis:
        container_name: redis
        restart: always
        networks:
            - jumpserver-net
        volumes:
            - /data/redis:/data
        image: redis:7.4
        command: redis-server --requirepass 123123
        
    jms_all:
        container_name: jms_all
        ports:
            - 80:80
            - 2222:2222
            - 30000-30003:30000-30003
        environment:
            - SECRET_KEY=aWigujYvOh3ODFjb0qLUCyTGxh7SjRGCDKccMPScZBySjG6T08
            - BOOTSTRAP_TOKEN=dHHmKjXtNDNmDoebn0S8PDFZiZlp48
            - LOG_LEVEL=ERROR
            - DB_ENGINE=mysql
            - DB_HOST=mysql
            - DB_PORT=3306
            - DB_USER=jumpserver
            - DB_PASSWORD=123123
            - DB_NAME=jumpserver
            - REDIS_HOST=redis
            - REDIS_PORT=6379
            - REDIS_PASSWORD=123123
        privileged: true
        volumes:
            - /opt/jumpserver/core/data:/opt/jumpserver/data
            - /opt/jumpserver/koko/data:/opt/koko/data
            - /opt/jumpserver/lion/data:/opt/lion/data
            - /opt/jumpserver/kael/data:/opt/kael/data
            - /opt/jumpserver/chen/data:/opt/chen/data
            - /opt/jumpserver/web/log:/var/log/nginx
        networks:
            - jumpserver-net
        image: jumpserver/jms_all:v4.10.12
networks:
  jumpserver-net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.30.0.0/24

# 启动、关闭
docker-compose up -d
docker-compose down
```

### 初始化部署

#### 软件源

ubuntu

- **noble** - Ubuntu 24.04 LTS (Noble Numbat) - **最新 LTS 版本**

- **jammy** - Ubuntu 22.04 LTS (Jammy Jellyfish) - 当前稳定 LTS 版本

- **focal** - Ubuntu 20.04 LTS (Focal Fossa) - 较旧 LTS 版本

```powershell
# 显示所有已配置的软件源
apt policy
# 查看主软件源配置
cat /etc/apt/sources.list
# 查看所有额外的软件源文件
ls -la /etc/apt/sources.list.d/
# 查看某个具体源文件的内容 (也可能是别的名字！)
cat /etc/apt/sources.list.d/ubuntu.sources

查看当前系统版本
cat /etc/os-release
```

编辑软件源的配置文件

```powershell
# 将原来的软件源文件改名为ubuntu.sources.bak，新建一个ubuntu.sources文件
cat > /etc/apt/sources.list.d/ubuntu.sources << eof
Types: deb
URIs: https://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.aliyun.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
eof

或者修改关键点：
ls /etc/os-release    # 查看系统版本信息
sed -i  "s@URIs:.*@URIs: http://mirrors.aliyun.com/ubuntu/@" "/etc/apt/sources.list.d/ubuntu.sources"
sed -i  "s@$VERSION_CODENAME@noble@g" "/etc/apt/sources.list.d/ubuntu.sources"

# 更新软件包列表
apt update
# 检查下载速度
sudo apt install -y wget curl
# 查看可更新软件包
apt list --upgradable
```



