### Git

#### 面试问题

svn与git的区别

什么是版本控制系统（vcs）

#### 第一部分--安装；创建

```powershell
以ubuntu为例
# 下载git软件包
apt update; apt install git
# 验证安装
git --version
# 设置你全局的用户名和邮箱（提交代码时的作者信息）
git config --global user.name "自定义你的姓名"
git config --global user.email "自定义你的邮箱@example.com"
# 查看设置的用户信息
git config  --list
# 创建版本库
cd /data/mygit
git init 			
## 这时候你当前/data/mygit目录下会多了一个.git的目录，这个目录是Git来跟踪管理版本的；
# 在/data/mygit目录下创建一个text文件，并将该文件添加到暂存区中，最后提交到仓库中；
echo "惊天浪淘沙" >> test
git add test
git commit -m test
# 查看是否有文件未被提交
git status
# 修改文件；查看具体修改内容
echo "雷霆半月斩" >> test  &&  git  status
```

#### 第二部分--查看；撤销

```powershell
# 撤销工作区的增删改操作（恢复为暂存区版本）
git restore test                    # 推荐
git checkout -- test               # 传统方式

# 撤销暂存区的增删改操作（移回工作区，保留修改）
git restore --staged test          # 推荐  
git reset test                     # 更简洁
git reset HEAD test                # 效果相同于：git reset test 

# 完全撤销（工作区 + 暂存区都恢复到最新提交）
git restore --staged --worktree test

# 查看
git branch                         # 查看当前分支
git branch -a                      # 查看所有分支 （远程和本地）
git status                         # 查看当前状态
git config --global --list         # 查看当前用户在 Git 全局配置中的所有设置
git diff test                      # 查看未暂存的修改
git diff --staged test             # 查看已暂存待提交的修改
git diff HEAD test                 # 查看所有未提交的修改
git show master:test               # 查看指定分支（master）中指定文件（test）在最新提交时的内容
                                   # 效果等同于：git show master -- test
git log                            # 查看当前分支的提交历史
                                   # git log master      查看 master 分支的日志（不切换分支）
                                   # git log --all       查看所有分支的日志
```

#### 第三部分--分支

```powershell
# 传统——创建分支并切换
git checkout -b feature/分支描述
# 新版 ——创建并切换到新分支 （Git 2.23+）
git switch -c feature/分支描述
# 查看 master 分支中的所有文件
git ls-tree -r master --name-only
# 查看 feature 分支中的所有文件
git ls-tree -r feature/分支描述 --name-only

合并分区内容
# 切换到master分支
git checkout master
# 将are1/测试分支的修改合并到master（当前分区）
git merge are1/测试
# 删除 are1/测试 分区
git branch –d are1/测试

合并常常产生冲突
root@ubuntu-nfs-200:~/gitlab# git merge ceshi 
Auto-merging test
CONFLICT (content): Merge conflict in test
Automatic merge failed; fix conflicts and then commit the result.
# 类似于上面这个，产生冲突后，查看文件进行修改
root@ubuntu-nfs-200:~/gitlab# cat test
<<<<<<< HEAD
#惊天浪淘沙#
#雷霆半月斩#
999
=======

#!/bin/bash
cat /etc/os-re*
>>>>>>> ceshi

# 根据自己的需求增删改
root@ubuntu-nfs-200:~/gitlab# cat test 
#!/bin/bash
cat /etc/os-re*
echo "勇敢牛牛不怕困难^_^"

# 最后提交修改的文件     git add  test   ；  git  commit  -m  test
```

#### 第部分--远程仓库

```powershell
# 创建SSH Key ；
# 会在指定目录下有没有id_rsa和id_rsa.pub这两个文件 （默认是/root）
# id_rsa是私钥，不能泄露出去，id_rsa.pub是公钥，可以放心地告诉任何人。
ssh-keygen -t rsa -C "duan@163.com"
# 三次回车在/root/.ssh/目录中生成id_rsa.pub和id_rsa
# 登录github,打开” settings”中的SSH Keys页面，然后点击“Add SSH Key”,填上任意title（比如：测试远程demo），在Key文本框里黏贴id_rsa.pub文件的内容。
# 然后在右上角找到“create a new repo”创建一个新的仓库  --> New repository 
# 在Repository name填入mygit，其他保持默认设置，点击“Create repository”按钮，就成功地创建了一个新的Git仓库

# 为当前本地仓库添加一个名为origin的远程仓库，其地址是GitHub上duanxueli08-cell用户（显示的名称）的mygit仓库
git remote add origin git@github.com:duanxueli08-cell/mygit.git 
# 推送代码到GitHub
git push -u origin master
# 查看远程仓库信息
git remote -v

远程拉取
# 登录github，创建一个新的仓库，名字叫test2 ；其他不变，打开带有readme的选项；
# 克隆一个本地库，执行指令后会自动生成一个test2的目录；这个文件夹包含完整的仓库代码、历史记录和Git配置；
# 克隆仓库（首次获取）
git clone git@github.com:duanxueli08-cell/test2
# 进入仓库目录
cd mygit
# 查看有哪些分支
git branch -a
# 拉取更新（后续同步）
git pull origin 分支名       # 拉取当前分支的最新代码
git fetch --all             # 获取所有远程分支的更新信息


# 测试SSH连接
ssh -T git@github.com
# 删除当前的远程仓库配置（如果有问题需要重新配置）
git remote remove origin
# 失败案例——使用https协议建立远程仓库未成功；ssh连接相对于https更便捷更安全
git remote add origin https://github.com/duanxueli08-cell/mygit.git
```

- **在GitHub上创建的仓库名**：`mygit`
- **Git远程地址中的名称**：`mygit.git`
- **实际存储的仓库名称**：`mygit`

```
# GitHub创建时填写的仓库名：mygit
# 对应的远程地址：git@github.com:username/mygit.git
```

#### **这些图片，无需多盐！**

![image-20251116174822208](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251116174822208.png)

![image-20251116174541249](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251116174541249.png)

![image-20251116172550065](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251116172550065.png)

![image-20251116172114867](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251116172114867.png)

![img](https://deepseek-api-files.obs.cn-east-3.myhuaweicloud.com/raw/2025/11/16/file-bac217ae-c0c9-4628-8d05-7a29e2917147?response-content-disposition=attachment%3B+filename%3D%22image.png%22&AccessKeyId=OD83TSXECLFQNNSZ3IF6&Expires=1763371007&Signature=OzB%2B2STG2qPrnc4umDqVXwdJiuI%3D)

- **用户名**: `Shirley.Duan`
- **显示名称**: `duanxueli08-cell`
- **仓库**: `duanxueli08-cell/mygit` 已经创建成功
- GitHub显示的仓库名称是 `duanxueli08-cell/mygit`，这意味着仓库路径使用了显示名称而不是用户名。

### Gitlab

#### 安装

```powershell
# GitLab-CE 安装包官方下载地址：
https://packages.gitlab.com/gitlab/gitlab-ce
# 通过软件源（清华）下载和安装
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu/pool/noble/main/g/gitlab-ce/gitlab-ce_18.5.2-ce.0_amd64.deb
dpkg -i gitlab-ce_18.5.2-ce.0_amd64.deb

```

#### 基础配置

gitlab相关目录：

```powershell
/etc/gitlab #配置文件目录，重要
/var/opt/gitlab #数据目录,源代码就存放在此目录,重要
/var/log/gitlab #日志目录
/run/gitlab #运行目录,存放很多的数据库文件
/opt/gitlab #安装目录
```

初始化配置

```powershell
# 查看配置文件
grep "^[a-Z]" /etc/gitlab/gitlab.rb
# 编辑配置文件
vim /etc/gitlab/gitlab.rb
external_url 'http://gitlab.wang.org'		 # 修改此行
#可选
nginx['listen_port']=8080					# 修改nginx代理监听的端口
gitlab_sshd['enable']=true					# 是否启用sshd服务

# 域名解析
vim /etc/hosts
10.0.0.200 gitlab.duan.org
```

```powershell
# 执行配置reconfigure并启动服务 （每次修改完配置文件都需要执行此操作）
gitlab-ctl reconfigure

# 查看 gitlab 组件运行状态
gitlab-ctl status

gitlab-ctl stop  # 停止gitlab
gitlab-ctl start # 启动gitlab
```

> 浏览器访问  http://gitlab.duan.org
>
> 默认用户为root，其密码是随机生成
>
> 如果没有在配置文件中对密码做初始化设置,可以从这个文件找到初始密码：cat /etc/gitlab/initial_root_password

#### 新建项目

注意: 此处在新建项目时先不进行初始化

#### 导入项目

设置——通用——导入和导出设置——repository by URL （其他的自定义选择）



#### gitlab迁移和升级

不能直接跳过中间的版本直接升级,选择最近的大版本进行升级
比如:12.1想升级到13.0,先升级到12.X最高版,再升级到13.0

#### 数据备份和恢复

- 备份

```powershell
# 备份配置文件
gitlab-ctl backup-etc
ls /etc/gitlab/config_backup/
tar tvf /etc/gitlab/config_backup/gitlab_config_1627267534_2021_07_26.tar
```

```powershell
# 旧版--备份相关配置--GitLab 12.1之前旧的版本
gitlab-rake gitlab:backup:create		# 在任意目录即可备份当前gitlab数据
ll /var/opt/gitlab/backups/
# 新版--备份相关配置--GitLab 12.2之后版本
gitlab-backup create
ll /var/opt/gitlab/backups/	
```

- 恢复

```powershell
# 在web端删除项目（模拟故障）
# 恢复的前提条件：
##--备份和恢复使用的版本要一致
##--还原相关配置文件后，执行gitlab-ctl reconfigure
##--确保gitlab正在运行状态
准备恢复
# 恢复前先停止两个服务
gitlab-ctl stop puma  &&  gitlab-ctl stop sidekiq
# 检验核对版本是否一致
root@ubuntu-200:~# ll /var/opt/gitlab/backups/      |  tail -n1
-rw-------  1 git  git  13680640 Nov 17 12:33 1763385139_2025_11_17_18.5.2_gitlab_backup.tar
新版——恢复
#恢复时指定备份文件的时间部分，不需要指定文件的全名
gitlab-backup restore BACKUP=备份文件名的时间部分_Gitlab版本
yes		# 确认恢复数据
#示例
gitlab-backup restore BACKUP=1763385139_2025_11_17_18.5.2

旧版——恢复
#恢复时指定备份文件的时间部分，不需要指定文件的全名
[root@ubuntu1804 ~]# gitlab-rake gitlab:backup:restore BACKUP=备份文件名的时间部分
yes	# 确认恢复数据
# 恢复后再将之前停止的两个服务启动 （或者重启服务gitlab-ctl restart）
gitlab-ctl start sidekiq && gitlab-ctl start unicorn

善后处理
gitlab-ctl reconfigure  && gitlab-ctl restart  && gitlab-ctl status
# 重启主要是为了启动开始时停止的两个服务
gitlab-rake gitlab:check SANITIZE=true	# 执行全面的 GitLab 系统健康检查
gitlab-rake gitlab:doctor:secrets		# 检查和验证 GitLab 中的密钥和加密数据。
gitlab-ctl tail						  # 查看日志
```



#### 实现Https

创建自签名证书

```powershell
# 创建证书
mkdir -p /etc/gitlab/ssl && cd /etc/gitlab/ssl
openssl genrsa -out gitlab.duan.org.key 2048
openssl req -days 3650 -x509 -sha256 -nodes -newkey rsa:2048 -subj "/C=CN/ST=beijing/L=beijing/O=duan/CN=gitlab.duan.org" -keyout gitlab.duan.org.key -out gitlab.duan.org.crt
# 修改配置文件的如下内容,必选项共4项
vim /etc/gitlab/gitlab.rb
external_url "https://gitlab.duan.org" # 此项必须修改为https，必选项，还原为http时，只修改此行即可
nginx['enable'] = true				   #可选
nginx['client_max_body_size'] = '1000m'	#可选
nginx['redirect_http_to_https'] = true	# 必选项，默认值为false，修改为true，实现http自动301跳转至https，，还原为http时，无需修改此行
nginx['redirect_http_to_https_port'] = 80 #可选,所有请求80的都跳转到443，默认值，可不修改，保持注释状态
nginx['ssl_certificate'] ="/etc/gitlab/ssl/gitlab.duan.org.crt" #必选项
nginx['ssl_certificate_key'] ="/etc/gitlab/ssl/gitlab.duan.org.key" #必选项
# 重新初始化
gitlab-ctl reconfigure
## 服务端与客户端都需要配置hosts文件，这里略过！
# 查看随机密码生成文件内容
cat /etc/gitlab/initial_root_password
```

> 登陆  https://gitlab.duan.org/

解决自签名证书的信任问题

```powershell
# 查看已经生成的自签名证书
root@ubuntu-nfs-200:~# ls /etc/gitlab/ssl/*
/etc/gitlab/ssl/gitlab.duan.org.crt  /etc/gitlab/ssl/gitlab.duan.org.key
# UbuntuCA证书路径
cat gitlab.wang.org.crt >> /etc/ssl/certs/ca-certificates.crt
# 红帽系统证书路径
cat gitlab.wang.org.crt >> /etc/pki/tls/certs/ca-bundle.crt
# 测试
curl -v https://gitlab.duan.org
# 测试 git 仓库连接
git ls-remote https://gitlab.duan.org/myapp/ceshi.git
如果证书有问题，不要想着修复，删除证书，重新生成
```

#### 实现SSH密钥认证

```powershell
# 生成密钥对（无人值守）
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
——————分割线————
ssh-keygen -t rsa     # 手工回车三次
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.202
# 推送公钥（仅第一次需要输入密码）；公钥会被推送到目标服务器的这个位置：/root/.ssh/authorized_keys
ssh 10.0.0.202
```

#### 启动 SSH 代理并添加密钥

- 密钥默认位置是/root/.ssh/目录下，ssh代理默认会在这个位置调取密钥文件；
- 有些人喜欢在这个目录下再次创建文件，或者将密钥放在别的地方，那么就需要将ssh代理指向那个位置；

```powershell
# 启动 SSH 代理
eval "$(ssh-agent -s)"
# 添加 web 目录下的私钥到代理
ssh-add ~/.ssh/web/id_rsa
# 检查已加载的密钥
ssh-add -l
# 测试 SSH 连接到 GitLab
ssh -T git@gitlab.duan.org
```



#### 重置 GitLab 忘记的密码

```powershell
# 进入 GitLab Rails 控制台
gitlab-rails console -e production
# 此步可能比较慢,需要等一段时间
user = User.find_by_username('root')
user.password="duan0714"
user.password_confirmation="duan0714"
user.save
quit
# 浏览器输入：gitlab.duan.org   
```





## Jenkins 8080

#### 安装

```powershell
# 安装openjdk （jenkins运行环境）
apt update && apt -y install openjdk-21-jdk
java -version

# deb 包下载地址国内镜像站点
https://mirrors.aliyun.com/jenkins/debian-stable/
https://mirror.tuna.tsinghua.edu.cn/jenkins/debian-stable/
wget https://mirror.tuna.tsinghua.edu.cn/jenkins/debian-stable/jenkins_2.528.2_all.deb 
apt install ./jenkins_2.528.2_all.deb

# 查看Jenkins配置、服务状态以及其他信息
grep -Ev "#|^$" /usr/lib/systemd/system/jenkins.service
systemctl status jenkins.service
getent passwd jenkins
ps aux|grep java

# 修改hosts文件 (windows 修改hosts文件：略)
echo "10.0.0.201 jenkins.duan.org" >> /etc/hosts

# 登陆
http://jenkins.duan.org:8080/
# 密码：cat /var/lib/jenkins/secrets/initialAdminPassword

# 自定义插件——选择无插件安装——使用admin账户继续——默认URL保存并完成——开始使用Jenkins
修改密码
# 右上角点击用户图像——Security——直接修改，然后保存
# 账户：admin		密码：123123
安装中文插件
# 右上角点击齿轮图标——Plugins——Available plugins——搜索 Chinese——下载 install
# http://jenkins.duan.org:8080/restart		# 重启Jenkins服务（也可以在终端输入指令重启）
```

#### 插件

|              | 索引关键词          | 插件官方名称                           |
| ------------ | ------------------- | -------------------------------------- |
| 中文         | chinese             | **Localization: Chinese (Simplified)** |
| Gitlab       | gitlab              | **GitLab Plugin**                      |
| 邮箱         | email-ext           | **Email Extension Plugin**             |
| 流水线       | pipeline            | **Pipeline**                           |
| 流水线可视化 | pipeline-stage-view | **Pipeline: Stage View Plugin**        |
|              | blue ocean          | **Blue Ocean**                         |
| SSH免密认证  | ssh                 | **SSH Build Agents plugin**            |
| 钉钉         | ding                | **DingTalk**                           |
| 企业微信     | qy                  | **Qy Wechat Notification**             |

```powershell
# 插件安装目录	
ls /var/lib/jenkins/plugins/
```

```powershell
拉取gitlab仓库代码(第45天第四个视频)
# 新建任务——任务名称——自由风格——确定
# configuration （配置）——源码管理—— Git —— 输入URL，这里我先用https协议：https://gitlab.duan.org/myapp/ceshi.git—— 指定拉取分支
# 添加凭据认证Credentials —— 添加 —— 类型默认，若是SSH就选SSH类型 —— 添加gitlab的用户和密码 —— 然后ID和描述要具有意义，使阅读者可以知道这个凭据的准确信息；
# Buld Steps模块增加构建步骤——执行shell——输入指令——保存save
执行立即构建，会看到对应的目录文件中拉取到了gitlab分支文件
root@ubuntu-201:/usr/local/share# cd /var/lib/jenkins/workspace/freestyle-hello
root@ubuntu-201:/var/lib/jenkins/workspace/freestyle-hello# ls
test
于是在执行shell中添加指令时，可以对拉取的文件进行操作，比如对java文件进行编译安装等，部署服务；
```

#### 构建后通知

##### 邮件通知

##### 钉钉通知

##### 微信通知

#### Gitlab 与  Jenkins 设置ssh密钥认证

- **GitLab中的公钥**
  - **密钥对来源**：**Jenkins服务器生成**
  - **添加位置**：GitLab项目 → Settings → Repository → Deploy Keys
  - **用途**：让Jenkins服务器能够拉取GitLab的代码
- **Jenkins中的私钥**
  - **密钥对来源**：**Jenkins服务器生成**
  - **添加位置**：Jenkins → Manage Jenkins → Credentials
  - **用途**：让Jenkins能够SSH连接到目标服务器（10.0.0.202/203）进行部署

```powershell
假设Gitlab服务器10.0.0.200	；	Jenkins服务器10.0.0.201
# 在Jenkins服务器中创建密钥对
mkdir -p /etc/ssh/hosts/10.0.0.{200..203}
ssh-keygen -t rsa -b 4096 -f /etc/ssh/hosts/10.0.0.200/id_rsa -N ""
# 查看并复制私钥
cat /etc/ssh/hosts/10.0.0.200/id_rsa
# 查看并复制公钥
cat /etc/ssh/hosts/10.0.0.200/id_rsa.pub
# 在 GitLab 服务器上测试自身连接
ssh -T git@localhost
```

#### 自动化构建

```powershell
定时构建
# 示例：在每个小时的一个随机分钟执行一次
H * * * *
# 示例：每10分钟执行一次，但起始点是随机的（比如从第7分钟开始：:07, :17, :27, :37, :47, :57）
H/10 * * * *
轮询SCM
# 触发式构建，比如添加gitlab URL源，间隔设为*****每分钟，那么每分钟都会查看远程仓库是否发生变更，若发生变更则触发构建
触发器 Webhook
# 构建配置中Triggers——勾选“触发远程构建”——弹出该路径显示（复制记录下来）
JENKINS_URL/job/webhook/build?token=TOKEN_NAME
# 然后自定义身份验证令牌，比如我常用的：123123
# 系统管理中的Jenkins location 查看具体的URL
http://jenkins.duan.org:8080/
# tocken=后面是构建配置中自定义的身份验证令牌
http://jenkins.duan.org:8080/job/webhook/build?token=123123
# 需要账户认证，在设置页面创建一个普通用户，然后并入该URL中，在其他主机测试（记得添加域名解析！）
curl http://duan:123123@jenkins.duan.org:8080/job/webhook/build?token=123123
# 这种密码明文显示不安全；登陆duan这个账号，点击用户头像——点击Security——添加Token
# 然后输入一个name（名字不重要）——随后生成一段字符串（这个字符串可以代表duan这个用户）
1109109a3757fc0e172b69bdb42ec6e592
# 这个字符串代替duan的密码
curl http://duan:1109109a3757fc0e172b69bdb42ec6e592@jenkins.duan.org:8080/job/webhook/build?token=123123 
基于标签变化触发
gitlab页面——设置——网络——出站请求——勾选“允许来自webhooks和集成对本地网络的请求”——保存
http://duan:1109109a3757fc0e172b69bdb42ec6e592@jenkins.duan.org:8080/job/webhook/build?token=123123 
gitlab页面——设置——Webhooks——添加新的Webhooks——粘贴上面的URL——触发来源：标签推送事件——取消SSL验证——添加webhooks  ；创建成功后——测试——标签推送事件——弹出：Hook executed successfully:HTTP 201
Jenkins服务器终端；
echo "看见我就说明成功了！" >> test
git add test
git commit -m test
git tag v1.1
git push origin master
git push --tags
# 这里说明一下：一旦推送新的标签，那么当前远程仓库中的文件会被Jenkins中的shll程序执行。
基于标签变化触发(需要Gitlab插件)
# 构建配置中——Triggers——取消构选 “触发远程构建”
# 构建配置中——Triggers——勾选 Build when …… —— 复制这个选项的URL ——高级——生成密钥
http://jenkins.duan.org:8080/project/webhook
65e0c4392ac6c89bb8dbd8ecd44a075b
# 在gitlab web界面重新添加一个webhooks URL路径，操作与上面的一样以及出站请求设置！
Jenkins服务器终端；
echo "看见我就说明成功了！" >> test
git add test
git commit -m test
git tag v1.1
git push origin master
git push --tags
```

![image-20251120093932234](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251120093932234.png)

#### 多任务构建

- 二选一
- 任务配置中——构建后操作——构建其他工程；
- 任务配置中——Triggers——其他工程构建后触发；

#### 部署若依项目

准备工作

```powershell
# 重新建立远程仓库（在gitlab服务器仓库中进行操作）
git remote remove origin 
git remote add origin https://gitlab.duan.org/myapp/ruoyi.git
# 查看当前状态，创建新用户，推送项目代码
git status
git checkout -b test
git add .
git commit  -m RuoYi/
git push origin ceshi

# Jenkins服务器下载项目代码（指定分支ceshi）
# 因为用的是https协议，就提前下载；如果是ssh协议，可以通过指令无人值守！
apt install git -y
git clone -b test https://gitlab.duan.org/myapp/ruoyi.git
因为开始用的是https协议导致后续无法做无人值守的脚本，又改回ssh（这也是生产中的主流）
git clone -b test git@gitlab.duan.org:myapp/ruoyi.git
权限问题，新建一个文件夹用来给后端服务器存放代码文件
mkdir -p  /data/jenkins
mv /var/lib/jenkins/workspace/ruoyi  /data/jenkins
```

```powershell
Jenkins
# 创建目录
mkdir -p /etc/ssh/hosts/10.0.0.{200..203}
# 生成密钥对
ssh-keygen -t rsa -b 4096 -f /etc/ssh/hosts/10.0.0.202/id_rsa -N ""
ssh-keygen -t rsa -b 4096 -f /etc/ssh/hosts/10.0.0.203/id_rsa -N ""
# 推送公钥（仅第一次需要输入密码）；公钥会被推送到目标服务器的这个位置：/root/.ssh/authorized_keys
ssh-copy-id -i /etc/ssh/hosts/10.0.0.202/id_rsa.pub root@10.0.0.202
ssh-copy-id -i /etc/ssh/hosts/10.0.0.203/id_rsa.pub root@10.0.0.203
# 使用密钥登录（测试）
ssh -i /etc/ssh/hosts/10.0.0.202/id_rsa root@10.0.0.202
ssh -i /etc/ssh/hosts/10.0.0.203/id_rsa root@10.0.0.203
# 授予Jenkins使用密钥的权限
这个很重要，平时root用惯了，突然回归平民用户有些不适应了！
sudo chmod 600 /etc/ssh/hosts/10.0.0.203/id_rsa
sudo chmod 600 /etc/ssh/hosts/10.0.0.202/id_rsa
sudo chown jenkins:jenkins /etc/ssh/hosts/10.0.0.203/id_rsa
sudo chown jenkins:jenkins /etc/ssh/hosts/10.0.0.202/id_rsa
```

```powershell
#!/bin/bash
set -e 

echo "数据库服务器部署"
scp -r -i /etc/ssh/hosts/10.0.0.203/id_rsa /data/jenkins/RuoYi root@10.0.0.203:/data/
ssh -i /etc/ssh/hosts/10.0.0.203/id_rsa root@10.0.0.203 << 'REMOTE_SCRIPT'
apt update
apt install -y mysql-server
sed -i '/127.0.0.1/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
mysql -e "CREATE DATABASE IF NOT EXISTS ry;"
mysql -e "create user if not exists ry@'%' identified by '123456';"
mysql -e "grant all on ry.* to ry@'%';"
mysql ry < /data/RuoYi/sql/ry_20240112.sql
mysql ry < /data/RuoYi/sql/quartz.sql
REMOTE_SCRIPT

echo "应用服务器部署"
scp -r -i /etc/ssh/hosts/10.0.0.202/id_rsa /data/jenkins/RuoYi root@10.0.0.202:/data/
ssh -i /etc/ssh/hosts/10.0.0.202/id_rsa root@10.0.0.202 << 'REMOTE_SCRIPT'
echo "10.0.0.203 mysql.duan.org" >> /etc/hosts
echo "10.0.0.202 www.duan.org" >> /etc/hosts
apt update && apt -y install maven
cd /data/RuoYi && mvn clean package -Dmaven.test.skip=true
echo "时间比较长，耐心等待！"
mkdir /srv
cp /data/RuoYi/ry.sh /srv/
cp /data/RuoYi/ruoyi-admin/target/ruoyi-admin.jar /srv
chmod +x /srv/ry.sh

echo "创建systemd服务文件"
cat > /lib/systemd/system/ruoyi.service << 'SYSTEMD_SERVICE'
[Unit]
Description=Ruoyi Application
After=network.target

[Service]
Type=forking
ExecStart=/srv/ry.sh start
ExecStop=/srv/ry.sh stop
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
User=root
Group=root

[Install]
WantedBy=multi-user.target
SYSTEMD_SERVICE
systemctl daemon-reload &&  systemctl start  ruoyi
REMOTE_SCRIPT
```

#### 基于 SSH 协议实现 Jenkins 分布式

```powershell
# 环境说明
Jenkins服务器——ubuntu2404——10.0.0.201
Jenkins-agent服务器——ubuntu2404——10.0.0.202

# 准备工作（10.0.0.201）
# 创建目录
mkdir -p /etc/ssh/hosts/10.0.0202
# 生成密钥对
ssh-keygen -t rsa -b 4096 -f /etc/ssh/hosts/10.0.0.202/id_rsa -N ""
# 推送公钥（仅第一次需要输入密码）；公钥会被推送到目标服务器的这个位置：/root/.ssh/authorized_keys
ssh-copy-id -i /etc/ssh/hosts/10.0.0.202/id_rsa.pub root@10.0.0.202
# 使用密钥登录（测试）
ssh -i /etc/ssh/hosts/10.0.0.202/id_rsa root@10.0.0.202
# 授予Jenkins使用密钥的权限
这个很重要，平时root用惯了，突然回归平民用户有些不适应了！
sudo chmod 600 /etc/ssh/hosts/10.0.0.202/id_rsa
sudo chown jenkins:jenkins /etc/ssh/hosts/10.0.0.202/id_rsa
# 在 10.0.0.201 上执行，测试是否能够免密登录
sudo -u jenkins ssh jenkins-agent@10.0.0.202

#	登录 Jenkins Web 界面 (http://jenkins.duan.org:8080)
# 下载ssh插件，这个很重要，具体操作略过！
# Master 节点配置ssh连接的自动信任主机
#	方法一：web界面系统管理的全局安全配置
#	方法二：修改agent 上面ssh客户端配置文件
vi /etc/ssh/ssh_config
#StrictHostKeyChecking ask
StrictHostKeyChecking no

# 添加节点
#	点击 "系统管理" → "节点管理"
#	点击 "新建节点"
#	节点名称输入：test-agent-202 (使用一个有意义的名称)
#	选择 "固定节点"，点击 "创建"
#	配置节点参数
#	名称：test-agent-202		# 节点的唯一标识
#	描述：测试不重要，有意义即可！
#	执行器数量：2				 # 根据 Agent 服务器的 CPU 核心数设置（nproc）
#	远程工作目录：				 # Agent 用户的家目录
#	标签：



agent服务器安装java等环境
注意： Jenkins Agent 和 Master 的环境尽可能一致，包括软件的版本，路径，脚本，ssh key验证,域
名解析等
apt update && apt install -y openjdk-21-jdk
```

#### 构建容器化任务

- Gitlab服务器——10.0.0.200
- harbor服务器——172.24.0.253    （magedu     Magedu123）
- Jenkins服务器——10.0.0.201
- 部署容器服务器——10.0.0.202

```powershell
10.0.0.200
echo "172.24.0.253 harbor.wang.org" >> /etc/hosts
10.0.0.201
# ssh密钥认证参考上面的笔记
apt update && apt install -y docker.io
vi /etc/docker/daemon.json 
    {
      "registry-mirrors": ["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"],
      "insecure-registries": ["harbor.wang.org"]
     }
systemctl  restart docker
docker info
# 实际生产中配置DNS域名解析，在这里是做实验就这样搞了！
echo "172.24.0.253 harbor.wang.org" >> /etc/hosts
vi /lib/systemd/system/jenkins.service
User=jenkins
Group=jenkins
将上面两行参数注释掉，Jenkins用户就能拥有root权限运行，但是这样好吗？这样不好！
# 将Jenkins用户加入docker组中
getent group docker			# 查看docker组
sudo groupadd docker		# 创建docker组 （如果没有！）
sudo usermod -aG docker jenkins		# 将jenkins用户添加到docker组
getent group docker			# 验证组是否创建成功
# 用户变更生效，如果是交互用户则重新登陆；如果是服务则需要重启；
systemctl  restart jenkins

10.0.0.202
apt update && apt install -y docker.io
scp 10.0.0.201:/etc/docker/daemon.json /etc/docker/
systemctl  restart docker
docker info
echo "172.24.0.253 harbor.wang.org" >> /etc/hosts
```

Jenkins加入docker组，权限不生效，则彻底重建Docker组权限

```powershell
# 完全移除并重新添加jenkins用户到docker组
sudo gpasswd -a jenkins docker
sudo usermod -aG docker jenkins
# 重新创建docker.sock（谨慎操作）
sudo systemctl stop docker
sudo rm -f /var/run/docker.sock
sudo systemctl start docker
# 确认新的socket权限
ls -la /var/run/docker.sock
# 重启Jenkins
sudo systemctl restart jenkins
# 测试
sudo -u jenkins docker ps
```

部署脚本

```powershell
#!/bin/bash

APP=hello_little_baby
HARBOR=harbor.wang.org

HOST_LIST="
10.0.0.210
10.0.0.211
"

PORT=80

#mvn clean package -Dmaven.test.skip=true
#docker build -t $HARBOR/example/$APP:$BUILD_NUMBER .
docker build -t $HARBOR/example/$APP:$BUILD_NUMBER -f Dockerfile-multistages .
docker login -u magedu -p Magedu123 $HARBOR
docker push $HARBOR/example/$APP:$BUILD_NUMBER

for host in $HOST_LIST;do
    ssh -i /etc/ssh/hosts/10.0.0.202/id_rsa  root@$host "docker rm -f $APP && docker run -d  --restart always --name $APP  -p $PORT:8888 $HARBOR/example/$APP:$BUILD_NUMBER"  
    #docker -H $host rm -f $APP && docker -H $host run -d  --restart always --name $APP  -p $PORT:8888 $HARBOR/example/$APP:$BUILD_NUMBER
    #docker -H ssh://root@$host rm -f $APP && docker -H ssh://root@$host run -d  --restart always --name $APP  -p $PORT:8888 $HARBOR/example/$APP:$BUILD_NUMBER
done
```

#### Jenkins 分布式部署

- harbor 仓库：10.0.0.147
- Gitlab 仓库：10.0.0.200
- Jenkins-server：10.0.0.201
- Jenkins-agent01：10.0.0.202
- Jenkins-agent02：10.0.0.203
- 后端服务器a：10.0.0.210
- 后端服务器a：10.0.0.211

```powershell
Jenkins 执行器数量配置
# 系统管理——系统配置——执行数量=	Jenkins服务器CPU核数=nproc
添加节点
# 系统管理——主目录——复制主目录路径
/var/lib/jenkins
# 系统管理——节点和云管理——+New Node—— Jenkins-agent1-ssh —— 固定节点 —— create
# executors数量=nproc
# 远程工作目录粘贴上面的内容
# 标签——Java——这个比较重要，Jenkins是根据标签不同分配部署任务
# 用法——我这里选的是'只允许运行绑定到这台机器的job'
# Launch method —— Launch agents via SSH
# 添加主机ip——添加凭据（用户密码 或 ssh）ID（相当于描述，要有意义）
# Host key —— 选择'Non verifying ……' （选这个是为了避免yes的输入）
### 扩展： /root/.ssh/known_hosts文件中记录有关于连接主机的信息
# 在任务配置中——GitLub Connection——勾选'限制项目运行节点'——在标签表达式中填写：java
标签带有java的节点主机受理这个标签java的构建任务
# 完成后，还需要在节点主机上下载运行环境：
apt update && apt install openjdk-21-jre -y			# 这里jre就够用了
节点主机与主节点主机环境尽量保持一致
# apt——下载必要的安装包；
# scp——传送代码脚本等文件；
# ssh-copy-id密钥认证；
# 域名解析；
# 添加公钥到gitlab网页的ssh keys
# 自签名证书添加；
apt install maven git docker.io -y
mkdir -p  /var/lib/jenkins
scp -r /var/lib/jenkins/workspace   10.0.0.202:/var/lib/jenkins/
scp -r /var/lib/jenkins/workspace   10.0.0.203:/var/lib/jenkins/
cat ~/.ssh/id_rsa.pub
cat gitlab.wang.org.crt >> /etc/ssl/certs/ca-certificates.crt	#添加harbor页面的认证证书
ssh -T git@gitlab.duan.org		# 添加公钥到gitlab网页ssh keys后测试连接
```

```powershell
# 电脑浏览器域名添加
10.0.0.147 harbor.duan.org
10.0.0.200 gitlab.duan.org
10.0.0.201 jenkins.duan.org
# SSH 密钥认证
10.0.0.147
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.202
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.203
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.210
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.211
10.0.0.200
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.201
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.202
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.203
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.210
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.0.0.211
10.0.0.201
ssh-keygen -t rsa
for host in 10.0.0.{202..203,210..211}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub root@$host
done
# 域名添加
10.0.0.147
cat >> /etc/hosts << eof
10.0.0.147 harbor.duan.org
10.0.0.200 gitlab.duan.org
10.0.0.201 jenkins.duan.org
eof
scp /etc/hosts 10.0.0.{200..203,210..211}:/etc/hosts

```

程序代码部署

- 自由风格：执行shell 或 脚本文件 ；默认Jenkins支持
- Pipline：Jenkins pipeline 语法；需要Jenkins插件

### SonarQube

#### 安装服务端

- 尽量用LTA版（长期稳定版）；
- 官方LTA版说明：https://www.sonarsource.com/products/sonarqube/downloads/historical-downloads/
- 以SonarQube 9.9 LTA为例；
- 数据库要求：PostgreSQL 的版本12-15
- 软件依赖：OpenJDK 17 或 Oracle JDK 17 （不低于**JDK 17**）
- 网络协议/端口：Http协议；9000（web界面和api）9001（内部通信，可选）

硬件要求

| 组件 | 最小要求 | 推荐要求 | 说明                 |
| :--- | :------- | :------- | :------------------- |
| CPU  | 2核      | 4核+     | 64位架构             |
| 内存 | 4GB      | 8GB+     | 小型团队至少8GB      |
| 存储 | 10GB     | 50GB+    | SSD推荐，保证快速I/O |
| 网络 | 1Gbps    | 1Gbps+   | 稳定的网络连接       |

| 参数               | 最小值 | 检查命令                  | 说明                 |
| :----------------- | :----- | :------------------------ | :------------------- |
| `vm.max_map_count` | 524288 | `sysctl vm.max_map_count` | 虚拟内存映射区域数量 |
| `fs.file-max`      | 131072 | `sysctl fs.file-max`      | 系统最大文件打开数   |
| 用户文件描述符     | 131072 | `ulimit -n`               | 单用户最大文件打开数 |
| 用户线程数         | 8192   | `ulimit -u`               | 单用户最大线程数     |

```powershell
# 编辑系统配置文件 （内核参数）
vim /etc/sysctl.conf
vm.max_map_count=524288
fs.file-max=131072
sudo sysctl -p					# 立即生效
# 编辑限制配置文件（用户限制）
sudo vim /etc/security/limits.conf
sonarqube_user - nofile 131072
sonarqube_user - nproc 8192

SonarQube 9.9 LTA 不支持Ubuntu24.04内置的PostGreSQL-16，支持Ubuntu22.04
SonarQube 9.9 不支持JDK 21

安装依赖
# 安装 OpenJDK 17 (SonarQube 9.9+ LTS 要求)
sudo apt install openjdk-17-jdk -y
java -version
# 安装 PostgreSQL
sudo apt install postgresql  -y
apt list postgresql
systemctl status postgresql

配置postgresql
# 修改监听地址支持远程连接（如果sonarqube和PostgreSQL在同一台主机，可不做修改）
vim /etc/postgresql/16/main/postgresql.conf
listen_addresses = '*' 或者 '0.0.0.0'
#开启远程访问（如果sonarqube和PostgreSQL在同一台主机，可不做修改）
vim /etc/postgresql/16/main/pg_hba.conf
# IPv4 local connections:
host all all 127.0.0.1/32 scram-sha-256
host all all 0.0.0.0/0 scram-sha-256 # 新

# 查看是有sonarqube用户
getent passwd 
# 创建SonarQube用户（如果没有！）
useradd -s /bin/bash -m sonarqube # Ubuntu使用useradd创建用户时默认使用/bin/sh,并且不创建家目录
#使用postgres用户登录（PostgresSQL安装后会自动创建postgres用户）
su - postgres
psql -U postgres	# 登录postgresql数据库
CREATE USER sonarqube WITH ENCRYPTED PASSWORD '123123';		# 创建用户和数据库并授权
CREATE DATABASE sonarqube OWNER sonarqube;					# 创建数据库
\l										# 查看所有数据库；相当于MySQL中 show databases;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;	# 授权

# 下载sonarqube9.9版本
wget -P /usr/local/srchttps://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip
unzip sonarqube-9.9.8.100196.zip
mv sonarqube-9.9.8.100196 /usr/local/
cd /usr/local/  && ls
ln -s sonarqube-9.9.8.100196 sonarqube			# 创建软链接
chown -R sonarqube:sonarqube /usr/local/sonarqube/

# 修改SonarQube配置用于连接postgresql数据库（改了三行数据！）
vim /usr/local/sonarqube/conf/sonar.properties
# 修改连接postgresql数据库的账号和密码,和前面的配置必须匹配
sonar.jdbc.username=sonarqube
sonar.jdbc.password=123123
# 修改数据库相关的信息，这里必须和此前配置的postgresql内容相匹配，其中localhost为DB服务器的地址，而sonarqube为数据库名称
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
# 默认配置如下，必须删除   ?currentSchema=my_schema
##sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube?currentSchema=my_schema

启动 sonarqube
注意:SonarQube 需要调用 Elasticsearch，而且默认需要使用普通用户启动，如果以root启动会报错
如果以root用户启动，后续用sonarqube用户启动也会报错
# 切换到sonarqubee用户，以该身份启动
su - sonarqube
# 启动方式一
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh start
# 启动方式二（借助sonarqube用户启动）
su - sonarqube -c '/usr/local/sonarqube/bin/linux-x86-64/sonar.sh start'
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh status	# 查看状态
ss -tunlp 											# 查看是否9000/tcp端口
cat /usr/local/sonarqube/logs/sonar.log				   # 查看日志

创建 service 文件
# 先停止sonarqube
su - sonarqube
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh stop
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh status
exit
# 创建service文件
cat > /lib/systemd/system/sonarqube.service << eof
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=simple
User=sonarqube
Group=sonarqube
PermissionsStartOnly=true
ExecStart=/usr/bin/nohup /usr/bin/java -Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true -jar /usr/local/sonarqube/lib/sonar-application-9.9.8.100196.jar
StandardOutput=syslog
LimitNOFILE=131072
LimitNPROC=8192
TimeoutStartSec=5
Restart=always
[Install]
WantedBy=multi-user.target
eof

启动 SonarQube
sudo systemctl daemon-reload
sudo systemctl start sonarqube && ss -tunlp | grep 9000
sudo systemctl status sonarqube

在浏览器中访问 http://sonarqube服务器IP:9000，登录后即可看到代码分析报告。
修改默认密码：首次登录 SonarQube 后立即修改 admin 密码。
默认用户名和密码都是 admin
```

安装中文插件

> 在 Marketplace 点击我已经了解风险，然后才能对各插件进行下载

![image-20251122111257843](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251122111257843.png)

重启服务才能生效，安装后界面

![image-20251122111404604](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251122111404604.png)

#### 安装客户端

> 在代码检测主机上部署上安装客户端 sonar-scanner （这里是Jenkins服务器）
>
> 官方网址：https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
>
> 下载链接：https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/

```powershell
# 下载安装、解压
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-7.3.0.5189-linux-x64.zip
unzip sonar-scanner-cli-7.3.0.5189-linux-x64.zip  -d /usr/local/ 
cd /usr/local  && ls
ln -s sonar-scanner-7.3.0.5189-linux-x64/ sonar-scanner
# 说明：服务本身自带java 17版本
root@ubuntu-201:/usr/local/sonar-scanner# ls jre/bin/java 
jre/bin/java
root@ubuntu-201:/usr/local/sonar-scanner# jre/bin/java -version
openjdk version "17.0.15" 2025-04-15
OpenJDK Runtime Environment Temurin-17.0.15+6 (build 17.0.15+6)
OpenJDK 64-Bit Server VM Temurin-17.0.15+6 (build 17.0.15+6, mixed mode, sharing)
# 添加域名解析 （记得电脑的hosts文件也要添加）
echo "10.0.0.100 sonarqube.duan.org" >> /etc/hosts && cat /etc/hosts
————安装方法一————
# 配置sonar-scanner连接sonarqube服务器
vim /usr/local/sonar-scanner/conf/sonar-scanner.properties
#指向sonarqube服务器的地址和端口
sonar.host.url=http://sonarqube.duan.org:9000
sonar.sourceEncoding=UTF-8
————安装方法二（推荐这个方式）————
# 浏览器登陆 sonarqube.duan.org:9000 
# 配置——权限——用户——创建用户——自定义登陆、名称、邮箱、密码——点击创建
# 默认加入sonar-users组中，而这个组有执行分析的权限
# 生成令牌/更新令牌——  squ_385e75be376b8a725bacb70719f860e0b5b23e3f  —— 完成
cat >> /usr/local/sonar-scanner/conf/sonar-scanner.properties << eof
sonar.host.url=http://sonarqube.duan.org:9000
sonar.login=squ_385e75be376b8a725bacb70719f860e0b5b23e3f
eof
```

———— 使用 SonarScanner 进行代码检测 ————

```powershell
# 准备代码项目 （如果没有的话！）
git clone 代码URL地址

方法一
# 创建 sonar-project.properties 文件，放置Java代码文件目录中
cat sonar-project.properties
#项目的唯一标识；键值 (projectKey) 必须唯一
sonar.projectKey=Ruoyi
#项目的名称,用于显示在 sonarqube web 界面
sonar.projectName=Ruoyi
#项目版本
sonar.projectVersion=1.0
#项目源码所在目录
sonar.sources=.
#排除扫描的目录
sonar.exclusions=**/test/**,**/target/**
#项目源码编译生成的二进制文件路径，./target默认没有会报错，可以手动创建
#sonar.java.binaries=./target
sonar.java.binaries=.
#编程语言
sonar.language=java
#编码格式
sonar.sourceEncoding=UTF-8
方法二
# 通过参数代替文件（主要是两个参数，一个定义唯一标识；一个指java路径）；示例：
sonar-scanner -Dsonar.projectKey=Ruoyi -Dsonar.java.binaries=.

# 扫描 Java 项目
# 方法一：使用绝对路径
cd /root/Ruoyi								# 进入代码文件目录
/usr/local/sonar-scanner/bin/sonar-scanner
# 方法二：创建软链接，必须将sonar-scanner添加到系统PATH中
cd /root/Ruoyi
ln -s/usr/local/sonar-scanner/bin/sonar-scanner  sonar-scanner 
echo "export PATH=$PATH:/usr/local/sonar-scanner/bin" >> ~/.bashrc
source ~/.bashrc

# 进入sonar网页项目首页，就会看到项目代码质量检测报告。
sonarqube.duan.org:9000
```

![image-20251122113932289](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251122113932289.png)

### Jenkins集成项目

- Gitlab 服务器——10.0.0.200
- Jenkins 服务器——10.0.0.201
- Sonar Scanner——10.0.0.201
- Sonar Qube服务器——10.0.0.100
- Harbor服务器——10.0.0.147
- 后端服务器——10.0.0.101 、10.0.0.102
- 以上服务器都必须安装docker服务

#### 准备工作

```powershell
# 添加域名
cat /etc/hosts
10.0.0.200 gitlab.duan.org
10.0.0.201 jenkins.duan.org
172.24.0.253 harbor.wang.org
10.0.0.147 harbor.duan.org
10.0.0.100 sonarqube.duan.org
# 推送域名文件
for ip in 147 201 100 101 102; do
    scp /etc/hosts 10.0.0.$ip:/etc/hosts
done
# Jenkins——ssh免密认证
ssh-keygen -t rsa
for host in 10.0.0.{147,200,100,101,102}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
done
# Gitlab——ssh免密认证
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@10.0.0.201
# Sonar Qube——ssh免密认证
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@10.0.0.201
# Harbor——ssh免密认证
ssh-keygen -t rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@10.0.0.201
# 后端服务器——ssh免密认证
ssh-keygen -t rsa
for host in 10.0.0.{147,200}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
done
# 后端服务器——ssh免密认证
ssh-keygen -t rsa
for host in 10.0.0.{147,200}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
done

问题故障：gitlab、harbor、socarqube、Jenkins都没有问题，但是docker run一直执行不下去，最后发现是权限的问题！
Jenkins服务器中对root用户进行的ssh免密认证，但是Jenkins用户没有做到ssh免密认证，所以指令执行不下去！
sudo -u jenkins bash
ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
ssh-copy-id -i /var/lib/jenkins/.ssh/id_rsa.pub root@10.0.0.101
ssh-copy-id -i /var/lib/jenkins/.ssh/id_rsa.pub root@10.0.0.102
```

##### 关闭 SSH 连接时的 yes/no 询问（可选）

```powershell
# 方法一：通过添加参数
for host in 10.0.0.{201,100,101,102}; do
    ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
done
# 方法二：修改 SSH 配置文件（永久生效）
echo "StrictHostKeyChecking no" >> ~/.ssh/config
```

#### Jenkins服务器

```powershell
admin
123123
docker login -u admin -p 123123 harbor.duan.org

# 安装Harbor步骤参考Harbor试验笔记
apt update && apt -y install docker.io
cat /etc/docker/daemon.json
    {
      "registry-mirrors": ["https://docker.m.daocloud.io","https://docker.1panel.live","https://docker.1ms.run","https://docker.xuanyuan.me"],
      "insecure-registries": ["harbor.duan.org"]
     }
docker info && systemctl start docker && systemctl status docker  
for host in 10.0.0.{147,200,101,102}; do
    scp /etc/docker/daemon.json -o StrictHostKeyChecking=no root@$host:/etc/docker/daemon.json
done

# 设置一个sonarqube回调Jenkins的webhook
# 在sonarqube网页配置——配置——webhook——创建
http://jenkins.duan.org:8080/sonarqube-wehook		# http://域名:端口/固定格式
# 创建一个随机密钥，不用记住！
[root@ubuntu2204 ~]#openssl rand -base64 21
Lltn9D3lW9ItpWYl0A41ANA/zL4z

# Jenkins服务器下载插件SonarQube Scanner
# 添加Jenkins到sonarqube的凭据（之前是通过/usr/local/sonar-scanner/conf/sonar-scanner.properties文件做服务器连接）
# sonarqube生成的令牌（参考上上面的笔记）：squ_385e75be376b8a725bacb70719f860e0b5b23e3f

# Jenkins网页——系统管理——system——SonarQube servers ——SonarQube installations
# name：SonarQube-Server  token：上面添加到sonarqube的凭据名称

# 打开企业微信软件——消息推送（之前创建的机器人，没有则参考之前的笔记）——复制该机器人的webhook
https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=95a38383-fec6-4ea8-a341-39141e3b05d7

# 首次开始流水线构建任务后，会自动生成触发器地址，复制这个地址
http://jenkins.duan.org:8080/project/pipeline-spring-sonar
# 复制到gitlab对应项目的webhooks中，令牌就是脚本中的令牌

# 切换到 jenkins 用户
sudo -u jenkins bash
# 生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa -N ""
# 复制公钥到目标服务器
ssh-copy-id -i /var/lib/jenkins/.ssh/id_rsa.pub root@10.0.0.101
ssh-copy-id -i /var/lib/jenkins/.ssh/id_rsa.pub root@10.0.0.102
```

创建Pipeline风格的任务

- 添加两个agent服务器

  - J-agent1-211服务器：10.0.0.211  对应的标签是：java
  - J-agent-212服务器：10.0.0.212  对应的标签是：go

- 由于目前主流都是SSH，所以本次试验没有加入JNLP的连接方式；

- 下面pipeline脚本部署的标签是java和go ，那么构建任务时会造成两个节点服务器重复部署的冲突；

  - 方案一：修改脚本指定最后执行docker run指令是哪个节点服务器；
  - 方案二：修改系统管理中的节点标签，使一个构建任务对应一个节点服务器；

  

```powershell
pipeline {
    agent none
    
    environment {
        codeRepo = "http://gitlab.duan.org/myapp/spring-boot-helloworld.git"
        credential = 'gitlab-root-password'
        harborServer = 'harbor.duan.org'
        projectName = 'spring-boot-helloworld'
        imageUrl = "${harborServer}/example/${projectName}"
        imageTag = "${BUILD_ID}"
    }
    
    triggers {
        gitlab(
            triggerOnPush: true,
            acceptMergeRequestOnSuccess: true,
            triggerOnMergeRequest: true,
            branchFilterType: 'All',
            addVoteOnMergeRequest: true,
            secretToken: '73f7b76f91ee30b1cc83a9c7d08c0021'
        )
    }
    
    stages {
        stage('Source') {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                git branch: 'main', credentialsId: "${credential}", url: "${codeRepo}"
                stash name: 'source', includes: '**'
            }
        }
        
        stage('Test') {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                unstash 'source'
                sh 'mvn test'
            }
        }
        
        stage("SonarQube Analysis") {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                unstash 'source'
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage("Quality Gate") {
            agent any  // 任意可用节点
            steps {
                script {
                    try {
                        timeout(time: 15, unit: 'SECONDS') {
                            waitForQualityGate abortPipeline: true
                        }
                    } catch (Exception e) {
                        echo "质量门检查超时，但分析已成功。继续执行..."
                        currentBuild.result = 'SUCCESS'
                    }
                }
            }
        }
        
        stage('Build') {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                unstash 'source'
                sh 'mvn -Dmaven.test.skip=true clean package'
                stash name: 'target', includes: 'target/**'
            }
        }
        
        stage('Build Docker Image') {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                unstash 'source'
                unstash 'target'
                sh 'docker image build . -t "${imageUrl}:${imageTag}"'
            }
        }
        
        stage('Push Docker Image') {
            agent {
                label 'java || go'  // 在java或go标签节点执行
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'harbor-admin',
                    passwordVariable: 'harborPassword',
                    usernameVariable: 'harborUserName'
                )]) {
                    sh "docker login -u ${harborUserName} -p ${harborPassword} ${harborServer}"
                    sh "docker image push ${imageUrl}:${imageTag}"
                }
            }
        }
        
        stage('Run Docker') {
            agent any  // 任意节点执行部署命令
            steps {
                sh 'ssh -o StrictHostKeyChecking=no root@10.0.0.101 "docker run --name ${projectName} -p 80:8888 -d ${imageUrl}:${imageTag}"'
                sh 'ssh -o StrictHostKeyChecking=no root@10.0.0.102 "docker run --name ${projectName} -p 80:8888 -d ${imageUrl}:${imageTag}"'
            }
        }
    }
    
    post {
        success {
            mail to: '17777055510@163.com',
            subject: "Status of pipeline: ${currentBuild.fullDisplayName}",
            body: "${env.BUILD_URL} has result ${currentBuild.result}"
        }
        failure {
            qyWechatNotification failNotify: true,
            webhookUrl: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=95a38383-fec6-4ea8-a341-39141e3b05d7'
        }
    }
}
```



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

![image-20251123143638325](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251123143638325.png)

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
> 首页 Alert —— 点击 Silence —— **Matchers**设置匹配规则 —— **Creator**执行人 —— **Comment** 说明 —— create
>
> 在 Silence 板块中可以看到 设置静默的具体信息 ，点击 Expire 进行取消静默操作

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

![image-20251126165346179](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251126165346179.png)

![image-20251126165514292](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251126165514292.png)

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

![image-20251127174220318](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251127174220318.png)

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

![image-20251127184146540](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251127184146540.png)

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



#### cAdvisor （容器顾问）

- 对于物理主机可以在其上安装Node Exporter实现监控；对于docker类型的容器应用，可以通过 cAdvisor 的方式来进行监控。
- 是 Google 开源的一个容器监控工具，基于Go语言开发，它以守护进程方式运行；
- 在Kubernetes-v1.10之前通过启动参数–cadvisor-port可以定义cAdvisor对外提供服务的端口，默认为4194；
- 新版本默认对外暴露的端口号：8080

#### Prometheus 本地存储



#### 远程存储 VictoriaMetrics

- 下载地址：[Releases · VictoriaMetrics/VictoriaMetrics](https://github.com/VictoriaMetrics/VictoriaMetrics/releases)

二进制单机部署

```powershell
wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.130.0/victoria-metrics-darwin-amd64-v1.130.0.tar.gz

```

 

## 若依服务项目

#### 单体架构

数据库服务器——10.0.0.203

```powershell
## 下载资源
git clone https://gitee.com/y_project/RuoYi.git
## 查看
[root@ubuntu2204 ~]#ls
bin  Dockerfile              kubernetes  pom.xml    ruoyi-admin   ruoyi-framework  ruoyi-quartz   ruoyi-system  ry.sh      ry.sh-java17
doc  Dockerfile-multi-stage  LICENSE     README.md  ruoyi-common  ruoyi-generator  ruoyi.service  ry.bat        ry.sh.bak  sql

# 准备数据库
## 安装和配置MySQL
apt update && apt install -y mysql-server
sed -i '/127.0.0.1/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf 
### 或者改为0.0.0.0
cat /etc/mysql/mysql.conf.d/mysqld.cnf  | egrep "(^mysql|^bind)"
bind-address            = 0.0.0.0
mysqlx-bind-address     = 0.0.0.0
## 查看数据库脚本
cd /root/RuoYi/sql/  ; ls
quartz.sql  ruoyi.html  ruoyi.pdm  ry_20240112.sql
## 准备数据库表和数据及用户
mysql
create database ry;                            # 创建数据库
create user ry@'%' identified by '123456';     # 创建用户
grant all on ry.* to ry@'%';                   # 授权
use ry                                         # 进入数据库
source /root/RuoYi/sql/ry_20240112.sql         # 导入数据
source /rootRuoYi/sql/quartz.sql               # 导入数据
show tables;                                   # 查看导入的数据表
## 修改连接MySQL的配置
cat RuoYi/ruoyi-admin/src/main/resources/application-druid.yml 
# 数据源配置
spring:
    datasource:
        type: com.alibaba.druid.pool.DruidDataSource
        driverClassName: com.mysql.cj.jdbc.Driver
        druid:
            master:
                url: jdbc:mysql://mysql.duan.org:3306/ry?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
                # 主库数据源，修改数据名称和用户密码
                # 数据库地址：mysql.duan.org:3306
                username: ry
                # 用户名：ry
                password: 123456
                # 密码：123456

```

代理服务器——10.0.0.200

```powershell
# 域名解析
## 注意:mysql.duan.org 需要通过/etc/hosts或DNS实现名称解析,这里的IP是MySQL所在的服务器IP
cat /etc/hosts
10.0.0.200 www.duan.org
10.0.0.203 mysql.duan.org

### 测试客户端（Windows）配置域名解析
C:\Windows\System32\drivers\etc\hosts
10.0.0.200 www.duan.org

# 构建Java项目
## 下载资源
apt update && apt -y install maven
scp -r 10.0.0.203:/root/RuoYi /root/
# maven编译打包
## clean - 清理阶段，删除之前编译生成的 target 目录；
## package - 打包阶段，编译代码并打包成 JAR/WAR 等格式
## -Dmaven.test.skip=true - 跳过测试编译和执行
mvn clean package -Dmaven.test.skip=true
# 查看编译后的jar包
find /root/RuoYi/  -name  "*.java"  -ls
# 查看你运行程序用的jar包
cat /root/RuoYi/bin/run.bat

# 传统方式运行
cd /root/RuoYi &&  java -jar ruoyi-admin/target/ruoyi-admin.jar

# 基于service方式管理服务
cp /root/RuoYi/ry.sh /srv/
cp /root/RuoYi/ruoyi-admin/target/ruoyi-admin.jar /srv
ls /srv
	ruoyi-admin.jar  ry.sh
## 添加执行权限
chmod +x /srv/ry.sh
## 修改官方脚本bug
[root@ubuntu2204 ~]#vim /srv/ry.sh
# JVM参数
# 将JVM_OPTS改为如下配置
JVM_OPTS="-Dname=$AppName  -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"
 ## 创建service文件
[root@ubuntu2204 ~]#vim /lib/systemd/system/ruoyi.service
[Unit]
Description=Ruoyi
After=network.target

[Service]
Type=forking
ExecStart=/srv/ry.sh start
ExecStop=/srv/ry.sh stop
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
# 启用
systemctl daemon-reload ; systemctl start  ruoyi

# 浏览器输入：www.duan.org
# 默认用户名/密码		admin/admin123 
```

#### 单体架构-容器化构建

```powershell
10.0.0.203
# 搭建环境
git clone https://gitee.com/lbtooth/RuoYi.git
apt update && apt install -y mysql-server
sed -i '/127.0.0.1/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf 
## 准备数据库表和数据及用户
cd /root/RuoYi
mysql
create database ry;                            # 创建数据库
create user ry@'%' identified by '123456';     # 创建用户
grant all on ry.* to ry@'%';                   # 授权
use ry                                         # 进入数据库
source RuoYi/sql/ry_20240112.sql               # 导入数据 （必须是相对路径）
source RuoYi/sql/quartz.sql                    # 导入数据 （必须是相对路径）
show tables;                                   # 查看导入的数据表


——————分割线——————上面是宿主机中运行mysql的操作
# 启动数据容器
docker run -p 3306:3306  -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=ry -e MYSQL_USER=ry -e MYSQL_PASSWORD=123456 --name mysql -d -v /data/mysql:/var/lib/mysql --restart=always mysql:8.0.29-oracle
# 加载sql数据
cd /root/RuoYi
docker exec -i mysql mysql -ury -p123456 ry < ./sql/ry_20240112.sql
docker exec -i mysql mysql -ury -p123456 ry < ./sql/quartz.sql 
docker exec -i mysql mysql -ury -p123456 ry -e show tables
docker exec -i mysql mysql -uroot -p123456 ry -e "SHOW TABLES;"
# 验证数据库导入结果
docker exec -i mysql mysql -ury -p123456 ry -e "SHOW TABLES;"
mysql -ury -p123456 -hmysql.duan.org
```

Dockerfile （10.0.0.200）

```powershell
# 基础镜像
FROM openjdk:8u212-jre-alpine3.9

# 作者
LABEL MAINTAINER="duanxueli"

# 更换软件源；设置时区为亚洲上海
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories && apk update && apk --no-cache add tzdata && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装字体相关包，否则无法显示验证码
RUN apk update && apk --no-cache add ttf-dejavu fontconfig

# 创建目录
RUN mkdir -p /data/ruoyi

# 指定路径
WORKDIR /data/ruoyi

# 挂载目录
VOLUME /data/ruoyi

# 复制jar文件到路径
COPY ./ruoyi-admin/target/*.jar /data/ruoyi/ruoyi.jar

# 暴露端口
EXPOSE 80

# 启动服务
CMD java -jar /data/ruoyi/ruoyi.jar --server.port=80
```

java后端服务器 （10.0.0.200）

```powershell
10.0.0.200
# 下载基础配置
apt update && apt -y install maven
scp -r 10.0.0.203:/root/RuoYi   .
# 修改连接MySQL的配置
cat RuoYi/ruoyi-admin/src/main/resources/application-druid.yml 
# 数据源配置
spring:
    datasource:
        type: com.alibaba.druid.pool.DruidDataSource
        driverClassName: com.mysql.cj.jdbc.Driver
        druid:
            # 主库数据源，修改数据名称和用户密码
            # 数据库地址：mysql.duan.org:3306
            # 用户名：ry
            # 密码：123456
            master:
                url: jdbc:mysql://mysql.duan.org:3306/ry?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
                username: ry
                password: 123456
# 添加hosts记录
echo 10.0.0.200 www.duan.org >> /etc/hosts
# maven编译打包
mvn clean package -Dmaven.test.skip=true
# 构建镜像
cd /root/RuoYi					# 这个一步操作仅仅是进入存放dockerfile文件所在目录
docker build -t ruoyi-app:v1.0  .
# 查看镜像
docker images
# 启用容器 
## --add-host 在容器内部的 /etc/hosts 文件中添加域名解析； --add-host mysql.duan.org:10.0.0.203
docker run -d   -v /etc/hosts:/etc/hosts --restart always --name ruoyi -p 80:80 ruoyi-app:v1.0
```

- allowPublicKeyRetrieval=true  解决 MySQL 8.0 公钥问题 ; 如果没有则会在错误信息明确显示：`Public Key Retrieval is not allowed`
- serverTimezone=Asia/Shanghai  更清晰的时区表示
- useSSL=false  表示禁用SSL  
  - MySQL 8.0 配置（默认 SSL 是开启的）设置禁用SSL，若是在该yml文件设置开启SSL，则会导致冲突，致使java应用与mysql连接失败；
  - 若是该yml文件设置禁用SSL连接，无论MySQL 配置是否禁用SSL，都不会导致冲突，会降级到非加密连接；
  - 在生产环境建议双方都开启SSL

#### 单体架构-容器化构建--多节点

```powershell
# 方法2，基于多阶段构建实现容器内编译构建JAVA应用,宿机无需安装JAVA和MAVEN，只需要Docker即可
[root@ubuntu2204 RuoYi]#cat Dockerfile-multi-stage 
#多阶段构建
#FROM maven:3.9.9-eclipse-temurin-8-alpine as build
FROM registry.cn-beijing.aliyuncs.com/wangxiaochun/maven:3.9.9-eclipse-temurin-8-alpine as build
COPY . /RuoYi
WORKDIR /RuoYi
RUN mvn clean package -Dmaven.test.skip=true
# 基础镜像
FROM registry.cn-beijing.aliyuncs.com/wangxiaochun/openjdk:8u212-jre-alpine3.9
# 作者
LABEL MAINTAINER="duanxueli"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories && apk update && apk --no-cache add tzdata && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 挂载目录
VOLUME /data/ruoyi
# 创建目录
RUN mkdir -p /data/ruoyi
# 指定路径
WORKDIR /data/ruoyi
# 复制jar文件到路径
COPY --from=build /RuoYi/ruoyi-admin/target/*.jar /data/ruoyi/ruoyi.jar
#安装依赖的字体，否则无法显示验证码
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories && apk update && apk --no-cache add ttf-dejavu fontconfig
#暴露端口
EXPOSE 80
# 启动服务
CMD java -jar /data/ruoyi/ruoyi.jar --server.port=80
#参考ry.sh
#CMD java -jar /data/ruoyi/ruoyi.jar --server.port=80 -Dname=ruoyi -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30

# 构建镜像（语法：docker build -t 镜像名称:标签 -f 指定要使用的 Dockerfile 文件）
docker build -t harbor.wang.org/example/ruoyi:v1.0 -f Dockerfile-multi-stage .
# 启动容器
docker run -d -v /etc/hosts:/etc/hosts --restart always --name ruoyi -p 80:80 harbor.wang.org/example/ruoyi:v1.0
```

#### 前后端分离项目

> 10.0.0.200	# 反向代理
> 10.0.0.201	# 前端
> 10.0.0.202	# 后端
> 10.0.0.203	# 数据库

```powershell
10.0.0.200
# 配置DNS实现域名解析
atp update && apt install -y bind9
cd /etc/bind/ && vim named.conf.default-zones 
zone "duan.org" {
    type master;
    file "/etc/bind/duan.org.zone";
};
vim duan.org.zone
$TTL    604800
@       IN      SOA     localhost. root.localhost. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@       IN      NS      master
master  A               10.0.0.200
ryui    A               10.0.0.201
ryvue   A               10.0.0.202
mysql   A               10.0.0.203
redis   A               10.0.0.203

# 修改网卡配置 (如果当前主机为DNS服务器,则网卡配置指向本机的IP而非127.0.0.1)
vim /etc/netplan/50-cloud-init.yaml
nameservers:
                addresses:
                - 10.0.0.200
```

```powershell
10.0.0.203
# 准备MySQL和Redis
apt update && apt install -y mysql-server redis

sed -i '/127.0.0.1/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

# 查看数据库脚本
ls RuoYi-Vue/sql
quartz.sql  ry_20231130.sql

# 准备数据库表和数据及用户
mysql
create database ryvue;
create  user ryvue@'%' identified by '123456';
grant all on ryvue.* to  ryvue@'%';
use ryvue
source RuoYi-Vue/sql/ry_20231130.sql
source RuoYi-Vue/sql/quartz.sql
exit

# 修改连接MySQL的配置
cat /root/RuoYi-Vue/ruoyi-admin/src/main/resources/application-druid.yml
# 数据源配置
spring:
    datasource:
        type: com.alibaba.druid.pool.DruidDataSource
        driverClassName: com.mysql.cj.jdbc.Driver
        druid:
            # 主库数据源
            master:
                url: jdbc:mysql://mysql.duan.org:3306/ryvue?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai
                username: ryvue
                password: 123456
# 修改redis配置
sed -i.bak -e 's/^bind .*/bind 0.0.0.0/' -e  '$a requirepass 123456' /etc/redis/redis.conf
systemctl restart redis
```

```powershell
10.0.0.202
# 添加域名解析
echo 10.0.0.203 mysql.duan.org >> /etc/hosts
echo 10.0.0.203 redis.duan.org >> /etc/hosts
# 修改application.yml文件
sed -i "s#redis.wang.org#redis.duan.org#"  /root/RuoYi-Vue/ruoyi-admin/src/main/resources/application.yml
# 安装java工具
apt update && apt install -y maven
mvn -v
# 编译打包
cd /root/RuoYi-Vue  &&  mvn clean package -Dmaven.test.skip=true
ll ruoyi-admin/target/ruoyi-admin.jar  -h
cp ruoyi-admin/target/ruoyi-admin.jar /opt/
cd && java -jar /opt/ruoyi-admin.jar 
# 查看浏览器
http://10.0.0.202:8080/
```

```powershell
10.0.0.201
# 安装工具  下载RuoYi-Vue包
apt update && apt -y install npm
npm -v
node -v

cd /root/RuoYi-Vue/ruoyi-ui
# 安装项目依赖包 --registry=https://registry.npmmirror.com：使用淘宝镜像源，加速下载（国内用户）
npm install --registry=https://registry.npmmirror.com
# 构建生产环境
npm run build:prod
这一步错先报错，后发现使用的 Node.js 18 与 RuoYi UI 项目中的某些依赖不兼容。
# 设置环境变量，使用旧版 OpenSSL 兼容模式
export NODE_OPTIONS="--openssl-legacy-provider"
# 然后构建
npm run build:prod
# 查看生成./dist目录
ls dist/
favicon.ico  html  index.html  index.html.gz  robots.txt  static
```

```powershell
10.0.0.200
apt update && apt install -y nginx
# 准备静态页面文件 将10.0.0.201生成的disk文件拷贝到本地
scp -r 10.0.0.201:/root/RuoYi-Vue .
mkdir -p /data/ryvue
cp -r ruoyi-ui/dist/* /data/ryvue/
# 实现Nginx反向代理配置
vim /etc/nginx/conf.d/ryvue.duan.org.conf 
server {
    listen 80;
    server_name ryvue.duan.org www.ryvue.duan.org;
    location / {
        root /data/ryvue;
        try_files $uri $uri/ /index.html;
        index index.html index,htm;
    }
  
    location /prod-api/ {
        proxy_pass http://10.0.0.202:8080/;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
# 重启nginx
nginx -s reload
# 访问浏览器
http://ryvue.duan.org/index
```





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
> 用户管理 ---> 创建用户        进入项目中的成员添加用户并授权
>
> 仓库管理 ---> 新建目标 ---> 配置仓库地址，是否选验证证书根据仓库主机的http与https协议勾选
>
> 复制管理 ---> 新建图形 ---> 如图所示配置目标仓库和事件驱动 ---> 点击 ‘复制’ （仅首次点一下，后续自动增量复制）

![image-20251111100612149](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251111100612149.png)



![image-20251111100539917](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251111100539917.png)

![](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251111095040002.png)

![image-20251111094630770](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20251111094630770.png)



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



### Docker 的资源限制 



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







## 课外面试拓展

之前公司服务器规模，简单说一下框架结构

#### 说说你之前的公司（工作）监控目标

以purometheus来说，有些是资源类的、有些是业务类的、有些是趋势类的；

资源类又可以细分为硬件设备、系统资源、应用软件

……后面的内容以后说，笔记先记到这里！

#### linux中定时任务的格式 

```powershell
# 分时日月周
* * * * * 
# 示例：每周一的五点整执行打包指令
0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
```

#### 查看当前主机的负载情况

```powershell
root@ubuntu-201:~# uptime
 12:55:53 up 10:25,  1 user,  load average: 0.00, 0.00, 0.02
# 当前时间；运行时长；当前登陆用户数量；系统在最后1分5分15分三个时间段的平均负载值
对于单个CPU核心的系统，如果平均负载为1.00，表示CPU刚好满负荷。如果超过1.00，表示有进程在排队等待。
```

> “平均负载”指的是处于可运行状态和不可中断状态的进程的平均数量。
>
> - 可运行状态：正在使用CPU或等待使用CPU的进程。
> - 不可中断状态：正在等待I/O（如磁盘读写）完成的进程

#### 查看系统进程中的僵尸态

```powershell
# top 命令可以动态实时地查看系统状态，包括僵尸进程的数量
示例输出：
top - 13:16:53 up 10:46,  1 user,  load average: 0.01, 0.02, 0.00
Tasks: 267 total,   1 running, 266 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni, 99.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   3868.0 total,   2959.2 free,    469.9 used,    667.5 buff/cache     
MiB Swap:   3868.0 total,   3868.0 free,      0.0 used.   3398.1 avail Mem 
扩展：上述信息分为四大部分说明，分别是：
# 系统概况：当前时间；运行时长；登陆用户数量；平均负载
# 进程统计：总进程数量；运行数；睡眠数；暂停数；僵尸进程数
# CPU使用情况：用户空间进程占用CPU百分比；内核空间；被调整优先级的进程；空闲；……
# 内存空间：总内存；空闲内存；已使用；缓存、缓冲
# 交换空间：略
```



#### 说一下http协议的工作原理

http协议就是客户端通过tcp连接向服务器发送一个格式化的请求，然后服务器处理并返回一个格式湖的响应，最后客户端根据这个响应内容进行处理并展示。

http协议是建立在tcp协议之上的，客户端首先要与服务器指定的端口建立可靠的tcp连接；

连接建立后，客户端回想服务器发送一个格式标准的“请求报文” ，这个报文有三个部分组成，分别是请求行、请求头、请求体；

请求行包含get、post、url地址以及http版本，请求头包含一些附加信息（比如客户端类型、接受的数据格式），请求体用于存放发送给服务器的数据（如表单数据）；

服务器收到请求后会根据get、post和url找到对应的资源并进行处理，然后生成一个“响应报文”给客户端，这个响应报文由状态行、响应头和响应体组成；

状态行包含http版本、状态码和状态说明，响应头包含响应的元信息（如服务器类型、内容类型、长度等），响应体就是返回给客户端的实际内容；

在默认http/1.0模式下，响应发送完毕，服务器就会关闭该tcp连接，而在http/1.1及以后的版本中，默认使用持久连接，如此可以在同一连接上发送多个请求和响应；

“所以，总结来说，HTTP 协议的核心就是基于 TCP 的‘请求-响应’模型。也正是因为这个工作原理，它衍生出两个非常重要的特点：

1. **无状态**：协议本身不记录之前的请求信息，每个请求都是独立的。这也是为什么我们需要 Cookie、Session 这样的技术来维持用户状态。
2. **明文传输**：HTTP 本身是明文的，存在安全风险。因此，在涉及安全的场景下，我们使用 HTTPS，它就是在 HTTP 和 TCP 之间增加了一个 SSL/TLS 加密层。”

说一下你对mysql的看法以及mysql主从复制的工作原理

MySQL 是大多数 Web 应用的首选，在成本、性能和易用性之间取得了绝佳的平衡。但当业务发展到超大规模，需要进行复杂的水平扩展或重型分析时，就需要考虑引入其他技术方案了。

主从复制的核心是基于二进制日志的异步复制。

当主库执行完增删改这类数据变更的操作后，会将这些更改事件按序记录到本地的二进制日志文件中；而二进制文件记录了所有数据库结构以及内容产生变动的记录；从库会新启动一个I/0线程用于请求主从上的二进制文件内容，并将其拷贝到从库本地的中继日志中；从库会启动一个sql线程读取本地的中继日志，解析中继日志中的事件，并在从库中重新执行这些sql指令，从而使从库数据与主库保持一致。

这种异步复制的模式。它的优点是性能好、对主库影响小；但缺点是它**存在延迟**，在某些极端情况下，可能会遇到从库数据落后于主库的问题。为了缩减缺点带来的影响会在性能允许的情况下尽量减少异步复制的周期间隔！

#### 简单说一下nginx配置文件中的worker_processes auto;

这是 Nginx 配置中一个非常实用的指令。它表示：**让 Nginx 自动设置工作进程的数量，通常等于你服务器 CPU 的核心数。**

它让 Nginx 自动根据你的服务器硬件来配置工作进程，以实现高效的并发处理。在绝大多数生产环境中，这都是推荐的首选配置。

#### 简单说一下容器之间的通讯访问过程

数据包从容器A的`eth0`发出，通过`veth pair`到达宿主机端的虚拟网卡，`docker0`网桥（像交换机）接收数据包，`docker0`根据目标IP/MAC地址，将数据包转发到容器B对应的veth端点，通过`veth pair`到达容器B的`eth0`，容器B的应用收到数据包

**总结**：容器数据通过虚拟网线，即启动容器时成对出现的网卡，之后连接到docker0模拟出来的二层交换机，再由交换机转发到目标容器。

#### 跨主机容器通信做过吗？

我们没有做过跨主机通信，docker无法解决这个问题，我们是通过第三方工具 （k8s fllannel,calico ）解决这个问题的！

- Docker 有哪些常用指令？
- Dockerfile 有哪些指令?
- 两个服务器装了 Docker，双方的容器之间如何实现通信,有几种方式，不同主机的两个容器之间能
- 够通信吗，怎么实现?
- Docker 的网络模式有几种？
- Docker的版本号是多少
- Docker容器中如何对外映射内部的端口？
- 如何找到某个 Docker容器的输出日志的宿主机位置？
- Docker的Dockerfile中的expose端口暴露与命令执行暴露的区别
- Docker 如何查看镜像
- Docker 如何实现容器间互联
- Docker使用到哪些技术？分别有什么作用？
- docker run 运行一个容器，端口映射为8080，一段时间之后忘记当初运行这个容器的命令，请问
- 如何修改映射的端口？
- Dockerfile常用指令有哪些？CMD和entrypoint有什么区别？ADD个COPY有什么区别？
- Docker是使用什么协议进行通信的？
- Dockerfile CMD,RUN 区别
- Dockerfile 做了哪些优化
- Docker 打镜像时需不需要对容器内操作系统进行内核参数优化？
