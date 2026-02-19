# Prometheus 9090

云原生：[CNCF Landscape](https://landscape.cncf.io/)

##### 监控系统

- 采集指标 Prometheus  
- 指标存储 Prometheus （内置数据库，且是时序数据库，是 Prometheus 所特有的）
- 展示 Grafana 展示 Prometheus 数据
- 告警

“主动”和“被动”是**站在被监控对象（Agent）的角度**来定义的。

被动模式

- **Prometheus 的工作模式是严格的被动模式**
- 这是 Prometheus 的默认和核心设计模式。
- Server 端压力大，因为它需要维护所有监控任务的调度和轮询。

主动模式

- Server 端压力小，更适合监控大量主机，它只需要接收数据，大大减少了轮询的开销。

> ubuntu系统内置的prometheus比较旧，尽量从官网下载；
>
> 官网下载地址：[Download | Prometheus](https://prometheus.io/download/)
>
> 下载尽量用长期稳定版本，比如我这次用的  prometheus-3.7.3.linux-amd64.tar.gz

##### 安装服务

```powershell
root@ubuntu-202:~# apt list prometheus
Listing... Done
prometheus/noble-updates,noble-security 2.45.3+ds-2ubuntu0.3 amd64
N: There is 1 additional version. Please use the '-a' switch to see it
# 可以看到版本很旧啊！很旧
# 所以这次放弃包安装，使用二进制安装，从官网下载文件、解压
wget https://github.com/prometheus/prometheus/releases/download/v3.7.3/prometheus-3.7.3.linux-amd64.tar.gz
tar xvf prometheus-3.5.0.linux-amd64.tar.gz -C /usr/local/
cd /usr/local && ls
ln -s prometheus-3.5.0.linux-amd64/ prometheus
# 可以看到有两个可执行文件，而且没有任何依赖！
root@ubuntu-202:/usr/local/prometheus# ls
LICENSE  NOTICE  prometheus  prometheus.yml  promtool		# prometheus服务的配置文件：prometheus.yml
root@ubuntu-202:/usr/local/prometheus# ldd promtool prometheus
promtool:
        not a dynamic executable
prometheus:
        not a dynamic executable
# 创建相关目录文件，并进行归纳整理 （可选）
cd /usr/local/prometheus && mkdir bin conf data 
mv prometheus promtool bin/   && mv prometheus.yml conf/
# 创建prometheus账户
useradd -r -s /sbin/nologin prometheus
# 使用 -L 选项跟随符号链接,否则对实际目录进行权限更改
chown -R prometheus: /usr/local/prometheus/
getent passwd prometheus
# 测试启动prometheus服务
bin/rometheus --config.file=/usr/local/prometheus/conf/prometheus.yml
# 查看端口是否打开
ss -tunlp | grep 9090
# 上面测试是以root用户启动，所以启动后生成的文件权限是root，所以测试完成还是要重新恢复一下。
# 否则prometheus启动服务写不进数据，导致启动失败！
chown -R prometheus: /usr/local/prometheus/
ll /usr/local/prometheus/
# 创建 service 文件
cat > /lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target
[Service]
Restart=on-failure
User=prometheus
Group=prometheus
WorkingDirectory=/usr/local/prometheus/
ExecStart=/usr/local/prometheus/bin/prometheus --config.file=/usr/local/prometheus/conf/prometheus.yml
# config.file=/usr/local/prometheus/conf/prometheus.yml --web.enable-lifecycle #添加后面的参数支持远程关机
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
# 检查配置文件语法
/usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml

systemctl daemon-reload
systemctl restart prometheus && systemctl status prometheus 
ss -tunlp | grep 9090

# 修改采集数据间隔(这里改为10s)
vi /usr/local/prometheus/conf/prometheus.yml
global:
  scrape_interval: 10s 
# 加载服务配置，使其生效
systemctl  reload prometheus.service 

# 在prometheus网页query界面输入up也可以查看所有设备的指标信息
# 查询 Prometheus 服务自身的监控指标全部信息
curl http://10.0.0.202:9090/metrics
# 访问 Prometheus 服务关于健康的指标
curl http://10.0.0.202:9090/-/healthy
# 展示各项监控指标访问数量（部分）
root@ubuntu-202:/usr/local/prometheus# curl http://10.0.0.202:9090/metrics | grep  prometheus_http_requests_total
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0# HELP prometheus_http_requests_total Counter of HTTP requests.
# TYPE prometheus_http_requests_total counter
prometheus_http_requests_total{code="200",handler="/"} 0
prometheus_http_requests_total{code="200",handler="/-/healthy"} 1
prometheus_http_requests_total{code="200",handler="/-/quit"} 0

# 容器化启动prometheus
官方下载网址：https://hub.docker.com/r/prom/prometheus
# 基于Docker compose 实现prometheus部署，在课件中看吧！
# ansible 部署 prometheus ，也在课件中看！
```

```powershell
cat /usr/local/prometheus/conf/prometheus.yml
# my global config
global:
  scrape_interval: 10s # 每10秒采集一次指标
  evaluation_interval: 15s # 每15秒评估一次告警规则


scrape_configs:
  - job_name: "prometheus"	# 采集任务名称

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    
scrape_configs:
  - job_name: "custom_metrics"
    metrics_path: '/custom-metrics'  # 自定义路径，默认是 /metrics
    scheme: 'http'				    # 自定义协议方案，默认是 http
    static_configs:
      - targets: ["localhost:8080"]
      # 采集目标地址
        labels:
          app: "prometheus"
          # 添加的标签
          
  - job_name: "node_exporter"
    static_configs:
      - targets: 
        - "10.0.0.200:9100"
        - "10.0.0.201:9100"
        - "10.0.0.202:9100"
        # 这是另一种格式书写；
        # prometheus服务器不能采集自身的数据，所以也需要安装node_exporter数据采集器
        labels:
          app: "node_exporter"
          # 标签无所谓，但既然写了就要有意义；
```

![image-20251123143638325](C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20251123143638325.png)

##### Node Exporter 9100

安装 Node Exporter 用于收集各 node 主机节点上的监控指标数据，监听端口为9100

下载地址：[Download | Prometheus](https://prometheus.io/download/)

```powershell
# 准备工作
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar xvf node_exporter-1.10.2.linux-amd64.tar.gz -C /usr/local/
cd /usr/local/ && ls
ln -s node_exporter-1.10.2.linux-amd64 node_exporter
cd /usr/local/node_exporter && ls
mkdir bin && ls
mv node_exporter bin/
useradd -r -s /sbin/nologin prometheus
chown -R prometheus:prometheus /usr/local/node_exporter/
ll /usr/local/node_exporter/

# 准备 service 文件
cat > /lib/systemd/system/node_exporter.service  << 'EOF'
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
# 启用：--collector.<name>
# 禁用：--no-collector.<name>
#no-collector.uname:禁止收集uname信息，会导致grafana无法显示此主机信息
#ExecStart=/usr/local/node_exporter/bin/node_exporter --no-collector.uname --collector.cgroups
User=prometheus
Group=prometheus
ExecStart=/usr/local/node_exporter/bin/node_exporter --collector.cgroups
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动 Node Exporter 服务
systemctl daemon-reload
systemctl restart node_exporter && systemctl status node_exporter
ss -tunlp | grep node_exporter

# 浏览器访问：10.0.0.201:9100
```

##### Grafana 3000

账户密码默认都是admin

- Grafana 本身提供了一个内置的 `/metrics` 端点
- 这个端点直接暴露 Grafana 自身的运行指标
- 访问地址：`http://10.0.0.201:3000/metrics`

官方下载地址：https://grafana.com/grafana/download

```powershell
wget https://mirrors.tuna.tsinghua.edu.cn/grafana/apt/pool/main/g/grafana-enterprise/grafana-enterprise_12.2.2_19496034263_linux_amd64.deb
# 方法1：手动安装依赖包
apt-get install -y adduser libfontconfig1 musl
dpkg -i grafana-enterprise_12.2.2_19496034263_linux_amd64.deb
# 方法2：手动安装依赖包 (推荐)
apt -y install ./grafana-enterprise_12.2.2_19496034263_linux_amd64.deb	# 注意：安装的是本地文件，所以要加文件路径
systemctl start grafana-server && systemctl status grafana-server
ss -tunp | grep 3000
出现一个小插曲：服务active，但是没有3000端口号
# 查看到配置中默认端口号被注释了！
grep -r "3000" /etc/grafana/
/etc/grafana/grafana.ini:;http_port = 3000
# 修改
sed -i 's/^;http_port = 3000/http_port = 3000/' /etc/grafana/grafana.ini

# 浏览器登陆：10.0.0.201:3000
# connections——data sources—— prometheus server URL：http://10.0.0.202:9090 —— save
# 配置 Prometheus 数据源
vi /usr/local/prometheus/conf/prometheus.yml
  - job_name: "node_exporter"
    static_configs:
      - targets: 
        - "10.0.0.201:9100"
        - "10.0.0.202:9100"
        labels:
          app: "node_exporter"

  - job_name: "grafana"
    static_configs:
      - targets:
        - "10.0.0.201:3000"
        labels:
          app: "grafana"
# 导入指定模板展示 Node Exporter 数据
# 登录 Grafana 官网查找 Node Exporter 模板，复制模版的ID；（具体的可以看课件，课件详细很多）
https://grafana.com/grafana/dashboards/1860-node-exporter-full/
# grafana网页——dashboards——选择查看项目—— new —— import —— 输入模版ID:1860 ——选择prometheus数据源—— 导入import
# 8919是另一个模版ID ，对中文患者很友好！其他的模版在官网找，也可以在课件中找！
```



##### pushgateway  9091

官方地址：[Download | Prometheus](https://prometheus.io/download/)

数据中转站，作为客户端与 prometheus 服务器之间的代理。

**二进制安装**

```powershell
wget https://github.com/prometheus/pushgateway/releases/download/v1.11.2/pushgateway-1.11.2.linux-amd64.tar.gz
tar xf pushgateway-1.11.2.linux-amd64.tar.gz -C /usr/local/
ln -s /usr/local/pushgateway-1.11.2.linux-amd64/ /usr/local/pushgateway && ls /usr/local/pushgateway
mv /usr/local/pushgateway/pushgateway /usr/local/pushgateway/bin/
id prometheus &> /dev/null || useradd -r -s /sbin/nologin prometheus
ldd /usr/local/pushgateway/bin/pushgateway		# 检查二进制文件的动态库依赖关系,列出动态依赖
ln -s /usr/local/pushgateway/bin/pushgateway /usr/local/bin/
/usr/local/pushgateway/bin/pushgateway 			# 前台启动 pushgateway ，仅做测试用！下面是配置 service 启动文件
cat > /lib/systemd/system/pushgateway.service <<EOF
[Unit]
Description=Prometheus Pushgateway
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/pushgateway/bin/pushgateway
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
User=prometheus
Group=prometheus
[Install]
WantedBy=multi-user.target
EOF
# 启动服务
systemctl daemon-reload
systemctl start pushgateway.service ; systemctl status pushgateway.service && ss -tunlp | grep 9091
# 浏览器访问
http://10.0.0.202:9091/
http://10.0.0.202:9091/metrics
```

配置 Prometheus 收集 Pushgateway 数据

```powershell
vi /usr/local/prometheus/conf/prometheus.yml
  - job_name: "pushgateway"
    static_configs:
      - targets:
        - "10.0.0.202:9091"
        labels:
          app: "pushgateway"
systemctl  reload prometheus.service 
# 在 http://10.0.0.202:9090/query prometheus网页输入 up ，查看 pushgateway 服务是否与 prometheus 对接成功；
```

配置客户端发送数据给 Pushgateway

- 测试：
- 在另一台设备中将指标 推送到 Pushgateway，并标记为 some_job 作业；
- 在浏览器网页 http://10.0.0.202:9091/metrics 就可以找到 指标 some_metric 的值 3.14 
- 再次测试：echo "some_metric 3.1415926" | curl --data-binary @- http://10.0.0.202:9091/metrics/job/some_job
  - 在浏览器网页 http://10.0.0.202:9091/metrics 就可以找到 指标 some_metric 的值变动为 3.1415926
  - 当然了！在 [http://10.0.0.202:9091](http://10.0.0.202:9091/metrics) 首页中就能看到推送到的指标数据；
  - 在 prometheus 网页页面搜索 some_metric 这个指标名，就能看到对应的指标数据；

```powershell
# 将指标 some_metric 的值 3.14 推送到 Pushgateway，并标记为 some_job 作业
echo "some_metric 3.14" | curl --data-binary @- http://10.0.0.202:9091/metrics/job/some_job
# 在 Prometheus 中，这个指标实际上会成为：
some_metric{job="some_job"} 3.14
# 这是 Prometheus 推模式（push model）的典型使用方式:
# 推送多个指标
cat <<EOF | curl --data-binary @- http://10.0.0.202:9091/metrics/job/batch_job
some_metric 3.14
another_metric 42
process_duration_seconds 15.7
EOF
```



##### PromQL

- 数据基础：时间序列数据
  - Prometheus基于指标名称（metrics name）以及附属的标签集（labelset）唯一定义一条时间序列
- 数据模型：
  - <metric name>{<label name>=<label value>, …}
  - {__name__="metric name", <label name>=<label value>, …}
  - 示例：
    - cpu_usage{instance="10.0.0.1:9100", job="node_exporter"}
    - {__name__="cpu_usage", instance="10.0.0.1:9100", job="node_exporter"}
- 表达式形式：每一个PromQL其实都是一个表达式，这些语句表达式或子表达式的计算结果可以为以下四种类型
  - 即时向量（瞬时数据）；范围向量（即在一个时间段内，抓取的所有监控项数据）；标量（一个简单的浮点类型数值）；字符串
- 数据选择器：metrics_name{筛选label=值,...}[<时间范围>] offset <偏移>
- PromQL 运算：二元运算符；聚合运算



##### 定制 Exporter

> 指标来源：
>
> - Node exproter ;
> - Pushgateway
> - 自行开发 exporter （自定义的业务指标）

定制 Exporter 案例: Python 实现  （主机：10.0.0.200）

```powershell
准备 Python 开发 Web 环境
# Ubuntu24.04安装 （生产环境需要安装相关模块库）
apt install -y python3-flask python3-prometheus-client
# 启动 python 程序，
python3 prometheus_metrics_demo.py
# 另开一个终端窗口，查看端口
ss -tunlp | grep 8000
# 浏览器输入 http://10.0.0.200:8000/metrics 查看指标 request_count_total
# 在另一个设备访问 http://10.0.0.200:8000 访问成功，输出 “{"return":"success OK!"}” 
# 浏览器输入 http://10.0.0.200:8000/metrics 重新查看指标数值 request_count_total 是否发生变化
# 将这个自定义的 exporter 在promenade服务器编入promenade.yml配置中
vi /usr/local/prometheus/conf/prometheus.yml
  - job_name: "my_metric"
    static_configs:
      - targets:
        - "10.0.0.200:8000"
        labels:
          app: "my_metric"
systemctl  reload prometheus.service 
# 编写一个指令做测试，在web端观察指标数值的变化
 while true; do   curl http://10.0.0.200:8000;   sleep $((RANDOM % 10)); done
# prometheus web端添加指令查看数值变化
rate(request_count_total{instance="10.0.0.200:8000", job="my_metric"}[1m])
```

```powershell
root@ubuntu-200:~# cat prometheus_metrics_demo.py 
#!/usr/bin/python3
#Author: shirley

from prometheus_client import Counter, Summary, generate_latest
from flask import Flask, Response
import time

app = Flask(__name__)

# 创建监控指标
REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')
REQUEST_COUNT = Counter('request_count', 'Total request count')

@app.route('/')
@REQUEST_TIME.time()
def hello():
    REQUEST_COUNT.inc()
    return {"return": "success OK!"}

@app.route('/metrics')
def metrics():
    # 返回 Prometheus 格式的指标数据
    return Response(generate_latest(), mimetype='text/plain')

if __name__ == '__main__':
    # 只启动一个 Flask 服务器，同时提供应用接口和 metrics 接口
    app.run(host='0.0.0.0', port=8000)
```

##### Prometheus 标签管理

> 标签添加、删除、修改都是编辑promenade.yml配置文件
>
> Prometheus对数据的处理流程：
>
> 服务发现——》配置——》重新标记 relabel_configs ——》抓取 ——》重新标记 metric_relabel_configs

```powershell
范例一
# 示例:删除指标名node_network_receive开头的标签
metric_relabel_configs:
- source_labels: [__name__]
	regex: 'node_network_receive.*'
	action: drop
```

**`source_labels: [__name__]`**：

- 这里指定了 `__name__`，表示你要基于指标名称来进行匹配和操作。

**`regex: 'node_network_receive.\*'`**：

- `regex` 是正则表达式，用于匹配源标签的值。在这个例子中，`'node_network_receive.*'` 表示 **所有以 `node_network_receive` 开头的指标名称**。

**`action: drop`**：

- `action` 指定了当匹配到该规则时要执行的操作。这里的 `drop` 表示 **删除这些匹配的指标数据**，即不再收集或存储任何以 `node_network_receive` 开头的指标

```powershell
范例二
# 示例:匹配所有 id 标签值以 / 开头的指标，然后将这些指标的 id 标签替换为 replace_id 标签，并重新赋值为 '123456'
metric_relabel_configs:
- source_labels: [id]
	regex: '/.*'
	replacement: '123456'
	target_label: replace_id
# 举例来说，如果原来的指标有标签 id="/example"，经过这个 relabeling 配置后，它会被转化为 replace_id="123456" 的标签。
```

- source_labels: [id]：表示操作会基于 id 标签来进行。
- regex: '/.*'：表示匹配所有以 / 开头的 id 标签值。
- replacement: '123456'：如果 id 标签的值匹配正则表达式 '/.*'，那么会将其替换成 '123456'。
- target_label: replace_id：表示 replace_id 将成为新的标签名，并且它的值会被赋为 '123456'。



##### 记录规则-rule配置

```powershell
# 在Prometheus查询部分指标时需要通过将现有的规则组合成一个复杂的表达式，才能查询到对应的指标结果.
# 比如在查询"自定义的指标请求处理时间"
request_processing_seconds_sum{instance="10.0.0.200:8000",job="my_metric"} / request_processing_seconds_count{instance="10.0.0.200:8000",job="my_metric"}
```

记录规则实现

```powershell
# 创建规则记录文件
mkdir /usr/local/prometheus/rules
vim /usr/local/prometheus/rules/prometheus_record_rules.yml
groups:
  - name: myrules
    rules:
      - record: "request_process_per_time"
        expr: request_processing_seconds_sum{job="my_metric"} / request_processing_seconds_count{job="my_metric"}
        labels:
          app: "flask"
          role: "web"
      
      - record: "request_count_per_minute"
        expr: increase(request_count_total{job="my_metric"}[1m])
        labels:
          app: "flask"
          role: "web"
# 检查规则文件有效性
 /usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml 
# 只检查规则文件
 /usr/local/prometheus/bin/promtool check rules /usr/local/prometheus/rules/prometheus_record_rules.yml
# 编辑prometheus配置文件
vim /usr/local/prometheus/conf/prometheus.yml
rule_files:
  - "/usr/local/prometheus/rules/*.yml"
  # 添加规则记录文件路径；也可以使用相对路径，是相对于prometheus.yml的路径，比如："../rules/*.yml"

systemctl  reload prometheus.service
# 访问测试
while true ;do curl 127.0.0.1:8001/metrics;sleep 0.$[RANDOM%10];done
# 登录到prometheus的web界面，可以通过 request_prcess_per_time 指标查询我们想要的数据
```

##### Alertmanager 部署   9093

- Prometheus 定义告警规则，并触发告警。
- Alertmanager 接收 Prometheus 发出的告警信息，然后根据配置的路由规则将通知发送到不同的通知渠道（如电子邮件、钉钉、短信等）。

```powershell
# 二进制部署
wget https://github.com/prometheus/alertmanager/releases/download/v0.29.0/alertmanager-0.29.0.linux-amd64.tar.gz
tar xf alertmanager-0.29.0.linux-amd64.tar.gz  -C /usr/local/ && cd /usr/local/
ln -s alertmanager-0.29.0.linux-amd64/ alertmanager  && cd alertmanager
mkdir bin conf && mv alertmanager amtool  bin && mv alertmanager.yml conf && tree
# 查看启动选项
root@ubuntu-202:/usr/local/alertmanager/bin# ./alertmanager  --help
# 配置service 启动文件
cat > /lib/systemd/system/alertmanager.service << eof
[Unit]
Description=Alertmanager Project
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/alertmanager/bin/alertmanager \
  --config.file=/usr/local/alertmanager/conf/alertmanager.yml \
  --storage.path=/usr/local/alertmanager/data \
  --web.listen-address=0.0.0.0:9093
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
eof

chown -R prometheus:prometheus /usr/local/alertmanager/
systemctl daemon-reload
systemctl enable alertmanager && systemctl start alertmanager && systemctl status alertmanager
ss -ntlp|grep 9093
# 浏览器访问 http://10.0.0.202:9093
# altermagnager 作为一个软件服务，也是需要被 prometheus 监控的；
# 是否支持被 prometheus 监控，要检查是否有暴露的指标数据，可以访问 http://10.0.0.202:9093/metrics 以查看是否能展示相关的监控指标。
# 进入 prometheus 服务器 ，编辑 prometheus.yml
vi /usr/local/prometheus/conf/prometheus.yml
scrape_configs:
  - job_name: "alertmanager"
    static_configs:
      - targets:
        - "10.0.0.202:9093"
        labels:
          app: "alertmanager"
# 开启 Prometheus 监控系统与 Alertmanager 的连接，指示 Prometheus 将告警发送到位于 10.0.0.202:9093 的 Alertmanager 实例。
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - 10.0.0.202:9093

systemctl  reload prometheus.service     
```

### 告警

- 什么条件告警？即：告警规则  （布尔值）（在 prometheus 定义的）
- 如何告警？ 在 alertmanager 中定义；



编辑 alertmanager 配置文件；配置文件总共定义了五个模块，global、templates、route，receivers，inhibit_rules

global：定义Alertmanager的全局配置

- resolve_timeout #定义持续多长时间未接收到告警标记后，就将告警状态标记为resolved
- smtp_smarthost #指定SMTP服务器地址和端口
- smtp_from #定义了邮件发件的的地址
- smtp_require_tls #配置禁用TLS的传输方式

templates：指定告警通知的信息模板。通常需要能够自定义警报所包含的信息，这个就可以通过模板来实现。

route：定义Alertmanager接收警报的处理方式，根据规则进行匹配并采取相应的操作。

- group_by       用于定义分组规则，使用告警名称做为规则，满足规则的告警将会被合并到一个通知中
- group_wait    等待一段时间后再一起发送；

receivers：定义相关接收者的地址信息

- email_configs #配置相关的邮件地址信息
- wechat_configs #指定微信配置
- webhook_configs #指定webhook配置,比如:dingtalk

###### Alertmanager 配置文件

```powershell
vi /usr/local/alertmanager/conf/alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:25'  # 基于全局块指定发件人信息,此处设为25，如果使用465则还需要添加tls相关配置
  smtp_from: '17777055510@163.com'
  smtp_auth_username: '17777055510@163.com'
  smtp_auth_password: 'XZrCA35ZAHwgXEZ5'
  smtp_hello: '163.com'
  smtp_require_tls: false  # 启用tls安全, 默认true, 此处设为false

# 路由配置
route:
  group_by: ['alertname', 'cluster']
  group_wait: 1m
  group_interval: 1m
  repeat_interval: 1m  # 此值不要过低，否则短期内会收到大量告警通知
  receiver: 'email'  # 指定接收者名称

# 收信人员
receivers:
  - name: 'email'
    email_configs:
      - to: 
          - '17700995441@163.com' 
          - 'lbtooth@163.com'
        send_resolved: true  # 问题解决后也会发送恢复通知


# alertmanager 配置文件语法检查命令
/usr/local/alertmanager/bin/amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
# 重启服务
systemctl restart alertmanager.service
# 浏览器输入 http://10.0.0.202:9093 在 status 板块下可以看到上面做的配置
```

###### Prometheus 告警规则

> 参考网站：https://samber.github.io/awesome-prometheus-alerts/

```powershell
# 确认包含rules目录中的yml文件
cat /usr/local/prometheus/conf/prometheus.yml
rule_files:
  - "/usr/local/prometheus/rules/*.yml"
# 准备告警rule文件
vim /usr/local/prometheus/rules/prometheus_alert_rules.yml
groups:
  - name: flask_web
    rules:
      - alert: InstanceDown
        expr: up{job="my_metric"} == 0
        for: 10s
        labels:
          severity: '1'
        annotations:
          summary: "Instance {{ $labels.instance }} 停止工作"
          description: "{{ $labels.instance }} job {{ $labels.job }} 已经停止10s以上"
# 检查语法
/usr/local/prometheus/bin/promtool check rules  /usr/local/prometheus/rules/prometheus_alert_rules.yml
# 在 prometheus 中开启 alertmanager 发送告警功能
vi /usr/local/prometheus/conf/prometheus.yml 
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - 10.0.0.202:9093
# 重新加载 prometheus 服务
systemctl reload prometheus.service 
# 重新启动测试服务 (本人是在10.0.0.200主机中定义的测试服务！)
python3 prometheus_metrics_demo.py
# 浏览器输入 http://10.0.0.202:9090 在 status 的 rule health 模块中查看配置的告警规则；
# 查看告警状态，http://10.0.0.202:9090 prometheus web 页面的 Alerts
# 查看 http://10.0.0.202:9093 Alertmanager首页的告警是否消掉
```

###### 静默告警

>  进入alertmanager网页：http://10.0.0.202:9093 
>
>  首页 Alert —— 点击 Silence —— **Matchers**设置匹配规则 —— **Creator**执行人 —— **Comment** 说明 —— create
>
>  在 Silence 板块中可以看到 设置静默的具体信息 ，点击 Expire 进行取消静默操作

###### 告警模版

```powershell
# 在alertmanqer节点上建立邮件模板文件
mkdir /usr/local/alertmanager/tmpl
# 模版一
vim /usr/local/alertmanager/tmpl/email.tmpl
{{ define "test.html" }}
<table border="1">
  <tr>
    <th>报警项</th>
    <th>实例</th>
    <th>报警阀值</th>
    <th>开始时间</th>
  </tr>
  {{ range $i, $alert := .Alerts }}
  <tr>
    <td>{{ index $alert.Labels "alertname" }}</td>
    <td>{{ index $alert.Labels "instance" }}</td>
    <td>{{ index $alert.Annotations "value" }}</td>
    <td>{{ $alert.StartsAt }}</td>
  </tr>
  {{ end }}
</table>
{{ end }}
# 模版二
vim /usr/local/alertmanager/tmpl/email_template.tmpl
{{ define "email.html" }}
  {{- if gt (len .Alerts.Firing) 0 }}
    {{ range .Alerts.Firing }}
    =========start==========<br>
    告警程序: prometheus_alert <br>
    告警级别: {{ .Labels.severity }} <br>
    告警类型: {{ .Labels.alertname }} <br>
    告警主机: {{ .Labels.instance }} <br>
    告警主题: {{ .Annotations.summary }} <br>
    告警详情: {{ .Annotations.description }} <br>
    触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }} <br>
    =========end==========<br>
    {{ end }}
  {{- end }}

  {{- if gt (len .Alerts.Resolved) 0 }}
    {{ range .Alerts.Resolved }}
    =========start==========<br>
    告警程序: prometheus_alert <br>
    告警级别: {{ .Labels.severity }} <br>
    告警类型: {{ .Labels.alertname }} <br>
    告警主机: {{ .Labels.instance }} <br>
    告警主题: {{ .Annotations.summary }} <br>
    告警详情: {{ .Annotations.description }} <br>
    触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }} <br>
    恢复时间: {{ .EndsAt.Format "2006-01-02 15:04:05" }} <br>
    =========end==========<br>
    {{ end }}
  {{- end }}
{{- end }}


# 应用模板,更改配置文件
vim /usr/local/alertmanager/conf/alertmanager.yml
templates:
  # 加载模板文件，使用相对路径，路径是相对于 alertmanager.yml 文件的位置
  - '/usr/local/alertmanager/tmpl/*.tmpl'  # 绝对路径（更推荐），或者相对路径
# 收信人员
receivers:
  - name: 'email'
    email_configs:
      - to: '17700995441@163.com,lbtooth@163.com,29308620@qq.com'
        send_resolved: true  # 问题解决后也会发送恢复通知
        headers: { Subject: "[WARN] 报警邮件" }  # 添加此行, 定制邮件标题
        html: '{{ template "test.html" . }}'     # 添加此行, 调用模板显示邮件正文
        #html: '{{ template "email.html" . }}'   # 添加此行, 调用模板显示邮件正文

# 检查语法
/usr/local/alertmanager/bin/amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
# 重启服务
systemctl restart alertmanager.service
# 或者重新加载配置
curl -XPOST localhost:9093/-/reload
# 测试 （与上面相同设置在主机10.0.0.200）
python3 prometheus_metrics_demo.py
# 进入 alertmanager 和 prometheus 网页界面查看告警状态，以及邮箱收件信息
```

###### 告警路由

定制告警规则

```powershell
# 将之前的告警文件删除或移动，重新编辑一个告警文件
# 指定flask_web规则的labels为 severity: critical
# 指定flask_QPS规则的labels为 severity: warning
vi /usr/local/prometheus/rules/prometheus_alert_rules.yml
groups:
  - name: flask_web
    rules:
      - alert: InstanceDown
        expr: up{job="my_metric"} == 0
        for: 10s
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} 停止工作"
          description: "{{ $labels.instance }} job {{ $labels.job }} 已经停止1分钟以上"
          value: "{{$value}}"

  - name: flask_QPS
    rules:
      - alert: InstanceQPSIsHigh
        expr: increase(request_count_total{job="my_metric"}[10s]) > 500
        for: 10s
        labels:
          severity: warning
        annotations:
          summary: "Instance {{ $labels.instance }} QPS 持续过高"
          description: "{{ $labels.instance }} job {{ $labels.job }} QPS 持续过高"
          value: "{{$value}}"
# 检查语法
/usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml 
# 重启服务
systemctl restart prometheus
# 测试 （与上面相同设置在主机10.0.0.200）
python3 prometheus_metrics_demo.py
# 编写一个指令做测试 (循环指令，增加访问次数，测试阈值告警)
 while true; do   curl http://10.0.0.200:8000;   sleep $((RANDOM % 10)); done
# 查看访问总数：request_count_total
# 请求速率（例如计算每分钟的请求数）：rate(request_count_total{job="my_metric"}[1m])
## rate() 函数的返回单位永远是：每秒钟的速率；后面的1m是采样的时间范围；
# 每个时间点显示该分钟的请求数：rate(request_count_total{job="my_metric"}[1m]) * 60
```

定制路由分组

```powershell
# 指定路由分组
vi /usr/local/alertmanager/conf/alertmanager.yml
route:
  group_by: ['instance', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'email'
  routes:
    - receiver: 'leader-team'
      matchers:
        - severity = "critical"
    - receiver: 'ops-team'
      matchers:
        - severity =~ "^(warning)$"

# 收信人员配置
receivers:
  - name: 'email'
    email_configs:
      - to: '17700995441@163.com'
        send_resolved: true
        html: '{{ template "test.html" . }}'
        headers:
          Subject: "[WARN] 报警邮件"
  
  - name: 'leader-team'
    email_configs:
      - to: '17700995441@163.com,29308620@qq.com'
        send_resolved: true
        html: '{{ template "test.html" . }}'
        headers:
          Subject: "[CRITICAL] 应用服务报警邮件"

  - name: 'ops-team'
    email_configs:
      - to: '17700995441@163.com,lbtooth@163.com'
        send_resolved: true
        html: '{{ template "test.html" . }}'
        headers:
          Subject: "[WARNING] QPS负载报警邮件"

#检查语法
/usr/local/alertmanager/bin/amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
# 服务生效
systemctl restart alertmanager.service
# 进入 alertmanager 和 prometheus 网页界面查看告警状态，以及邮箱收件信息
```

###### 抑制告警

定制告警规则

- 当python服务异常终止的时候，不要触发同节点上的 QPS 过低告警动作。

```powershell
vim /usr/local/prometheus/rules/prometheus_alert_inhibit.yml
groups:
  - name: flask_web
    rules:
      - alert: InstanceDown
        expr: up{job="my_metric"} == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} 停止工作"
          description: "{{ $labels.instance }} job {{ $labels.job }} 已经停止 30s 以上"
          value: "{{$value}}"
          
      - alert: InstanceQPSIsHigh
        expr: increase(request_count_total{job="my_metric"}[30s]) > 30
        for: 30s
        labels:
          severity: warning
        annotations:
          summary: "Instance {{ $labels.instance }} QPS 持续过高"
          description: "{{ $labels.instance }} job {{ $labels.job }} QPS 持续过高"
          value: "{{$value}}"

      - alert: InstanceQPSIsLow
        expr: up{job="my_metric"} == 0
        for: 30s
        labels:
          severity: warning
        annotations:
          summary: "Instance {{ $labels.instance }} QPS 异常为零"
          description: "{{ $labels.instance }} job {{ $labels.job }} QPS 异常为 0"
          value: "{{$value}}"
# 告警规则中将QPS阈值设置为零是为了做服务down告警的试验参照，如果同时触发，那么就会根据抑制告警进行抑制！
# 检查rules语法
/usr/local/prometheus/bin/promtool check rules /usr/local/prometheus/rules/prometheus_alert_inhibit.yml
# 重新加载服务
systemctl  reload prometheus.service
```

启动抑制机制

```powershell
vim /usr/local/alertmanager/conf/alertmanager.yml
......
# 收信人员
receivers:
  - name: 'email'
    email_configs:
      - to: '1711375523@qq.com'
        send_resolved: true  # 问题解决后也会发送恢复通知
        headers: { Subject: "[WARN] 报警邮件" }  # 添加此行, 定制邮件标题
          #html: '{{ template "test.html" . }}'     # 添加此行, 调用模板显示邮件正文
        html: '{{ template "email.html" . }}'   # 添加此行, 调用模板显示邮件正文

  - name: 'leader-team'
    email_configs:
      - to: '17700995441@163.com,29308620@qq.com'
        send_resolved: true
        html: '{{ template "email.html" . }}'
        headers:
          Subject: "[CRITICAL] 应用服务报警邮件"

  - name: 'ops-team'
    email_configs:
      - to: '17777055510@189.cn,lbtooth@163.com'
        send_resolved: true
        html: '{{ template "email.html" . }}'
        headers:
          Subject: "[WARNING] QPS负载报警邮件"  
# 抑制措施
inhibit_rules:
  - source_match:
      severity: critical  # 被依赖的告警服务
    target_match:
      severity: warning   # 依赖的告警服务
    equal:
      - instance

# 添加抑制配置，另为了加强试验对比，设置不同告警对应不同的邮箱；
# 检查语法
/usr/local/alertmanager/bin/amtool check-config /usr/local/alertmanager/conf/alertmanager.yml
# 重启 alertmanager 服务
systemctl restart alertmanager
# 测试（为了测试方便，将阈值调低，时间调短）
python3 prometheus_metrics_demo.py
 while true; do   curl http://10.0.0.200:8000;   sleep $((RANDOM % 3)); done
# 通过调试访问频率和开关测试服务，观测各个邮箱的通知以及通知的模版！
# 经过测试QQ邮箱接受邮件有问题，不能作为本次试验的测试工具！
# 试验成功，QPS值=0，抑制告警生效，仅仅触发down服务告警，仅对应的邮箱收到通知！
```

###### 微信告警

略

###### 钉钉告警  8060

- 企业注册——建群——智能群助手——添加机器人——自定义
- Webhook：
  https://oapi.dingtalk.com/robot/send?access_token=c293e8a905fd6fe98843a235073de1fa346cea3da1bdae8f658c6b1bc3f28abe
- 关键字：PromAlert   :star:如果机器人设置关键字，那么也必须设置对应的模板文件；
- 加签（密钥）：SECfd374d045cb4db25ac87ca60b2977c7d1426b8c23d0072b96494c98c026b69ae

```powershell
# 采用关键字进行测试
WEBHOOK_URL="https://oapi.dingtalk.com/robot/send?access_token=c293e8a905fd6fe98843a235073de1fa346cea3da1bdae8f658c6b1bc3f28abe"
curl -H "Content-Type: application/json" -d '{"msgtype":"text","text":{"content":"PromAlert - prometheus 告警测试"}}' ${WEBHOOK_URL}
# 返回信息
{"errcode":0,"errmsg":"ok"}
# 注意：只有包含定制的告警关键字的信息才会被发送成功。否则会提示下面错误,这里面测试的时候，没有开启加签
{"errcode":310000, errmsg":"description:"关键词不还配;solution:请联系群管理员查看此机器人的关键词，并在发送的信息中包含此关键词;"}
```

prometheus-webhook-dingtalk 软件部署 （在主机10.0.0.201，我随机选的！）

> 下载地址：[timonwong/prometheus-webhook-dingtalk: DingTalk integration for Prometheus Alertmanager](https://github.com/timonwong/prometheus-webhook-dingtalk/)

```powershell
wget https://github.com/timonwong/prometheus-webhook-dingtalk/releases/download/v2.1.0/prometheus-webhook-dingtalk-2.1.0.linux-amd64.tar.gz
#解压文件
tar xf prometheus-webhook-dingtalk-2.1.0.linux-amd64.tar.gz -C /usr/local/
ln -s /usr/local/prometheus-webhook-dingtalk-2.1.0.linux-amd64 /usr/local/dingtalk
#准备文件和目录
cd /usr/local/dingtalk  && mkdir bin conf  && ls
mv prometheus-webhook-dingtalk bin/
cp config.example.yml conf/config.yml
# 准备servcie文件
cat > /lib/systemd/system/dingtalk.service << eof
[Unit]
Description=alertmanager project
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/dingtalk/bin/prometheus-webhook-dingtalk --config.file=/usr/local/dingtalk/conf/config.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
User=prometheus
Group=prometheus

[Install]
WantedBy=multi-user.target
ss -tnulp | egrep 'Pro|8060'
eof

systemctl daemon-reload 
systemctl  start dingtalk.service && systemctl  status dingtalk.service && ss -tunlp | grep 8060

# 编辑 config.yml 相关信息
vim /usr/local/dingtalk/conf/config.yml
argets:
  webhook1:
    url: https://oapi.dingtalk.com/robot/send?access_token=c293e8a905fd6fe98843a235073de1fa346cea3da1bdae8f658c6b1bc3f28abe
    # secret for signature
    secret: SECfd374d045cb4db25ac87ca60b2977c7d1426b8c23d0072b96494c98c026b69ae
# 重启服务
systemctl restart dingtalk.service
```

Alertmanager 配置

```powershell
# 在告警配置中修改路由和收件人
vim /usr/local/alertmanager/conf/alertmanager.yml
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s		# 初始等待10秒，将相同告警分组
  group_interval: 20s	# 发送新告警分组的时间间隔15秒
  repeat_interval: 3m  # 重复发送相同告警的间隔3分钟
  receiver: 'dingtalk'  # 指定接收者名称
receivers:
  - name: 'email'
    email_configs:
      - to: '17700995441@189.cn'
        send_resolved: true  # 问题解决后也会发送恢复通知
        headers: { Subject: "[WARN] 报警邮件" }  # 添加此行, 定制邮件标题
          #html: '{{ template "test.html" . }}'     # 添加此行, 调用模板显示邮件正文
        html: '{{ template "email.html" . }}'   # 添加此行, 调用模板显示邮件正文

  - name: 'leader-team'
    email_configs:
      - to: '17700995441@163.com,29308620@qq.com'
        send_resolved: true
        html: '{{ template "email.html" . }}'
        headers:
          Subject: "[CRITICAL] 应用服务报警邮件"

  - name: 'ops-team'
    email_configs:
      - to: '17777055510@189.cn,lbtooth@163.com'
        send_resolved: true
        html: '{{ template "email.html" . }}'
        headers:
          Subject: "[WARNING] QPS负载报警邮件"          

  - name: 'dingtalk'
    webhook_configs:
      - url: 'http://10.0.0.201:8060/dingtalk/webhook1/send'
        send_resolved: true
# 重启服务
systemctl  restart alertmanager.service
# 路由和收件人都已经修改为 dingtalk ，down 掉服务，查看钉钉机器人是否发送告警消息；
```

###### 定制钉钉告警模板文件

- 确保钉钉中安全设置中有自定义的关键字和加签；PromAlert
- 准备两个图片的外链接：
  - 该图片地址必须是全网都能够访问的一个地址；

配置告警模板

```powershell
vim /usr/local/dingtalk/contrib/templates/dingtalk.tmpl
{{ define "__subject" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .GroupLabels.SortedPairs.Values | join " " }} {{ if gt (len .CommonLabels) (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{ .Values | join " " }}{{ end }}){{ end }}
{{ end }}

{{ define "__alertmanagerURL" }}{{ .ExternalURL }}/#/alerts?receiver={{ .Receiver }}{{ end }}

{{ define "__text_alert_list" }}{{ range . }}
**Labels**
{{ range .Labels.SortedPairs }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}
**Annotations**
{{ range .Annotations.SortedPairs }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}
**Source:** [{{ .GeneratorURL }}]({{ .GeneratorURL }})
{{ end }}{{ end }}

{{ define "___text_alert_list" }}{{ range . }}
---
**告警主题:** {{ .Labels.alertname | upper }}
**告警级别:** {{ .Labels.severity | upper }}
**触发时间:** {{ dateInZone "2006-01-02 15:04:05" (.StartsAt) "Asia/Shanghai" }}
**事件信息:** {{ range .Annotations.SortedPairs }} {{ .Value | markdown | html }}
{{ end }}
**事件标签:**
{{ range .Labels.SortedPairs }}{{ if and (ne (.Name) "severity") (ne (.Name) "summary") (ne (.Name) "team") }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}{{ end }}
{{ end }}{{ end }}

{{ define "___text_alertresovle_list" }}{{ range . }}
---
**告警主题:** {{ .Labels.alertname | upper }}
**告警级别:** {{ .Labels.severity | upper }}
**触发时间:** {{ dateInZone "2006-01-02 15:04:05" (.StartsAt) "Asia/Shanghai" }}
**结束时间:** {{ dateInZone "2006-01-02 15:04:05" (.EndsAt) "Asia/Shanghai" }}
**事件信息:** {{ range .Annotations.SortedPairs }} {{ .Value | markdown | html }}
{{ end }}
**事件标签:**
{{ range .Labels.SortedPairs }}{{ if and (ne (.Name) "severity") (ne (.Name) "summary") (ne (.Name) "team") }}> - {{ .Name }}: {{ .Value | markdown | html }}
{{ end }}{{ end }}
{{ end }}{{ end }}

{{/* Default */}}
{{ define "_default.title" }}{{ template "__subject" . }}{{ end }}

{{ define "_default.content" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}\] **[{{ index .GroupLabels "alertname" }}]({{ template "__alertmanagerURL" . }})**

{{ if gt (len .Alerts.Firing) 0 }}
![警报图标](https://img.icons8.com/color/48/000000/high-importance.png)
**========PromAlert 告警触发========**
{{ template "___text_alert_list" .Alerts.Firing }}
{{ end }}

{{ if gt (len .Alerts.Resolved) 0 }}
![恢复图标](https://img.icons8.com/color/48/000000/ok.png)
**========PromAlert 告警恢复========**
{{ template "___text_alertresovle_list" .Alerts.Resolved }}
{{ end }}
{{ end }}

{{/* Legacy */}}
{{ define "legacy.title" }}{{ template "__subject" . }}{{ end }}

{{ define "legacy.content" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}\] **[{{ index .GroupLabels "alertname" }}]({{ template "__alertmanagerURL" . }})**
{{ template "__text_alert_list" .Alerts.Firing }}
{{ end }}

{{/* Following names for compatibility */}}
{{ define "_ding.link.title" }}{{ template "_default.title" . }}{{ end }}
{{ define "_ding.link.content" }}{{ template "_default.content" . }}{{ end }}
```

应用告警模板 

```powershell
vim /usr/local/dingtalk/conf/config.yml
...
templates:
  - '/usr/local/dingtalk/contrib/templates/dingtalk.tmpl'

default_message:
  title: '{{ template "_ding.link.title" . }}'
  text: '{{ template "_ding.link.content" . }}'
...
targets:
  webhook1:
    url: https://oapi.dingtalk.com/robot/send?access_token=c293e8a905fd6fe98843a235073de1fa346cea3da1bdae8f658c6b1bc3f28abe
    # secret for signature
    secret: SECfd374d045cb4db25ac87ca60b2977c7d1426b8c23d0072b96494c98c026b69ae
# 主要是添加 templates 和 default_message 这两个模块，targets 已经做好了就不要动了！
# 重启dingtalk服务
systemctl  restart dingtalk.service
# 恢复web服务和重启web服务，查看自定义告警文件信息
```

测试截图

![image-20251126165346179](C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20251126165346179.png)

![image-20251126165514292](C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20251126165514292.png)

###### Alertmanager 高可用

- 在不同主机用Alertmanager实现：

第一台主机定义Alertmanager实例A，其中Alertmanager的服务运行在9093端口，集群服务地址运行在9094端口。

```powershell
alertmanager --web.listen-address=":9093" --cluster.listen-address=":9094" --config.file=/etc/prometheus/alertmanager.yml --storage.path=/data/alertmanager/
```

第二台主机定义Alertmanager实例B，为了将A1，A2组成集群。 A2启动时需要定义--cluster.peer参数并且指向A1实例的集群服务地址:8001

```powershell
alertmanager --web.listen-address=":9093" --cluster.listen-address=":9094" --cluster.peer=A主机:9094 --config.file=/etc/prometheus/alertmanager.yml --storage.path=/data/alertmanager/
```

创建Promthues集群配置文件/etc/prometheus/prometheus-ha.yml，完整内容如下：

```powershell
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s
rule_files:
  - /etc/prometheus/rules/*.rules
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - A主机IP:9093
      - B主机IP:9093
```

没时间，也没有精力学后面的内容了。后面的看课件吧！舅学到这儿了！

### 服务发现

- 静态服务发现：在Prometheus配置文件中通过static_config项,手动添加监控的主机实现
- 基于文件的服务发现：将各target记录到文件中，prometheus启动后，周期性刷新这个文件，从而获取最新的target
- 基于 DNS 服务发现：针对一组DNS域名进行定期查询，以发现待监控的目标，并持续监视相关资源的变动
- 基于 Consul 服务发现：基于 Consul 服务实现动态自动发现

###### 静态服务发现

- 默认状态

```powershell
vi /usr/local/prometheus/conf/prometheus.yml
scrape_configs:
  - job_name: "alertmanager"
    static_configs:
      - targets:
        - "10.0.0.202:9093"
        labels:
          app: "alertmanager"
```

###### 文件服务发现

- Target的文件可由手动创建或利用工具生成；
- 文件可使用  YAML 和 JSON 格式，它含有定义的Target列表，以及可选的标签信息,YAML 适合于运维场景，JSON 更适合于开发场景；
- Prometheus Server 定期从文件中加载 Target 信息，根据文件内容发现相应的Target

配置过程和格式

yml 格式

```powershell
# 自行安装 node exporter 服务，这里略过！
mkdir /usr/local/prometheus/conf/targets && cd /usr/local/prometheus/conf/targets/
vi node_exporter.yml
- targets:
  - "10.0.0.200:9100"
  - "10.0.0.201:9100"
  - "10.0.0.202:9100"
  labels:
    app: "node_exporter"
    discovery: "file"
# 修改 prometheus 配置文件自动加载实现自动发现
vi /usr/local/prometheus/conf/prometheus.yml
scrape_configs:
  - job_name: "node_exporter_file"
    scrape_interval: 10s		# 指定抓取数据的时间间隔；（这里是单独配置，也可以全局配置）
    file_sd_configs:
    - files:
      - targets/*.yml
      refresh_interval: 10s		# 指定重读文件的时间间隔，默认值5m
# 语法检查
vi /usr/local/prometheus/bin/promtool check config vi /usr/local/prometheus/conf/prometheus.yml
# 重新加载
systemctl reload prometheus
```

yml 转 json 格式

```powershell
apt update && apt install -y libghc-yaml-dev jq reserialize
cd /usr/local/prometheus/conf/targets/  && cp node_exporter.yml node_exporter_file.yml 
yaml2json /usr/local/prometheus/conf/targets/node_exporter_file.yml  |jq
vi /usr/local/prometheus/conf/targets/node_exporter_file.json
[
  {
    "targets": [
      "10.0.0.200:9100",
      "10.0.0.201:9100",
      "10.0.0.202:9100"
    ],
    "labels": {
      "app": "node_exporter",
      "discovery": "file_json"
    }
  }
]

vi /usr/local/prometheus/conf/prometheus.yml
scrape_configs:
  - job_name: "node_exporter_file_json"
    scrape_interval: 10s
    file_sd_configs:
    - files:
      - targets/*.json
      refresh_interval: 10s
vi /usr/local/prometheus/bin/promtool check config vi /usr/local/prometheus/conf/prometheus.yml
systemctl reload prometheus
# 在 prometheus web 页面 status——target health 应该可以看到 node_exporter_file_json 列表
```



###### DNS 服务发现

部署 DNS 环境

```powershell
apt update && apt -y install bind9 bind9utils bind9-doc bind9-host
named -v
dpkg -L bind9 | grep named.conf			# 查看部署软件
# 定制正向解析 zone 的配置
cat >> /etc/bind/named.conf.default-zones << 'EOF'
//定制网站主域名的zone配置
zone "duan.org" {
    type master;
    file "/etc/bind/duan.org.zone";
};
EOF
# 定制主域名的 zone 文件
vim /etc/bind/duan.org.zone
; BIND data file for wang.org domain
;
$TTL    604800
@       IN      SOA     master.duan.org. admin.duan.org. (
                              1         ; Serial
                        604800         ; Refresh
                         86400         ; Retry
                       2419200         ; Expire
                        604800 )       ; Negative Cache TTL

; Name servers
        IN      NS      master.duan.org.

; A records
master  IN      A       10.0.0.202
node1   IN      A       10.0.0.201
node2   IN      A       10.0.0.200
node3   IN      A       10.0.0.203
flask   IN      A       10.0.0.201

# 检查配置文件
named-checkconf
# 重启dns服务
rndc reload
systemctl restart named  && systemctl status named
# 配置 prometheus 服务器使用DNS域名服务器
vi /etc/netplan/50-cloud-init.yaml 
network:
    version: 2
    ethernets:
        ens33:
            addresses:
            - 10.0.0.202/24
            nameservers:
                addresses:
                - 10.0.0.202
                search:
                - duan.org
                - duan.com
            routes:
            -   to: default
                via: 10.0.0.2
# 应用网络配置
netplan apply
# 确认dns解析效果
dig node1.duan.org
host node1.duan.org

```

配置 DNS服务支持 SRV 记录

```powershell
# 添加SRV记录
vim /etc/bind/duan.org.zone
...
_prometheus._tcp  SRV 10 10 9100 node1
_prometheus._tcp  SRV 10 10 9100 node2
_prometheus._tcp  SRV 10 10 9100 node3
# 检查配置文件
named-checkconf
#生效
rndc reload
#测试解析
dig srv _prometheus._tcp.duan.org
host -t srv _prometheus._tcp.duan.org
```

配置 Prometheus 使用 DNS

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
  - job_name: 'dns_sd_flask'  # 实现单个主机定制的信息解析，也支持DNS或/etc/hosts文件实现解析
    dns_sd_configs:
      - names: ['flask.duan.org']
        type: A  # 指定记录类型，默认SRV
        port: 8000  # 不是SRV时，需要指定Port号
        refresh_interval: 10s

  - job_name: 'dns_sd_node_exporter'  # 实现批量主机解析
    dns_sd_configs:
      - names: ['_prometheus._tcp.duan.org']  # SRV记录必须通过DNS的实现
        refresh_interval: 10s  # 指定DNS资源记录的刷新间隔,默认30s
    relabel_configs:  # 生成新的标签service，值为_prometheus._tcp
      - source_labels: ['__meta_dns_name']
        regex: '(.+?)\.duan\.org'
        target_label: 'service'
        replacement: '$1'

systemctl  reload prometheus.service 
# 在 prometheus web 页面 status——target health 应该可以看到 node_exporter_file_json 列表中对应的域名和标签
```

###### Consul 服务发现

- 单体架构中该服务应用意义不大，主要应用于微服务架构；
- 服务运行可以指定 client 或者 server 模式；规模小直接运行 server 模式；而 Client 是一个转发所有RPC请求到server的代理；

```powershell
# 包安装
apt update && sudo apt install consul

# 二进制安装
https://releases.hashicorp.com/consul/       # 下载连接
wget https://releases.hashicorp.com/consul/1.22.1/consul_1.22.1_linux_amd64.zip
unzip consul_1.22.0_linux_amd64.zip -d /usr/local/bin
cd /usr/local/bin && ls
consul --help					# 查看consul帮助
consul agent --help				# 查看consul帮助
consul -autocomplete-install	# 实现consul命令自动补全
useradd -s /sbin/nologin consul	# 创建用户
mkdir -p /data/consul /etc/consul.d
chown -R consul:consul /data/consul /etc/consul.d
# 测试：以server模式启动服务cosnul agent
/usr/local/bin/consul agent -server -ui -bootstrap-expect=1 -data-dir=/data/consul -config-dir=/etc/consul.d -node=consul -client=0.0.0.0
ss -tunlp | grep 8500
# 创建service文件
cat > /lib/systemd/system/consul.service << EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -server -bind=10.0.0.200 -ui -bootstrap-expect=1 -data-dir=/data/consul -node=consul -client=0.0.0.0 -config-dir=/etc/consul.d
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

chown -R consul:consul /data/consul /etc/consul.d
systemctl daemon-reload
systemctl start consul && systemctl  status consul && ss -tunlp 
# 浏览器输入 10.0.0.200:8500
```

Consul 自动注册和删除服务

```powershell
# 在每个服务器中做域名解析
echo "10.0.0.200 consul.duan.org" >> /etc/hosts
echo "10.0.0.201 node1.duan.org" >> /etc/hosts
# 列出数据中心
curl http://consul.duan.org:8500/v1/catalog/datacenters
# 列出节点
curl http://consul.duan.org:8500/v1/catalog/nodes
# 列出服务
curl http://consul.duan.org:8500/v1/catalog/services
# 指定节点状态
curl http://consul.duan.org:8500/v1/health/node/node2
# 列出服务节点
curl http://consul.duan.org:8500/v1/catalog/service/<service_id>
# 提交Json格式的数据进行注册服务
curl -X PUT -H "Content-Type: application/json" -d '{"id":"myservice-id","name":"myservice","address":"10.0.0.201","port":9100,"tags":["service"],"checks":[{"http":"http://10.0.0.201:9100/","interval":"5s"}]}' http://consul.duan.org:8500/v1/agent/service/register
# 浏览器输入 10.0.0.200:8500 consult 服务器 web 页面查看 ID为 myservice-id 的节点是否注册。

# 删除服务（注意：集群模式下需要在service_id所有在主机节点上执行才能删除该service）
curl -X PUT http://consul.duan.org:8500/v1/agent/service/deregister/myservice-id
```

使用consul services命令注册和注销服务

- 首先保证域名解析都已经配置完成！
- 注册单个服务时，file.json文件使用service进行定义，注册多个服务时，使用services以列表格式进行定义。

```powershell
cat >>  /etc/hosts  <<EOF
10.0.0.201 node1.duan.org
10.0.0.200 node2.duan.org
10.0.0.203 node3.duan.org
EOF

cat services.json
{
  "services": [
    {
      "id": "node1-exporter",
      "name": "node-exporter",
      "address": "node1.duan.org",
      "port": 9100,
      "tags": ["node_exporter", "monitoring"],
      "checks": [
        {
          "http": "http://node1.duan.org:9100/metrics",
          "interval": "5s"
        }
      ]
    },
    {
      "id": "node2-exporter",
      "name": "node-exporter",
      "address": "node2.duan.org",
      "port": 9100,
      "tags": ["node_exporter", "monitoring"],
      "checks": [
        {
          "http": "http://node2.duan.org:9100/metrics",
          "interval": "5s"
        }
      ]
    },
    {
      "id": "node3-exporter",
      "name": "node-exporter",
      "address": "node3.duan.org",
      "port": 9100,
      "tags": ["node_exporter", "monitoring"],
      "checks": [
        {
          "http": "http://node3.duan.org:9100/metrics",
          "interval": "5s"
        }
      ]
    },
    {
      "id": "prometheus-server",
      "name": "prometheus",
      "address": "prometheus.duan.org",
      "port": 9090,
      "tags": ["prometheus", "monitoring"],
      "checks": [
        {
          "http": "http://prometheus.duan.org:9090/-/healthy",
          "interval": "10s"
        }
      ]
    },
    {
      "id": "grafana-dashboard",
      "name": "grafana",
      "address": "grafana.duan.org",
      "port": 3000,
      "tags": ["grafana", "dashboard"],
      "checks": [
        {
          "http": "http://grafana.duan.org:3000/api/health",
          "interval": "15s"
        }
      ]
    }
  ]
}
# 注册
consul services register node1.json
# 取消注册
consul services deregister -id myservice-id
```

配置 Prometheus 使用 Consul 服务发现

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
- job_name: 'consul'
  honor_labels: true  # 如果标签冲突，覆盖Prometheus添加的标签，保留原标签
  consul_sd_configs:
    - server: 'consul.duan.org:8500'
      services: []  # 指定需要发现的service名称,默认为所有service
      # tags:  # 可以过滤具有指定的tag的service
      #   - "service"
      # refresh_interval: 2m  # 刷新时间间隔，默认30s
    #- server: 'consul-node2.duan.org:8500'  # 添加其它两个节点实现冗余
    #- server: 'consul-node3.duan.org:8500'  # 添加其它两个节点实现冗余
  relabel_configs:
    - source_labels: ['__meta_consul_service']  # 生成新的标签名
      target_label: 'consul_service'
    - source_labels: ['__meta_consul_dc']  # 生成新的标签名
      target_label: 'datacenter'
    - source_labels: ['__meta_consul_tags']  # 生成新的标签名
      target_label: 'app'
    - source_labels: ['__meta_consul_service']  # 删除consul的service,此service是consul内置,但并不提供metrics数据
      regex: "consul"
      action: drop

# 检查语法
/usr/local/prometheus/bin/promtool check config  /usr/local/prometheus/conf/prometheus.yml
systemctl  reload prometheus.service
# 在consult 服务器进行服务注册 
curl -X PUT -H "Content-Type: application/json" -d '{"id":"myservice-id","name":"myservice","address":"10.0.0.201","port":9100,"tags":["service"],"checks":[{"http":"http://10.0.0.201:9100/","interval":"5s"}]}' http://consul.duan.org:8500/v1/agent/service/register
# 在 prometheus web 页面查看能否发现该注册服务
```

consul 部署集群

```powershell
# 启动第1个节点
consul agent -bind=10.0.0.201 -client=0.0.0.0 -data-dir=/data/consul -node=node1 -ui -server -bootstrap
# 启动第2个节点
consul agent -bind=10.0.0.202 -client=0.0.0.0 -data-dir=/data/consul -node=node2 -retry-join=10.0.0.201 -ui -server -bootstrap-expect 2
# 启动第3个节点
consul agent -bind=10.0.0.203 -client=0.0.0.0 -data-dir=/data/consul -node=node2 -retry-join=10.0.0.201 -ui -server -bootstrap-expect 2
# 启动成功后，访问第一个有-ui功能的节点：http://10.0.0.201:8500
```

### Exporter

- 应用内置: 软件内就内置了Exporter,比如: Prometheus,Grafana,Gitlab,Zookeeper,MinIO等；
- 应用外置: 应用安装后,还需要单独安装对应的 Exporter,比如: MySQL,Redis,MongoDB,PostgreSQL等
- 定制开发: 如有特殊需要,用户自行开发

> 之前部署的 node exporter 采集指标服务不能采集关于 mysql 、redis 等这些服务指标数据；

###### Node Exporter 监控 9100

```powershell
# 修改 node_exporter 的配置文件
# 在node2节点修改node_exporter配置文件
vi /lib/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
# 只收集指定服务
ExecStart=/usr/local/node_exporter/bin/node_exporter \
    --collector.systemd \
    --collector.systemd.unit-include="(mysql|nginx|ssh|node_exporter)\.service"
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target

# 重启node_exporter服务
systemctl daemon-reload
systemctl restart node_exporter.service
```

修改 Prometheus 配置

```powershell
# 修改prometheus的配置文件，让它自动过滤文件中的节点信息
vim /usr/local/prometheus/conf/prometheus.yml
  - job_name: "node_exporter"
    static_configs:
      - targets:
        - "10.0.0.200:9100"
        - "10.0.0.201:9100"
        - "10.0.0.202:9100"
        labels:
          app: "node_exporter"
# 重启服务
systemctl reload prometheus.service
# 稍等几秒钟，到浏览器中查看监控目标
# 在node2节点安装nginx服务后,再次观察可以看到下面结果
curl -s http://10.0.0.200:9100/metrics | grep -E "(ssh|mysql|nginx)"
# 这个方式只能收集服务系统级的信息，而较为细化的信息收集不到！
```

###### MySQL 监控 9104

- MySQL exporter 监控服务下载地址：https://prometheus.io/download/
- MySQL 服务器：10.0.0.200
- 监控部署在 Prometheus 服务器中：10.0.0.202

```powershell
# MySQL 数据库环境准备
apt update && apt -y install mysql-server
# 更新mysql配置，如果MySQL和MySQL exporter 不在同一个主机，需要修改如下配置
sed -i 's#127.0.0.1#0.0.0.0#' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
# 为mysqld_exporter配置获取数据库信息的用户并授权
CREATE USER 'exporter'@'10.0.0.%' IDENTIFIED BY '123123';
ALTER USER 'exporter'@'10.0.0.%' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'10.0.0.%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'10.0.0.%';
FLUSH PRIVILEGES;

# mysqld_exporter 安装
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.18.0/mysqld_exporter-0.18.0.linux-amd64.tar.gz
# 解压软件
tar xf mysqld_exporter-0.18.0.linux-amd64.tar.gz -C /usr/local
ln -s /usr/local/mysqld_exporter-0.18.0.linux-amd64 /usr/local/mysqld_exporter
cd /usr/local/mysqld_exporter/
mkdir bin
mv mysqld_exporter bin/
# 在mysqld_exporter的服务目录下，创建 .my.cnf 隐藏文件，为 mysqld_exporter 配置获取数据库信息的基本属性
vim /usr/local/mysqld_exporter/.my.cnf
[client]
host=10.0.0.200		# 这个地址该是 MySQL 服务器的实际 IP
port=3306
user=exporter
password=123123
# 创建 prometheus 用户（如果没有 prometheus 用户）
id prometheus &> /dev/null || useradd -r -s /sbin/nologin prometheus
# 修改node_exporter的服务启动文件
vim /lib/systemd/system/mysqld_exporter.service
[Unit]
Description=mysqld exporter project
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/mysqld_exporter/bin/mysqld_exporter --config.my-cnf="/usr/local/mysqld_exporter/.my.cnf"
Restart=on-failure
User=prometheus
Group=prometheus
[Install]
WantedBy=multi-user.target

# 重载并重启服务
systemctl daemon-reload
systemctl enable --now mysqld_exporter.service
ss -tnulp | grep mysql && systemctl status mysqld_exporter.service

# 编辑 Prometheus 配置文件
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: "mysqld_exporter"
    static_configs:
      - targets:
        - "10.0.0.202:9104"
# 重启服务
systemctl reload prometheus.service
# 稍等几秒钟，到浏览器中查看 Prometheus 监控目标
https://samber.github.io/awesome-prometheus-alerts/rules#mysql  		# 参考指标模板
```

Grafana 图形展示

- 导入grafana的镜像模板文件：https://grafana.com/grafana/dashboards/14057,7362,11323,13106,17320(中文版)
- 进入 http://10.0.0.201:3000/  Grafana 网页 —— Dashboards —— inport —— 17320 —— Load —— 选择数据源 —— Import
- 进不去挂梯子！另外选择数据源，连个都要要选 （这里我都选 Prometheus）
  - Prometheus-self7.26    和       VictoriaMetrics-prod-all


展示图

![image-20251127174220318](C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20251127174220318.png)

```powershell
# 做完实验，关闭服务以及服务器自启，节约资源
systemctl  disable --now mysql.service
```

###### Java 监控 9527

- 下载链接：https://prometheus.io/download/
- 对于 Java 应用， 可以借助于专门的 jmx exporter方式来暴露相关的指标数据
- Tomcat 服务器：10.0.0.200  （ Java 应用监控及配置也在这个服务器进行安装）

准备 Java 环境

```powershell
# 方法1：包安装 Tomcat
apt update && apt -y install tomcat10
# 方法2：二进制安装 Tomcat
略
```

准备 Jmx Exporte

```powershell
wget https://github.com/prometheus/jmx_exporter/releases/download/1.5.0/jmx_prometheus_javaagent-1.5.0.jar
# 下载配置文件
wget https://github.com/prometheus/jmx_exporter/blob/main/examples/tomcat.yml
mv jmx_prometheus_javaagent-1.5.0.jar /usr/share/tomcat10/lib/
mv tomcat.yml  /usr/share/tomcat10/etc/
# 修改tomcat的启动脚本 catalina.sh
vim /usr/share/tomcat10/bin/catalina.sh
JAVA_OPTS="-javaagent:/usr/share/tomcat10/lib/jmx_prometheus_javaagent-1.5.0.jar=9527:/usr/share/tomcat10/etc/tomcat.yml"
systemctl restart tomcat10
# 查看 jmx_prometheus_javaagent-1.5.0.jar 是否加载进来了
ps aux | grep  java| grep tomcat.yml
# 浏览器中查看暴露的指标：10.0.0.200:9527/metrics
```

编辑 Prometheus 配置文件

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: "jmx_exporter"
    static_configs:
      - targets:
        - "10.0.0.200:9527"

systemctl reload prometheus.service
```

Grafana 图形展示

- 与上述添加大致相同，这里使用 14845 模版；
- 在 Job 那块需要手动修改名称，要与 prometheus.yml 文件中的指标名称相同，这里就用：jmx_exporter

![image-20251127184146540](C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20251127184146540.png)

```powershell
# 做完实验，关闭服务以及服务器自启，节约资源
systemctl  disable --now tomcat10.service 
```

###### Redis 监控 9121

- redis 服务器：10.0.0.200
- redis_exporter 监控服务部署在 redis 服务器；

```powershell
apt update && apt -y install redis
sed -i.bak -e '/^bind.*/c bind 0.0.0.0' -e '$a requirepass 123123' /etc/redis/redis.conf
vim /etc/redis/redis.conf
bind 0.0.0.0
requirepass 123123
systemctl restart redis
```

```powershell
wget https://github.com/oliver006/redis_exporter/releases/download/v1.80.1/redis_exporter-v1.80.1.linux-amd64.tar.gz
tar xf redis_exporter-v1.80.1.linux-amd64.tar.gz -C /usr/local/
cd /usr/local/ && ls
ln -s redis_exporter-v1.80.1.linux-amd64 redis_exporter
id prometheus &> /dev/null || useradd -r -s /sbin/nologin prometheus
# 修改 node_exporter 的服务启动文件
cat > /lib/systemd/system/redis_exporter.service <<eof
[Unit]
Description=Redis Exporter
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/redis_exporter/bin/redis_exporter \
    -redis.addr redis://localhost:6379 \
    -redis.password 123123
Restart=on-failure

[Install]
WantedBy=multi-user.target
eof

systemctl daemon-reload
systemctl enable --now redis_exporter && systemctl status redis_exporter

# 本机测试访问
curl -s 127.0.0.1:9121/metrics|head
```

编辑 Prometheus 配置文件

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: "redis_exporter"
    static_configs:
      - targets:
        - "10.0.0.200:9121"

systemctl reload prometheus.service
```

 Grafana 图形展示

- Grafana 模板 763  ；模板 11835  ； 模板 14615

```powershell
# 做完实验，关闭服务以及服务器自启，节约资源
systemctl  disable --now redis-server.service && systemctl  status redis-server.service
```

###### Nginx 监控 9113

Nginx 默认自身没有提供 Json 格式的指标数据,可以通过下三种方式实现 Prometheus 监控

- 通过容器方式 nginx/nginx-prometheus-exporter 容器配合nginx的stub状态页实现nginx的监控；
- Prometheus metric library for Nginx
- 先编译安装一个第三方模块nginx-vts,将状态页转换为Json格式，再利用nginx-vts-exporter采集数据到Prometheus；

nginx-prometheus-exporter 容器实现

> 容器下载地址：https://hub.docker.com/r/nginx/nginx-prometheus-exporter

```powershell
apt update && apt install -y docker.io nginx
cat /etc/docker/daemon.json
    {
      "registry-mirrors": ["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"],
      "insecure-registries": ["harbor.duan.org"]
     }
systemctl restart docker
# 拉取镜像
docker pull nginx/nginx-prometheus-exporter:1.5.1
# 配置启用 Nginx 的状态监控页面
cat > /etc/nginx/conf.d/status.conf <<eof
server {
	listen 8888;
	location /basic_status {
		stub_status;
	}
}
eof
nginx -s reload						# 重新加载 Nginx 服务
curl 127.0.0.1:8888/basic_status	  # 测试
Active connections: 1 
server accepts handled requests
 1 1 1 
Reading: 0 Writing: 1 Waiting: 0 
```

| **Active connections** | 当前活跃连接数               | 1    |
| ---------------------- | ---------------------------- | ---- |
| **accepts**            | 已接受的客户端连接总数       | 1    |
| **handled**            | 已处理的连接数               | 1    |
| **requests**           | 客户端总请求数               | 1    |
| **Reading**            | 正在读取请求头的连接数       | 0    |
| **Writing**            | 正在向客户端写入响应的连接数 | 1    |
| **Waiting**            | 保持连接的空闲客户端数       |      |

```powershell
# 启动容器
docker run -p 9113:9113 --name nginx-prometheus-exporter --restart always -d nginx/nginx-prometheus-exporter:1.5.1 --nginx.scrape-uri=http://10.0.0.200:8888/basic_status
# 测试
curl 10.0.0.200:9113/metrics
# 没问题的话就编入 Prometheus 配置文件中
```

编辑 Prometheus 配置文件

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: "nginx_exporter"
    static_configs:
      - targets:
        - "10.0.0.200:9113"

systemctl reload prometheus.service
```

 Grafana 图形展示

- Grafana 模板 2949 ；模板 11199 

```powershell
# 做完实验，关闭服务以及服务器自启，节约资源
systemctl  disable --now nginx.service  && systemctl  status nginx.service
```



###### Consul 监控 9107

- 安装部署不再这里赘述了，就用之前部署好的主机：10.0.0.200    端口：8500

```powershell
# 先安装consul.再部署consul_exporter
wget https://github.com/prometheus/consul_exporter/releases/download/v0.13.0/consul_exporter-0.13.0.linux-amd64.tar.gz
tar xf consul_exporter-0.13.0.linux-amd64.tar.gz -C /usr/local/
ln -sv /usr/local/consul_exporter-0.13.0.linux-amd64 /usr/local/consul_exporter
mkdir /usr/local/consul_exporter/bin/
mv /usr/local/consul_exporter/consul_exporter /usr/local/consul_exporter/bin/
# 创建 consul 用户
useradd -r consul
# 创建 service 文件
cat > /lib/systemd/system/consul_exporter.service <<eof
[Unit]
Description=Consul Exporter
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
Type=simple
User=consul
EnvironmentFile=-/etc/default/consul_exporter
# 具体使用时，若consul_exporter与consul server不在同一主机时，consul server要指向实际的地址；
ExecStart=/usr/local/consul_exporter/bin/consul_exporter \
    --consul.server="http://10.0.0.200:8500" \
    --web.listen-address=":9107" \
    --web.telemetry-path="/metrics" \
    --log.level="info" \
    $ARGS
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
Restart=always

[Install]
WantedBy=multi-user.target
eof
# 启动服务
systemctl daemon-reload
systemctl enable --now consul_exporter.service
ss -tnlp | grep '9107'
curl 10.0.0.200:9107/metrics

```

修改prometheus配置文件监控 consul_exporter

```powershell
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: "consul_exporter"
    static_configs:
      - targets:
        - "10.0.0.200:9107"

systemctl reload prometheus.service
```

Grafana 展示

- 模板 12049

```powershell
# 做完实验，关闭服务以及服务器自启，节约资源
systemctl  disable --now consul && systemctl  status consul
```



##### blackbox_exporter 黑盒监控 9115

- blackbox_exporter是一个二进制Go应用程序，默认监听端口9115；（ 部署主机IP：10.0.0.201 ）
- **外部监控**：从用户角度测试服务可用性
- **不问内部**：不关心服务内部状态，只检查外部表现
- **端到端测试**：模拟真实用户请求验证服务

## 主要监控能力

| 探测类型       | 监控内容                    | 应用场景       |
| :------------- | :-------------------------- | :------------- |
| **HTTP/HTTPS** | 网站可用性、状态码、SSL证书 | Web服务监控    |
| **TCP**        | 端口连通性、响应时间        | 数据库、中间件 |
| **ICMP**       | 网络连通性、延迟            | 网络设备监控   |
| **DNS**        | DNS解析、响应时间           | 域名服务监控   |
| **gRPC**       | gRPC服务健康检查            | 微服务监控     |

blackbox_exporter 安装 （二进制安装）

```powershell
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz
tar xf blackbox_exporter-0.27.0.linux-amd64.tar.gz -C /usr/local/
ln -s /usr/local/blackbox_exporter-0.27.0.linux-amd64/ /usr/local/blackbox_exporter
cd /usr/local/blackbox_exporter/ && mkdir bin conf && ls
mv blackbox_exporter bin/ && mv blackbox.yml conf/
# 新版blackbox_exporter-0.26.0 如果以普通用户启动，会导致探测失败
id prometheus &> /dev/null || useradd -r -s /sbin/nologin prometheus
# 创建service文件
cat > /lib/systemd/system/blackbox_exporter.service << 'EOF'
[Unit]
Description=Prometheus Blackbox Exporter
After=network.target

[Service]
Type=simple
# 新版blackbox_exporter-0.26.0如果以普通用户启动，会导致探测失败
# User=prometheus
# Group=prometheus
ExecStart=/usr/local/blackbox_exporter/bin/blackbox_exporter \
    --config.file=/usr/local/blackbox_exporter/conf/blackbox.yml \
    --web.listen-address=:9115
Restart=on-failure
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start blackbox_exporter && systemctl status blackbox_exporter
ss -tunlp | grep black
# 浏览器访问：http://10.0.0.201:9115
```

Prometheus 配置定义监控规则

```powershell
# 添加域名 （两台服务器都添加域名）
echo "10.0.0.201 black-exporter.duan.org" >> /etc/hosts
# 做这个实验采用了 icmp 和 tcp 两个通信方式分别进行尽快采样观测；
# 但是好像需要nginx服务，没看懂，就像这样吗！
vim /usr/local/prometheus/conf/prometheus.yml
...
  - job_name: 'ping_status_blackbox_exporter'
    metrics_path: /probe
    params:
      module: [icmp]  # 探测方式
    static_configs:
      - targets: 
        - '10.0.0.201'
        - 'www.google.com'  # 探测的目标主机地址
        labels:
          instance: 'ping_status'
          group: 'icmp'
    relabel_configs:
      - source_labels: [__address__]  
        # 修改目标URL地址的标签[__address__]为__param_target,用于发送给blackbox使用
        target_label: __param_target  # 此为必须项
      - target_label: __address__  
        # 添加新标签，用于指定black_exporter服务器地址,此为必须项
        replacement: 'black-exporter.duan.org:9115'  # 指定black_exporter服务器地址,注意名称解析
      - source_labels: [__param_target]  
        # Grafana 使用此标签进行显示，此值是固定的
        target_label: ipaddr  
        # Grafana 展示的字段名，如果自定义，默认的ipaddr字段仍然存在，只是不再有数据
        
/usr/local/prometheus/bin/promtool check config /usr/local/prometheus/conf/prometheus.yml
systemctl  reload prometheus.service 
# 打开浏览器 http://10.0.0.202:9090  查看服务
# 打开浏览器 http://10.0.0.201:9115/  可以看到已经探测的记录
```

三种监控方式都没有做好！就先这样吧！以后再捋思路！

