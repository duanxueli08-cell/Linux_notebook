```powershell
https://bucd.info/api/v1/client/subscribe?token=f48c929668d9571f45dfaaccbd8c9d11

半年
https://488113.xyz/t/p/dec8c9e2930842d4171ba59fd270d206
```

根据你的配置和步骤，让我们分析一下数据流向：

## 数据流向分析：

### 1. **Filebeat → Redis**
- Filebeat 从 Nginx 日志文件读取数据
- Filebeat 将格式化后的 JSON 日志推送到 Redis
- 根据你的配置，应该是推送到 Redis 的 `filebeat` 键（list 类型）

### 2. **检查 Filebeat 是否正确推送数据到 Redis**

**检查 Filebeat 配置：**
```bash
# 查看 Filebeat 配置文件
cat /etc/filebeat/filebeat.yml
```

**Filebeat 配置文件应该包含类似这样的 Redis 输出：**
```yaml
output.redis:
  hosts: ["10.0.0.201:6379"]
  password: "123123"
  key: "filebeat"           # 对应 Logstash 配置中的 key
  db: 0
  datatype: "list"          # 对应 Logstash 配置中的 data_type
```

### 3. **检查 Redis 中是否有数据**

```bash
# 连接到 Redis 检查数据
redis-cli -h 10.0.0.201 -a 123123

# 查看 filebeat 列表长度
LLEN filebeat

# 查看列表中的几条数据（不删除）
LRANGE filebeat 0 5

# 或者查看并删除一条（用于测试）
LPOP filebeat
```

### 4. **测试整个数据流**

**步骤1：手动向 Redis 添加测试数据**
```bash
# 模拟 Filebeat 推送一条 Nginx 访问日志
redis-cli -h 10.0.0.201 -a 123123 LPUSH filebeat '{
  "@timestamp": "2025-12-06T23:00:00Z",
  "clientip": "192.168.1.100",
  "host": "10.0.0.201",
  "http_host": "example.com",
  "uri": "/test",
  "status": "200",
  "size": "1500",
  "responsetime": "0.123",
  "upstreamtime": "0.100",
  "http_user_agent": "Mozilla/5.0",
  "referer": "-",
  "tags": ["nginx-access"]
}'
```

**步骤2：检查 Logstash 是否处理数据**
```bash
# 查看 Logstash 日志
sudo journalctl -u logstash -f

# 或者在 Logstash 配置中，我们启用了 stdout 输出
# 如果 Logstash 正在运行，你应该能在日志中看到处理后的数据
```

### 5. **检查 Elasticsearch 中是否有数据**

```bash
# 检查 Elasticsearch 中是否有对应索引
curl -X GET "http://10.0.0.201:9200/_cat/indices?v" | grep nginx

# 查看索引中的文档
curl -X GET "http://10.0.0.201:9200/nginx-access-2025.12.06/_search?pretty"
```

### 6. **诊断工具**

**创建诊断脚本：**
```bash
cat > check_data_flow.sh << 'EOF'
#!/bin/bash

echo "=== 1. 检查 Redis 数据 ==="
redis-cli -h 10.0.0.201 -a 123123 LLEN filebeat

echo -e "\n=== 2. 检查 Elasticsearch 索引 ==="
curl -s "http://10.0.0.201:9200/_cat/indices?v" | grep -E "nginx|syslog"

echo -e "\n=== 3. 检查 Logstash 状态 ==="
sudo systemctl status logstash --no-pager -l

echo -e "\n=== 4. 检查 Filebeat 状态 ==="
sudo systemctl status filebeat --no-pager -l

echo -e "\n=== 5. 最近 Logstash 日志 ==="
sudo journalctl -u logstash --no-pager -n 20
EOF

chmod +x check_data_flow.sh
./check_data_flow.sh
```

### 7. **如果 Redis 中没有数据，检查 Filebeat**

```bash
# 查看 Filebeat 日志
sudo journalctl -u filebeat -f

# 检查 Filebeat 是否在监控正确的文件
sudo filebeat test config
sudo filebeat test output

# 查看 Filebeat 进程状态
ps aux | grep filebeat

# 重启 Filebeat
sudo systemctl restart filebeat
```

### 8. **快速测试整个流程**

```bash
# 1. 确保所有服务运行
sudo systemctl status filebeat redis logstash

# 2. 清除 Redis 中的测试数据（可选）
redis-cli -h 10.0.0.201 -a 123123 DEL filebeat

# 3. 触发 Nginx 访问（产生日志）
curl http://localhost/  # 或在浏览器访问

# 4. 检查数据流
sleep 5
redis-cli -h 10.0.0.201 -a 123123 LLEN filebeat

# 5. 查看 Elasticsearch
curl "http://10.0.0.201:9200/nginx-access-$(date +%Y.%m.%d)/_count?pretty"
```

## 常见问题和解决方案：

1. **Filebeat 没有读取日志文件权限**
   ```bash
   sudo chmod 644 /var/log/nginx/access.log
   ```

2. **Filebeat 配置错误**
   ```bash
   # 测试 Filebeat 配置
   sudo filebeat test config
   sudo filebeat test output
   ```

3. **Redis 连接问题**
   ```bash
   # 测试 Redis 连接
   redis-cli -h 10.0.0.201 -a 123123 PING
   ```

4. **Logstash 解析问题**
   ```bash
   # 使用最小配置测试
   sudo tee /tmp/test.conf << 'EOF'
   input {
     redis {
       host => "10.0.0.201"
       password => "123123"
       key => "filebeat"
     }
   }
   output { stdout { codec => rubydebug } }
   EOF
   
   sudo -u logstash /usr/share/logstash/bin/logstash -f /tmp/test.conf
   ```

请运行这些检查命令，告诉我结果，我可以帮你进一步诊断问题所在。
