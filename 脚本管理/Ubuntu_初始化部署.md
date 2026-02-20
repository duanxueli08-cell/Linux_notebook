### 脚本

```bash
#!/bin/bash

# ==============================================================================
# 脚本说明：Ubuntu 22.04 初始化一键部署脚本 (极简解耦版)
# ==============================================================================

# 确保脚本以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[1;31m请使用 root 用户执行此脚本。\e[0m"
  exit 1
fi

echo -e "\e[1;32m[1/8] 正在配置系统基础环境变量 (PS1)...\e[0m"
# 添加带颜色的高亮终端提示符
if ! grep -q "PS1=" /root/.bashrc; then
cat >> /root/.bashrc << 'EOF'
PS1='[\[\e[1;31m\]\u@\h\[\e[0m\]:\[\e[1;35m\]\w\[\e[0m\]]\$ '
EOF
fi

echo -e "\e[1;32m[2/8] 正在备份默认源并配置阿里云 DEB822 格式软件源...\e[0m"
# 备份旧的软件源
if [ -f /etc/apt/sources.list ]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
fi

# 写入新的 ubuntu.sources
cat > /etc/apt/sources.list.d/ubuntu.sources << EOF
Types: deb
URIs: https://mirrors.aliyun.com/ubuntu/
Suites: jammy jammy-updates jammy-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.aliyun.com/ubuntu/
Suites: jammy-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# 更新软件包列表并安装基础工具
apt update
apt install -y wget curl tree bash-completion

echo -e "\e[1;32m[3/8] 正在配置时区与系统时间同步...\e[0m"
# 设置时区为上海
timedatectl set-timezone Asia/Shanghai
# 使用 systemd-timesyncd 强制同步阿里云 NTP
sed -i 's/#NTP=/NTP=ntp.aliyun.com/' /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd

echo -e "\e[1;32m[4/8] 正在配置 SSH 远程登录权限...\e[0m"
# 允许 Root 登录，同时保留密码认证
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

echo -e "\e[1;32m[5/8] 正在进行系统底层核心优化...\e[0m"
# 1. 提升文件句柄数
cat >> /etc/security/limits.conf << 'EOF'
* soft nofile 65535
* hard nofile 65535
EOF

# 2. 彻底关闭 Swap（满足容器或高并发实验需求）
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

# 3. 开启 IPv4 路由转发
if grep -q "net.ipv4.ip_forward" /etc/sysctl.conf; then
    sed -i 's/^#*net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
else
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p

echo -e "\e[1;32m[6/8] 正在自动抓取并修改网卡命名规则...\e[0m"
# 自动抓取当前默认路由对应的活动网卡（如 ens33）
OLD_NIC=$(ip -o -4 route show to default | awk '{print $5}' | head -n 1)

if [ -n "$OLD_NIC" ] && [ "$OLD_NIC" != "eth0" ]; then
    echo -e "\e[1;33m -> 检测到当前网卡为 $OLD_NIC，准备将其替换为 eth0\e[0m"
    
    # 修改 GRUB 内核参数，禁用可预测命名
    sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
    update-grub
    
    # 自动定位 /etc/netplan/ 下的 yaml 配置文件，并替换其中的旧网卡名
    NETPLAN_FILE=$(ls /etc/netplan/*.yaml 2>/dev/null | head -n 1)
    if [ -n "$NETPLAN_FILE" ]; then
        sed -i "s/$OLD_NIC/eth0/g" "$NETPLAN_FILE"
        echo -e "\e[1;33m -> 已将 $NETPLAN_FILE 中的 $OLD_NIC 替换为 eth0\e[0m"
    else
        echo -e "\e[1;31m -> 未找到 Netplan 配置文件，请稍后手动检查！\e[0m"
    fi
else
    echo -e "\e[1;33m -> 当前网卡已经是 eth0 或未能获取网卡名，跳过重命名。\e[0m"
fi

echo -e "\e[1;32m[7/8] 初始化脚本执行完毕！\e[0m"
echo -e "\e[1;31m[8/8] 系统需要重启以应用网卡改名和内核参数。\e[0m"

# 倒计时重启
for i in {5..1}; do
    echo -ne "系统将在 $i 秒后重启...\r"
    sleep 1
done
echo -e "\n正在重启..."
reboot

```

### 💡 执行

1. 在你的 Ubuntu 中新建文件：
```bash
vi init.sh
```


2. 按 `i` 进入插入模式，将上面的代码粘贴进去，然后按 `Esc` 输入 `:wq` 保存。
3. 赋予执行权限并运行：
```bash
chmod +x init.sh
./init.sh
```
