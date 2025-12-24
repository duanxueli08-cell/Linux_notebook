# zabbix服务端部署(ubuntu2404)

## 软件源定制

> 如果软件源已经更换为阿里云或者其他的国内软件源，这一步可以忽略！

```powershell
# rm -rf /etc/apt/sources.list.d/*
# cat > /etc/apt/sources.list <<-eof
deb https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe
multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe
multiverse
deb https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe
multiverse
eof
# apt update
```

> 获取最新版本的zabbix软件源

```bash
# wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
# dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
# apt update
```



## 安装zabbix server 和 前端工具以及代理agent

```ba
# apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent 
```

### 安装数据库

```ba
# apt install mysql-server -y
注意：
如果mysql和zabbix server 没有在同一台主机上，需要开放对应的ip地址访问能力
```

### 定制数据库

```ba
# mysql
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by '123123';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;
```

### 准备数据环境

> 使用默认的sql文件，创建zabbix的数据库环境

```ba
# zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz |mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
Enter password: # 输入密码 password
```

> 对于ubuntu Desktop来说，上述的命令是可以正常执行成功的，但是在ubuntu server版本上，可能会出现如下问题

```ba
# zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz |
mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
Enter password:
ERROR 1419 (HY000) at line 2494: You do not have the SUPER privilege and binary
logging is enabled (you *might* want to use the less safe
log_bin_trust_function_creators variable)

解决方法：在 msyql数据库中，为该用户增加 SUPER权限即可
GRANT SUPER ON *.* TO zabbix@localhost;
```

### 检测效果

```ba
# mysql -uzabbix -p123123 -e "use zabbix;show tables;"
```

### 恢复数据库环境

> 将刚才为了导入数据库文件能力的 属性移除

```ba
mysql
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;
```

### 配置zabbix连接数据库

> 为Zabbix server配置数据库
>
> Zabbix Web 页面的账户密码： Admin	zabbix	（默认账户密码都是Admin，初次登陆会有修改密码的操作，改完后一定要记得哦！）

```ba
vim /etc/zabbix/zabbix_server.conf
DBPassword=123123

在这个文件中这些捎带着看一下：
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=123@123
DBPort=3306
ListenPort=10051
```

> 为Zabbix agent配置数据库

```ba
vi /etc/zabbix/zabbix_agentd.conf
Server=127.0.0.1,10.0.0.10
加入被监控的主机地址，也就是本机地址！

grep -Ev '#|^$' /etc/zabbix/zabbix_agentd.conf
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=127.0.0.1,10.0.0.10
ServerActive=127.0.0.1			# 主动检查的服务器IP
Hostname=master.zabbix.com		# 向服务器报告的身份
Include=/etc/zabbix/zabbix_agentd.d/*.conf
配置解读：
Hostname 是 Zabbix Agent 的唯一身份标识，用于告诉 Zabbix Server "我是谁"
在 Zabbix Web 界面中显示的主机名就是基于这个参数。
```

> 查看配置效果

```ba
grep -Env '#|^$' /etc/zabbix/zabbix_server.conf
grep -Env '#|^$' /etc/zabbix/zabbix_agentd.conf
```

## 前端的配置

### Nginx环境定制

> 查看软件文件

```ba
dpkg -L zabbix-nginx-conf
```

> 确认nginx的配置

```ba
egrep -v '#|^$' /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;
events {
worker_connections 768;
}
http {
sendfile on;
tcp_nopush on;
types_hash_max_size 2048;
include /etc/nginx/mime.types;
default_type application/octet-stream;
ssl_prefer_server_ciphers on;
access_log /var/log/nginx/access.log;
gzip on;
include /etc/nginx/conf.d/*.conf;		# 导入的配置
include /etc/nginx/sites-enabled/*;
}
```

> 删除默认的nginx首页配置文件

```ba
# rm -f /etc/nginx/sites-enabled/default
```

> 定制zabbix的配置文件

```ba
vim /etc/nginx/conf.d/zabbix.conf
server {
listen 80;
...

解析：
定制http配置段内部默认的server配置段属性
```

## PHP环境定制

> 修改php配置

```ba
cat /etc/zabbix/php-fpm.conf
[zabbix]
user = www-data
group = www-data
listen = /var/run/php/zabbix.sock
listen.owner = www-data
listen.allowed_clients = 127.0.0.1
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 200
php_value[session.save_handler] = files
php_value[session.save_path] = /var/lib/php/sessions/
php_value[max_execution_time] = 300
php_value[memory_limit] = 128M
php_value[post_max_size] = 16M
php_value[upload_max_filesize] = 2M
php_value[max_input_time] = 300
php_value[max_input_vars] = 10000
php_value[date.timezone] = Asia/Shanghai # 增加默认时区

解析：
主要是修改PHP的默认时间区域为亚洲上海。
如果后续登录zabbix的web页面第二步在检测必要条件方面没通过，那么根据提示可以在这个配置中修改。
```

> 重启服务

```ba
systemctl restart zabbix-server zabbix-agent nginx php8.3-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.3-fpm
注意：
zabbix的服务在ubuntu上安装后，不会自动设置为开机自启动。
```

> 检测效果

```ba
netstat -tnulp | egrep 're|ngi|php|zabb'
大概率结果显示：
nginx开启的是80端口，php开启的是9000端口
zabbix开启了多个端口10051(server)和10050(agent)
```

## web配置

### 浏览器访问Zabbix server主机的ip地址  http://10.0.0.10/   

### 选择默认语言为 中文，进行下一步

![image-20251015225910861](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015225910861.png)

> 注意：这里面的语言包需要提前安装，中文包在安装的时候，就已经安装好了。下面的两个包非必须安装

```ba
Ubuntu安装的中文包
apt -y install language-pack-zh-hans

CentOS安装的中文包
yum -y install langpacks-zh_CN
(Rocky Linux/RHEL/CentOS 7 及更早版本的默认工具)

rocky安装的中文包
dnf install glibc-langpack-zh -y
(Rocky Linux/RHEL/CentOS 8, 9+ 的默认和推荐工具)
```

### 检查必要条件

> 保证检查列表项状态全部是"OK"
>
> 如果有未通过检查项，根据提示去/etc/zabbix/php-fpm.conf配置中修改！

![image-20251015225952272](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015225952272.png)

### 配置数据连接

> 修改数据库的链接地址、端口、密码等信息，在此步的host也可以设置为127.0.0.1
> 注意：
> 如果你数据库定制了开放的ip，可以直接定制ip地址。

![image-20251015230125032](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015230125032.png)

### 设置

> 此处的Name可以不用设置，当然也可以设置一个名称，比如 Zabbix server，然后点击下一步即可

![image-20251015230316196](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015230316196.png)

### 登录

> 默认登录信息：
> 用户名：Admin
> 密码：zabbix

### php配置文件

> 当我们配置zabbix的web界面完毕后，会在zabbix的家目录下生成一个专用的web配置文件

```ba
查看zabbix的web界面的基本配置
# find / -name "zabbix.conf.php"

/usr/share/zabbix/conf/zabbix.conf.php
```

> 查看效果

```ba
grep -Env '//|^$' /usr/share/zabbix/conf/zabbix.conf.php
```

### 中文问题

#### 问题描述

> 点击图形后，进入到图形界面，会发生字体异常 -- 不是程序的问题，仅仅是字符集的问题

#### 原因分析

> 图形中展示的信息内容不是翻译的问题，而是字体格式输出的问题。
>
> 对于zabbix，信息在Windows的web页面信息输出不是采用win系统默认的字体格式，而是zabbix内部配置的字体类型。
>
> 所以我们就需要对zabbix的字体进行调整，将我们宿主机上（我的是Windows系统）的某些字体上传到Zabbix内部，并且让其生效

```powershell
查看前端配置文件
grep -ni _FONT /usr/share/zabbix/include/defines.inc.php
查看默认支持的字符集
ls -l /usr/share/zabbix/assets/fonts 
```

#### 解决方法

> 方法1：(推荐)

到windows电脑上查找字符集，字符集的目录：C:\Windows\Fonts

我们选择一个字体【任何字体都可以】,选择一个 simkai.ttf，将其上传到 zabbix的字体目录下，改名为 graphfont.ttf

```powershell
cd /usr/share/zabbix/ui/assets/fonts
mv graphfont.ttf graphfont.ttf-bak
mv ~/SIMKAI.TTF graphfont.ttf
```

> 方法2：

修改zabbix的web使用的字体名称为我们定制的名称，
或者直接使用英文字体，就不会发生中文格式的问题。

### 地理地图无法显示

#### 问题描述

> 默认情况下，我们看到右下角的地图无法正常显示

点击管理-常规-地理地图，修改成高德地图。

供应商：其他
URL: https://webrd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}
属性文字：高德矢量地图
最大缩放级别: 18

> 效果图如下

![image-20251015232016284](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015232016284.png)

### 修改初始化地点

> 点击右下角地理地图板块的“ 齿轮 ”
>
> 初始试图的经纬坐标修改为：39.908692,116.397477    （这里的坐标以天安门为例）

![image-20251015232123802](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251015232123802.png)



## 数据采集

### 前情提要

> 数据采集的时候，主要有两种方式：
> HTTP协议方式
> Zabbix agent + zabbix专用协议
>
> ———————******———————
>
> zabbix server的数据采集从组成方式上来说，主要靠两种采集方式：
> 1 本机采集：				 zabbix_agentd
> 2 跨主机组合采集： 	zabbix_agentd	+	zabbix_get

### 采集软件

> ———————**软件简介**———————
>
> **zabbix_agentd**：是**在被监控机器上运行**的**守护进程**（后台服务），负责**收集数据**。
>
> ​	**角色**： 客户端代理（Agent）
>
> ​	**工作方式**：
>
> 1. 它作为一个后台服务（守护进程）安装并运行在**需要被监控的服务器**上（如 Web 服务器、数据库服务器等）。
> 2. 它持续运行，监听来自 Zabbix Server 的请求
>
> - **被动模式**：默认模式。Zabbix Server 主动向 Agent 请求数据，Agent 返回数据。
>
> - **主动模式**：Agent 主动向 Zabbix Server 请求需要监控的项目列表，然后收集数据并主动发送给 Server。
>
>   主要功能：
>
> - **收集本地数据**：如 CPU 使用率、内存、磁盘空间、网络流量、进程数量等。
>
> - **执行自定义脚本**：根据 Zabbix Server 的指令，运行用户编写的脚本（例如，检查特定应用的业务状态）并返回结果。
>
> - **监听端口**：默认在 **10050** 端口上监听来自 Zabbix Server 的连接。
>
> **zabbix_get**：是**在 Zabbix Server 或一台测试机器上运行**的**命令行工具**，负责**主动获取数据**
>
> ​	**角色**： 诊断与测试工具
>
> ​	**工作方式**：
>
> 1. 它是一个轻量级的**命令行工具**。
> 2. 它通常运行在 **Zabbix Server** 本身，或者任何一台可以连接到被监控主机（运行着 zabbix_agentd）的机器上。
> 3. 它**模拟 Zabbix Server** 的行为，向指定的 zabbix_agentd 发起一次性的数据请求，并直接将结果打印在终端上。
>
> ​    **主要功能**：
>
> - **手动测试监控项**：在 Zabbix Web 界面上配置了一个新的监控项后，可以用 `zabbix_get` 命令手动测试这个监控项是否能正常获取到数据，而不用等待 Server 的下一个调度周期。
> - **故障排查**：当某个监控项在 Web 界面上显示“不支持”或没有数据时，使用 `zabbix_get` 可以直接判断问题是出在 Agent 端（无法获取数据）还是 Server 端（数据处理或网络问题）。
> - **脚本集成**：可以在自定义脚本中调用 `zabbix_get` 来获取数据。

### 软件安装查看

```ba
查看软件信息
apt info zabbix-get
apt info zabbix-agent

安装软件
apt install zabbix-get -y
dpkg -L zabbix-get
dpkg -L zabbix-agent

# 1. rocky安装
# 添加 Zabbix 官方仓库安装，对于 Zabbix 6.4 (LTS 长期支持版本)
dnf install -y https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-3.el9.noarch.rpm
# 2. 清理并更新仓库缓存
dnf clean all
dnf makecache
# 3. 安装 zabbix-get
dnf install -y zabbix-get

zabbix_agentd [-c config-file] -p| -t item-key
属性解析
-c 指定zabbix的客户端配置文件，不写表示使用默认的配置文件
-p 打印所有的有效监控条目
-t 测试指定监控条目的数据获取效果
——————***——————
zabbix_get -s host-name-or-IP [-p port-number] [-I IP-address] -k item-key
属性解析
-s：远程Zabbix-Agent配置文件中设置的IP地址或者是主机名。如果指定的ip不存在则发生报错
-p：远程Zabbix-Agent的端口。
-l：本机出去的IP地址，用于一台机器中又多个网卡的情况。
-k：获取远程Zabbix-Agent数据所使用的Key(监控条目关键字，可以通过zabbit_agentd命令获取)。
```

```ba
获取数据
	root@ubuntu24-13:~# zabbix_agentd -t system.cpu.num
获取当前所有有效监控条目
	zabbix_agentd -p
获取指定监控节点的有效条目
	zabbix_agentd -t agent.hostname
	zabbix_agentd -t system.swap.size
结果显示：
	每个item监控项都是以键值对的形式存在，键名是我们定制的，值是自动获取的。
	这些值都是在zabbix的最新数据中进行使用

收集zabbix 客户端主机的名称
	zabbix_get -s 127.0.0.1 -p 10050 -k "agent.hostname"
测试客户端主机状态是否正常
	zabbix_get -s 127.0.0.1 -p 10050 -k "agent.ping"
结果解析：
	agent.ping 如果返回值是1，表示主机间连通没有问题。
注意事项：
	如果ping不通，检查配置文件/etc/zabbix/zabbix_agentd.conf
	grep -Eni '^Server|^Hostname' /etc/zabbix/zabbix_agentd.conf
	systemctl restart zabbix-agent.service
测试实践：
	echo '10.0.0.10 master.zabbix.com' >> /etc/hosts
	zabbix_get -s 10.0.0.10 -p 10050 -k "agent.hostname"
	zabbix_get -s master.zabbix.com -p 10050 -k "agent.hostname"	# master.zabbix.com 这个是配置文件中的Hostname
	
	
```



# zabbix客户端部署

##### 功能定位：安装在被监控目标上的轻量级代理程序，其核心功能定位是：**数据采集器**。

> 如果把 Zabbix Server 比作大脑（监控中心），那么 Zabbix Agent 就是遍布在身体各处的神经末梢（感官），负责感知和上报身体各部位的状况。

#### Zabbix Agent 的工作模式主要主要有两种：主动与被动。

##### 模式一：被动模式

1. **监听等待**：Agent 启动后，在 **10050 端口** 上进入监听状态，等待 Server 的连接。
2. **接收请求**：Zabbix Server（或 Proxy）根据监控配置，主动向 Agent 发起请求。
3. **执行采集**：Agent 收到请求后，执行相应的检查指令（如读取一个键值 `system.cpu.load`）。
4. **返回数据**：Agent 将采集到的数据返回给发起请求的 Server。

- **特点**：Server “拉取” 数据。适合小规模环境或网络策略要求 Server 主动发起的情况。

##### 模式二：主动模式

1. **主动联系**：Agent 启动后，主动向配置文件中 `ServerActive` 参数指定的 Server 地址进行联系。
2. **请求任务**：Agent 向 Server 请求：“我是 `Hostname` 指定的主机，我有哪些监控项需要采集？”
3. **获取列表**：Server 返回一个监控项列表给 Agent。
4. **采集上报**：Agent 根据列表，独立地进行数据采集，然后 **主动** 将一批数据发送给 Server。

- **特点**：Agent “推送” 数据。**这是推荐的生产环境模式**，因为它极大地减轻了 Server 端的负载和连接数，扩展性更强。

> #### 配置关键参数
>
> - **`Server`**：定义**允许哪些** Zabbix Server IP 来**被动拉取**数据。
>
> - **`ServerActive`**：定义 Agent **主动向哪些** Zabbix Server IP **推送**数据。
>
> - **`Hostname`**：Agent 的**唯一身份标识**，必须与在 Zabbix Server 上创建的主机名称完全一致，尤其是在主动模式下至关重要。
>
>   在ubuntu与rocky系统中这个配置参数都在/etc/zabbix/zabbix_agentd.conf文件中。

## 部署zabbix-agent服务

> 安装Zabbix Agent 有三种方式：包安装（推荐）、二进制安装、编译安装。

> 官方网址：[下载并安装Zabbix](https://www.zabbix.com/download?)

#### 安装Zabbix存储库

> 禁用EPEL提供的Zabbix软件包（如果已安装）。 编辑文件 /etc/yum.repos.d/epel.repo 并添加以下语句。

```ba
[epel]
...
excludepkgs=zabbix*
```

> 继续安装zabbix存储库。

```ba
# rpm -Uvh https://repo.zabbix.com/zabbix/7.4/release/rocky/9/noarch/zabbix-release-latest-7.4.el9.noarch.rpm
# dnf clean all
```

#### 安装Zabbix服务器、前端、代理

```ba
# dnf install zabbix-agent
```

#### 启动 Zabbix 代理流程

> 启动 Zabbix 代理进程并使其在系统启动时启动。

```ba
# systemctl restart zabbix-agent
# systemctl enable zabbix-agent
```

> 定制配置

```powershell
vim /etc/zabbix/zabbix_agentd.conf

117:Server=10.0.0.11			# 指定zabbix服务端的地址，如果需要本地测试临时测试的话，需要添加本地的ip地址
125:ListenPort=10050			# 默认的端口号，可以不用取消注释
158ServerActive=127.0.0.1		# 注释该条目，这是另外一种指定zabbixserver主机的方式
169:Hostname=10.0.0.16 			# zabbixserver监控当前主机的时候，客户端主机唯一的标识
注意：
如果没有定义Hostname, 则服务器将使用agent的系统主机名命名主机。
如果需要本地测试监控，修改Server的配置Server=10.0.0.10,10.0.0.11

查看配置
grep -Env '#|^$' /etc/zabbix/zabbix_agentd.conf

zabbix-agent……启动！
systemctl restart zabbix-agent.service
systemctl enable zabbix-agent.service

查看端口
查看进程
ps -ef | grep zabbix_agent
查看日志
cat /var/log/zabbix/zabbix_agentd.log
```

#### 创建主机和主机组资源

> 创建主机组
>
> 数据采集--主机群组--创建主机组；
>
> 输入“主机组名” ，点击 ‘ 添加 ’

> 创建主机
>
> 数据采集--主机--创建主机；
>
> 主机名称：即/etc/zabbix/zabbix_agentd.conf配置中的Hostname ，也可以是该主机的IP地址。
>
> 可见名称：这里与主机名称相同
>
> 模板：		Templates/Operating systems——Linux by Zabbix agent
>
> 主机群组：自定义
>
> 接口类型：有四种接口，这里先用agent
>
> 接口地址：即主机地址
>
> 描述：		
>
> 数据中心：A1，机房：A1-1，机柜：A1-1-1，
> 应用服务：Web，应用软件：Nginx，
> 维护者：Shirley.Wang，日期：20251016
>
> 勾选 ‘ 启用 ’（enabled）

检查效果

稍等一会，Availability下面的ZBX就会变绿，表示配置成功了，如图中所示：

![image-20251016153636728](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251016153636728.png)

###  JMX方式监控(server端部署)

##### 核心工作原理

> 1. **在 Java 应用中开启 JMX 接口**：
>    在启动 Java 应用时，需要添加特定的 JVM 参数，开启一个远程 JMX 端口（例如 `12345`）。这样，应用内部的各项指标（称为 **MBeans**）就通过这个端口暴露出来了。
> 2. **Zabbix Java Gateway 作为翻译官**：
>    Zabbix Server（C++编写）无法直接理解 JMX 协议。因此，需要一个中间件——**Zabbix Java Gateway**（Java编写）。它负责与 Java 应用通信，将 Zabbix Server 的请求“翻译”成 JMX 请求，并将获取到的数据“翻译”回 Zabbix 能理解的格式。
> 3. **Zabbix Server 发起查询**：
>    Zabbix Server 根据配置的监控项，向 Zabbix Java Gateway 请求数据，Gateway 再去查询指定的 Java 应用，最后将数据返回给 Server。

#### 环境部署

```powershell
安装tomcat应用
# apt search tomcat
# apt install tomcat10 -y

检测效果
systemctl is-active tomcat10.service
netstat -tnulp | grep java
```

##### zabbix服务端部署

> 部署 java gateway

```powershell
下载安装java gatway
apt install zabbix-java-gateway -y
编辑配置文件
grep -E '^[a-Z]' /etc/zabbix/zabbix_java_gateway.conf
LISTEN_IP="0.0.0.0"
LISTEN_PORT=10052
PID_FILE="/var/run/zabbix/zabbix_java_gateway.pid"
START_POLLERS=50 			# 开启的进程可以多一点
TIMEOUT=30
重启服务
systemctl restart zabbix-java-gateway.service
systemctl enable zabbix-java-gateway.service
查看端口
netstat -tnulp | grep java
```

> 配置JMX

```powershell
grep 'Java' /etc/zabbix/zabbix_server.conf | grep -v '#'
JavaGateway=10.0.0.16		# 指定java gateway 主机的地址
JavaGatewayPort=10052
StartJavaPollers=20			# 设定的java线程数量要小于 java-gateway的
START_POLLERS
重启服务
systemctl restart zabbix-server.service
查看效果
ps aux | grep 'java poller' | grep -v "grep" | wc -l
```

##### tomcat开启 JMX监控

```powershell
查找tomcat的专属启动文件
find / -name "catalina.sh"
/usr/share/tomcat10/bin/catalina.sh		# 这是ubuntu版本，根据具体定义！
修改配置文件
vim /usr/share/tomcat10/bin/catalina.sh
...
112 # ---------------------------------------------------------------------------
--
# 在这个部分添加下面的相关配置，多个配置必须在一起，不要使用功能Enter来进行换行操作
CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -
Djava.rmi.server.hostname=10.0.0.16 -Dcom.sun.management.jmxremote.port=10086 -
Dcom.sun.management.jmxremote.ssl=false -
Dcom.sun.management.jmxremote.authenticate=false"
重启服务
systemctl restart tomcat10.service
查看端口
netstat -tnulp | grep java
...
tcp6 0 0 :::10086 :::* LISTEN 27798/java # JMX开启的端口

上传测试工具
mkdir /data/softs -p
cd /data/softs/
root@ubuntu24-16:softs# ls
cmdline-jmxclient-0.10.3.jar

执行测试命令
java -jar cmdline-jmxclient-0.10.3.jar - 10.0.0.12:10086 java.lang:type=Memory HeapMemoryUsage
——————下面的是信息输出——————
03/06/2025 20:44:25 +0800 org.archive.jmx.Client HeapMemoryUsage:
committed: 159383552
init: 130023424
max: 2069889024
used: 26354048
注意：
这里的命令是：java.lang:type=Memory HeapMemoryUsage，因为Memory有很多属性，需要指定。
```

##### zabbix 以JMX方式监控tomcat主机

> 添加主机，以JMX的方式监控主机。
>
> 监听的tomcat的JMX端口是 10086。
>
> 关联相关的jmx模板。Templates——Apache Tomcat by JMX  和  Generic Java JMX

### Nginx监控

#### Ubuntu部署nginx

```powershell
安装软件
apt update && apt -y install nginx
定制nginx状态页面
vim /etc/nginx/sites-enabled/default
server {
	.....
#添加下面三行，Zabbix默认监控/basic_status,此处为/status，需要和zabbix的模板定义的路径
要保持一致
	location /status {
		stub_status;
	}
}
检测后启动nginx
nginx -t
systemctl restart nginx
测试页面
apt install curl
curl localhost/status
```

#### Rocky部署nginx

```powershell
安装软件
yum -y install nginx
定制nginx状态页面
vim /etc/nginx/nginx.conf
server {
	.....
#添加下面三行，Zabbix默认监控/basic_status,此处为/status，需要和zabbix的模板定义的路径
要保持一致
	location /status {
		stub_status;
	}
}
检测后启动nginx
nginx -t
systemctl restart nginx
测试页面
apt install curl
curl localhost/status
```

#### 添加nginx监控

> 关于Nginx的监控，主要有两个模版，其中HTTP模版里面的监控数据是走http协议传输数据的，而zabbix默认情况下是不支持HTTP协议的监控接口的。
>
> 所以这种情况下，接口部分的内容是可以不用指定的【在zabbix 7.0 之前随意指定一个即可】。
>
> 在HTTP方式监控场景下，我们可以通过一个 宏的方式来确定Nginx监控。



# Prometheus

> 基础信息
>
> ​						Prometheus															Zabbix
>
> 语言：			Goloang（Go）													   PHP、C	、Go
>
> 部署：			二进制、解压即用。												yum、编译、数据库、php依赖
>
> 简易难度：	门槛较高																	容易使用
>
> 监控方式：	通过各种exporter , 监控一般都是基于http 		  各种模板，客户端，自定义监控，各种协议.
>
> 应用场景：	监控服务、容器、k8s											  监控系统底层，硬件，系统，网络。
