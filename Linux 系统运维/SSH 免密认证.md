**生成密钥**
```
ssh-keygen -t rsa

# 密钥文件默认存放中在：/用户/.ssh/
```

**批量传送自己的公钥**
```
for host in 10.0.0.{147,200,100,101,102}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
done

# 禁用首次连接时的 Host Key 检查：-o StrictHostKeyChecking=no
```

**测试免密连接**
```
ssh root@10.0.0.200

# 直接登录，无需输入密码和确认 
```