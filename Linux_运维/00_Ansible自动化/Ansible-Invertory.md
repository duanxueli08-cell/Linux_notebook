# Ansible-Invertory



### Ansible安装

```powershell
需要配置epel仓库
[root@m01 ~]# yum -y install ansible
#注意ansible只安装不启动

Ansible参数:
-i #主机清单文件路径，默认是在/etc/ansible/hosts 使用-i指定主机清单的位置
-m #使用的模块名称，默认使用command模块
-a #使用的模块参数，模块的具体动作

修改主配置文件:跳过指纹检测
[root@m01 ~]# grep host_key_checking /etc/ansible/ansible.cfg -n
 host_key_checking = False

```





### Ansible Inventory主机清单

```powershell
Ansible基于用户名+密码+端口方式管理客户端
方法1.指定客户端用户名+密码+端口方式
[root@m01 ~]# cat /etc/ansible/hosts
10.0.0.7 ansible_ssh_user=root ansible_ssh_port=22 ansible_ssh_pass='1'

测试是否管理客户端使用ping模块
[root@m01 ~]# ansible 10.0.0.7 -m ping
10.0.0.7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

方法2.指定主机方式,使用别名方式管理客户端
vim /etc/ansible/hosts
web02 ansible_ssh_host=10.0.0.8 ansible_ssh_pass='1'

[root@m01 ~]# ansible web02 -m ping
web02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

方法3.使用区间范围表示主机
[root@m01 ~]# cat /etc/ansible/hosts
10.0.0.[7:8] ansible_ssh_user=root ansible_ssh_port=22 ansible_ssh_pass='1'
表示客户端包含:
10.0.0.7
10.0.0.8

设置小组:[小组名称]
[root@m01 ~]# cat /etc/ansible/hosts
10.0.0.31 ansible_ssh_pass='1'
[webs]
web01 ansible_ssh_host=10.0.0.7 ansible_ssh_pass='1'
web02 ansible_ssh_host=10.0.0.8 ansible_ssh_pass='1'
www.linuxnc.com
[dbs]
10.0.0.51 ansible_ssh_pass='1'

查看小组的成员:
[root@m01 ~]# ansible webs --list-hosts
  hosts (3):
    web01
    web02
    www.linuxnc.com

2.Ansible基于免秘钥方式管理客户端
1)生成秘钥对
[root@m01 ~]# ssh-keygen

2)拷贝到客户端
[root@m01 ~]# ssh-copy-id -i .ssh/id_rsa.pub 10.0.0.7
[root@m01 ~]# ssh-copy-id -i .ssh/id_rsa.pub 10.0.0.8

3)配置主机清单:
[root@m01 ~]# cat /etc/ansible/hosts
10.0.0.7
10.0.0.8

4)测试
[root@m01 ~]# ansible 10.0.0.7 -m ping
10.0.0.7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[root@m01 ~]# ansible 10.0.0.8 -m ping
10.0.0.8 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

使用all表示所有客户端:
[root@m01 ~]# ansible all -m ping
10.0.0.8 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
10.0.0.7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

设置小组:
[root@m01 ~]# cat /etc/ansible/hosts
[webs]
web01 ansible_ssh_host=10.0.0.7
web02 ansible_ssh_host=10.0.0.8

[root@m01 ~]# ansible webs -m ping
web02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
web01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

设置包含多个组:
[lnmp:children]
webs
dbs

小结: inventory主机清单 基于SSH
1)基于用户名+密码+端口
2)基于免秘钥

vim /etc/ansible/hosts
10.0.0.7 #指定单台主机
web01 ansible_ssh_host=10.0.0.7 #使用别名
[webs] #指定小组
10.0.0.7
10.0.0.8
[dbs]
10.0.0.51
10.0.0.52
[lnmp:children] #指定多个组
webs
dbs

```



### Ansible-Adhoc

```powershell
环境准备:
[root@m01 ~]# cat /etc/ansible/hosts
nfs ansible_ssh_host=10.0.0.31
[webs]
web01 ansible_ssh_host=10.0.0.7
[dbs]
web02 ansible_ssh_host=10.0.0.8
[lnmp:children]
webs
dbs

免秘钥推送

第一个模块: command模块不支持管道,不建议使用
第二个模块: shell模块，在不知道用啥模块的时候，使用shell模块
第三个模块: scripts模块执行脚本的模块

安装nfs-utils
配置nfs-utils
启动nfs-utils

第四个模块 : yum 模块
yum:
  name: nfs-utils 软件的名称
  state:动作
    present安装
    absent 卸载
    latest 安装最新版软件

[root@m01 ~]# ansible nfs -m yum -a 'name=nfs-utils state=present' #安装nfs-utils
[root@m01 ~]# ansible nfs -m yum -a 'name=nfs-utils state=absent' #卸载nfs-utils

案例:创建文件 file模块
[root@m01 ~]# ansible webs -m file -a 'path=/root/ansible.txt state=touch'
[root@m01 ~]# ansible webs -m file -a 'path=/root/ansible state=directory'

file模块
copy模块
user模块
group创建
db模块
mount模块
system模块

```





### Ansible-playbook

```powershell
案例1.playbook重构NFS服务
1.恢复快照
2.打通免秘钥
[root@m01 ~]# ssh-copy-id -i .ssh/id_rsa.pub 10.0.0.31

[root@m01 ~]# mkdir ansible
[root@m01 ~]# cd ansible/
[root@m01 ansible]#
[root@m01 ansible]# cat nfs.yml
#安装nfs-utils
- hosts: nfs
  tasks:
    - name: Install NFS Server
      yum:
        name: nfs-utils
        state: present

测试语法是否正确:啥都不显示说明没问题
[root@m01 ansible]# ansible-playbook --syntax-check nfs.yml
playbook: nfs.yml

执行playbook
[root@m01 ansible]# ansible-playbook nfs.yml

yum模块:
yum:
  name: nfs-utils指定包的名称
  state:动作[present|absent|latest]

copy模块:
copy:
  src:源文件(在61服务器)
  dest:拷贝到客户端的具体的位置
  owner:属主
  group:属组
  mode:权限
  content: "字符串"

案例:将61的exports拷贝到nfs的家目录 属主属组为bin 权限为600
- name: Configure NFS Server
  copy:
    src: exports
    dest: /root/exports
    owner: bin
    group: bin
    mode: 0600

案例:将content中的字符串定向到目标位置/root/test.txt
[root@m01 ansible]# cat nfs.yml
- hosts: nfs
  tasks:
    - name: Install NFS Server
      yum:
        name: nfs-utils
        state: present
    - name: Configure NFS Server
      copy:
        content: "/data/ 172.16.1.0/24(rw,sync,all_squash,anonuid=666,anongid=666)"
        dest: /etc/exports

group模块:
group:
  name:组的名字
  gid: 小组的编号
  state:动作创建还是删除[present|absent]

user模块：
user:
  name:用户名
  uid: 用户的id
  group:组名称
  shell:指定解释器[/bin/bash|sbin/nologin]
  create_home:是否创建家目录 true创建 false

file模块：
file:
  path:创建的位置
  state: 
    touch创建普通文件
    directory创建目录
    absent删除文件或目录
  owner：属主
  group:属组
  mode: 权限
  recurse:递归授权

systemd模块
systemd:
  name: nfs #服务名称
  state: started#动作
  enabled: yes #开机是否运行

systemd的动作:
started #启动
stopped #停止
restarted#重启
reloaded #重新加载

[root@m01 ansible]# cat nfs.yml
- hosts: nfs
  tasks:
    - name: Install NFS Server
      yum:
        name: nfs-utils
        state: present
    - name: Configure NFS Server
      copy:
        content: "/data/ 172.16.1.0/24 (rw,sync,all_squash,anonuid=666,anongid=666)"
        dest: /etc/exports
    - name: Create www Group
      group:
        name: www
        gid: 666
        state: present
    - name: Create www User
      user:
        name: www
        uid: 666
        group: www
        shell: /sbin/nologin
        create_home: false
    - name: Create /data
      file:
        path: /data
        state: directory
        owner: www
        group: www
    - name: Start NFS Server
      systemd:
        name: nfs
        state: started
        enabled: yes
```



### Ansible重构backup服务

```
1.安装backup服务
2.配置backup服务
/etc/rsyncd.conf
uid=www
gid=www
auth_user=rsync_backup
auth_pass=/etc/rsync.pass
[backup]
path=/backup
3.根据配置文件创建数据
4.启动加入开机启动

客户端测试:
rsync -avz xxxx rsync_backup@172.16.1.41::backup

重点:
主机清单配置
单台主机
组
基于SSH用户名+密码
免秘钥
playbook重构NFS BACKUP Nginx+PHP DB
```