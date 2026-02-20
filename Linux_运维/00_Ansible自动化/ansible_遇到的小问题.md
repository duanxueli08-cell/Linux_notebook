Ubuntu 2204 安装 ansible

```
# 1. 安装工具（如果尚未安装）
sudo apt install software-properties-common -y

# 2. 添加源（这才是正确的写法）
sudo add-apt-repository --yes --update ppa:ansible/ansible

# 3. 安装软件
sudo apt install ansible
```