### 故障背景

无意间将 windows 系统下 C:\Users\Administrator\.ssh 目录下的密钥对删除导致 Obsidian 笔记推送信息内容失败！如图所示：
![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20260220171239365.png)

### 解决过程

>在 windows 系统中重新生成密钥对，再把新公钥添加到 GitHub

具体操作步骤：

```
# 查看文件路径
ls $env:USERPROFILE\.ssh

# 无脑三次回车生成密钥对，
ssh-keygen -t ed25519 -C "shirley@shenzhou.notebook"
```

- 登录 GitHub → 点击右上角头像 → Settings → SSH and GPG keys → New SSH key

- Key type：✅ Authentication key（默认）

- Key：粘贴刚才复制的整段公钥

- Add SSH key

```
# 测试 SSH 连接是否成功
ssh -T git@github.com

# 正常输出应为：
Hi your_username! You've successfully authenticated, but GitHub does not provide shell access.
```