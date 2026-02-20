
> 平时大都是通过 windows 系统操作，所以我就在 windows 系统生产密钥对，将公钥发送给被控制端的设备！

```powershell
# 查看是否存在 .ssh 目录
ls $env:USERPROFILE\.ssh

# 查看密钥文件
ls $env:USERPROFILE\.ssh\id_*.pub
```

>如果没有密钥对，通过下面的步骤完成；

```powershell
ssh-keygen -t ed25519 -C "shirley@shenzhou.notebook"
# 一路回车（默认存到 .ssh\id_ed25519）

# -t ed25519 = 当代黄金标准（快、小、硬）
# -C "xxx" = 给公钥贴标签（方便管理，非密码）
# 空 passphrase = 把家门钥匙扔在门口 —— 永远设一个
```

>最后将生成的公钥拷贝到被控制的设备中

```
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh root@10.0.0.61 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

>**由于是windows 系统，在进行文本传输时会涉及到一些隐藏字符，一定要注意最后的检查哦！！！**

```
cat -A ~/.ssh/authorized_keys

# 如果有隐藏字符作祟，用这个指令快速解决
sed -i 's/^.*ssh-ed25519/ssh-ed25519/' ~/.ssh/authorized_keys
```

