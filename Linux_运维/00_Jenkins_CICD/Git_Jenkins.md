### Git

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
git restore test                   # 推荐
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

![image-20260219231304143](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/image-20260219231304143.png)


![image-20251116174541249.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/image-20251116174541249.png)

![image-20251116172550065.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/image-20251116172550065.png)


![image-20251116172114867.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/image-20251116172114867.png)





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

![image-20251120093932234](C:\Program Files\Obsidian\data\Obsidian_Vault\Image\image-20251120093932234.png)

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

![image-20251122111257843](C:\Program Files\Obsidian\data\Obsidian_Vault\Image\image-20251122111257843.png)

重启服务才能生效，安装后界面

![image-20251122111404604](C:\Program Files\Obsidian\data\Obsidian_Vault\Image\image-20251122111404604.png)

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

![image-20251122113932289](C:\Program Files\Obsidian\data\Obsidian_Vault\Image\image-20251122113932289.png)

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

 