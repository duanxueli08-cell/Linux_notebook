
---

# MySQL 主从复制部署实验（Rocky 9）

## 📌 实验目标

在主服务器创建数据库并写入数据，通过主从复制机制，让从库实时同步主库数据。  
客户端连接主/从库进行查询，实现数据同步验证。

**实验环境：**

|角色|系统|IP|
|---|---|---|
|主库（Master）|Rocky Linux 9|`10.0.0.10`|
|从库（Slave）|Rocky Linux 9|`10.0.0.11`|

**MySQL 版本：** 8.x 以上（实验中使用 MySQL 社区版本）

---

## 🗂️ 目录

下面是为你重新整理的 **专业版 MySQL 主从复制部署实验 Markdown 文档**。
结构清晰、可直接发布/培训使用，包含目录、图示、步骤、命令高亮、注意事项。

---

# MySQL 主从复制部署实验（Rocky 9）

## 📌 实验目标

在主服务器创建数据库并写入数据，通过主从复制机制，让从库实时同步主库数据。
客户端连接主/从库进行查询，实现数据同步验证。

**实验环境：**

| 角色         | 系统            | IP          |
| ---------- | ------------- | ----------- |
| 主库（Master） | Rocky Linux 9 | `10.0.0.10` |
| 从库（Slave）  | Rocky Linux 9 | `10.0.0.11` |

**MySQL 版本：** 8.x 以上（实验中使用 MySQL 社区版本）

---

## 🗂️ 目录

1. [实验架构图](#实验架构图)
2. [主库配置（10.0.0.10）](#主库配置-1000010)
3. [从库配置（10.0.0.11）](#从库配置-1000011)
4. [验证主从同步](#验证主从同步)
5. [解除主库读锁](#解除主库读锁)
6. [客户端测试](#客户端测试)
7. [常见问题与检查项](#常见问题与检查项)

---

## 实验架构图

```
┌──────────────────────────┐
│     主库 Master           │
│  Rocky 9 — 10.0.0.10      │
│  开启 binlog，server-id=1 │
└───────────────┬──────────┘
                │
        MySQL Replication
                │
┌───────────────▼──────────┐
│      从库 Slave           │
│  Rocky 9 — 10.0.0.11      │
│  relay-bin，server-id=2   │
└───────────────────────────┘
```

---

# 主库配置 (10.0.0.10)

## 1. 安装 MySQL

```bash
sudo dnf install mysql-server -y
sudo systemctl enable --now mysqld
```

---

## 2. 修改主库配置文件 `/etc/my.cnf`

```ini
[mysqld]
server-id=1
log_bin=mysql-bin
bind-address=0.0.0.0
default_authentication_plugin=mysql_native_password
```

> **说明：**
>
> * `server-id` **必须唯一**
> * `log_bin` 是开启主从复制必需项
> * `bind-address` 为实验需要开放所有来源，生产环境建议限制为内网段

---

## 3. 重启 MySQL

```bash
sudo systemctl restart mysqld
```

---

## 4. 创建复制用户

```bash
mysql -uroot -p

create database testdb;

create user 'tom'@'10.0.0.%' identified by 'Duan@0714';

grant replication slave on *.* to 'tom'@'10.0.0.%';

flush privileges;
```

---

## 5. 获取主库 binlog 位置信息（非常关键）

```sql
flush tables with read lock;
show master status;
```

📌 请 **保持此会话不要关闭**，否则锁会失效。

记录结果，例如：

| File             | Position |
| ---------------- | -------- |
| mysql-bin.000001 | 154      |

---

# 从库配置 (10.0.0.11)

## 1. 安装 MySQL

```bash
sudo dnf makecache
sudo dnf install mysql-server -y
sudo systemctl enable --now mysqld
```

---

## 2. 修改从库配置 `/etc/my.cnf`

```ini
[mysqld]
server-id=2
relay-log=relay-bin
bind-address=0.0.0.0
default_authentication_plugin=mysql_native_password
```

---

## 3. 重启 MySQL

```bash
sudo systemctl restart mysqld
```

---

## 4. 配置复制信息（CHANGE MASTER）

```bash
mysql -uroot -p
```

```sql
stop slave;

change master to
  master_host='10.0.0.10',
  master_user='tom',
  master_password='Duan@0714',
  master_log_file='mysql-bin.000001',
  master_log_pos=154;

start slave;
```

---

## 5. 查看复制状态

```sql
show slave status\G
```

确保以下两项都是 `Yes`：

```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

正常状态一般显示为：

```
Waiting for master to send event
```

---

# 验证主从同步

在**主库**执行：

```sql
create database demo_db;
create table demo_db.t1(id int);
insert into demo_db.t1 values(1);
```

在**从库**查看：

```sql
show databases;
select * from demo_db.t1;
```

若能查询到相同数据，即同步成功。

---

# 解除主库读锁

如果仍有之前的锁，需执行：

```sql
unlock tables;
```

---

# 客户端测试

假设客户端 IP 为：`10.0.0.30`

### 连接主库写入：

```bash
mysql -h 10.0.0.10 -utom -p -e "create database clientdb;"
```

### 连接从库读取：

```bash
mysql -h 10.0.0.11 -utom -p -e "show databases;"
```

出现 `clientdb` 即为同步成功。

---

# 常见问题与检查项

| 问题                   | 原因            | 解决方式                |
| -------------------- | ------------- | ------------------- |
| Slave_IO_Running=No  | 网络/用户权限       | 检查用户、密码、防火墙         |
| Slave_SQL_Running=No | SQL 执行失败      | 查看 `Last_Error` 并修复 |
| 主库 binlog 未更新        | log_bin 未开启   | 检查 `/etc/my.cnf`    |
| 位置不一致                | master_pos 错误 | 重新记录 File/Pos       |

---

# 🎉 完整部署文档已整理完毕！

如果你需要，我可以继续为你：

✅ 生成 PDF、HTML、或富格式文档
✅ 添加 GTID 模式版本（更先进）
✅ 添加 MySQL 主主复制（双主）
✅ 添加 MySQL + Keepalived 高可用架构图

需要继续扩展吗？

    

---

## 实验架构图

```
┌──────────────────────────┐
│     主库 Master           │
│  Rocky 9 — 10.0.0.10      │
│  开启 binlog，server-id=1 │
└───────────────┬──────────┘
                │
        MySQL Replication
                │
┌───────────────▼──────────┐
│      从库 Slave           │
│  Rocky 9 — 10.0.0.11      │
│  relay-bin，server-id=2   │
└───────────────────────────┘
```

---

# 主库配置 (10.0.0.10)

## 1. 安装 MySQL

```bash
sudo dnf install mysql-server -y
sudo systemctl enable --now mysqld
```

---

## 2. 修改主库配置文件 `/etc/my.cnf`

```ini
[mysqld]
server-id=1
log_bin=mysql-bin
bind-address=0.0.0.0
default_authentication_plugin=mysql_native_password
```

> **说明：**
> 
> - `server-id` **必须唯一**
>     
> - `log_bin` 是开启主从复制必需项
>     
> - `bind-address` 为实验需要开放所有来源，生产环境建议限制为内网段
>     

---

## 3. 重启 MySQL

```bash
sudo systemctl restart mysqld
```

---

## 4. 创建复制用户

```bash
mysql -uroot -p

create database testdb;

create user 'tom'@'10.0.0.%' identified by 'Duan@0714';

grant replication slave on *.* to 'tom'@'10.0.0.%';

flush privileges;
```

---

## 5. 获取主库 binlog 位置信息（非常关键）

```sql
flush tables with read lock;
show master status;
```

📌 请 **保持此会话不要关闭**，否则锁会失效。

记录结果，例如：

|File|Position|
|---|---|
|mysql-bin.000001|154|

---

# 从库配置 (10.0.0.11)

## 1. 安装 MySQL

```bash
sudo dnf makecache
sudo dnf install mysql-server -y
sudo systemctl enable --now mysqld
```

---

## 2. 修改从库配置 `/etc/my.cnf`

```ini
[mysqld]
server-id=2
relay-log=relay-bin
bind-address=0.0.0.0
default_authentication_plugin=mysql_native_password
```

---

## 3. 重启 MySQL

```bash
sudo systemctl restart mysqld
```

---

## 4. 配置复制信息（CHANGE MASTER）

```bash
mysql -uroot -p
```

```sql
stop slave;

change master to
  master_host='10.0.0.10',
  master_user='tom',
  master_password='Duan@0714',
  master_log_file='mysql-bin.000001',
  master_log_pos=154;

start slave;
```

---

## 5. 查看复制状态

```sql
show slave status\G
```

确保以下两项都是 `Yes`：

```
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

正常状态一般显示为：

```
Waiting for master to send event
```

---

# 验证主从同步

在**主库**执行：

```sql
create database demo_db;
create table demo_db.t1(id int);
insert into demo_db.t1 values(1);
```

在**从库**查看：

```sql
show databases;
select * from demo_db.t1;
```

若能查询到相同数据，即同步成功。

---

# 解除主库读锁

如果仍有之前的锁，需执行：

```sql
unlock tables;
```

---

# 客户端测试

假设客户端 IP 为：`10.0.0.30`

### 连接主库写入：

```bash
mysql -h 10.0.0.10 -utom -p -e "create database clientdb;"
```

### 连接从库读取：

```bash
mysql -h 10.0.0.11 -utom -p -e "show databases;"
```

出现 `clientdb` 即为同步成功。

---

# 常见问题与检查项

| 问题                   | 原因            | 解决方式                |
| -------------------- | ------------- | ------------------- |
| Slave_IO_Running=No  | 网络/用户权限       | 检查用户、密码、防火墙         |
| Slave_SQL_Running=No | SQL 执行失败      | 查看 `Last_Error` 并修复 |
| 主库 binlog 未更新        | log_bin 未开启   | 检查 `/etc/my.cnf`    |
| 位置不一致                | master_pos 错误 | 重新记录 File/Pos       |

---

# 🎉 完整部署文档已整理完毕！
