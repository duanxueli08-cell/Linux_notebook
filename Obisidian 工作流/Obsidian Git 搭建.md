首先创建一个远程仓库，比如：
- github （推荐）
- 阿里云 （备选）
- gitee

## Windows 操作环境
Windows 操作环境，需要下载 Git 工具
(个人喜欢独立安装器，便携版也不错，根据自己需求选择)
下载链接：
https://github.com/git-for-windows/git/releases/download/v2.52.0.windows.1/Git-2.52.0-arm64.exe


进入需要上传的文件夹中，位置以自己的为准！
cd /c/Program Files/Obsidian/data/Obsidian Vault
在这个位置打开 git 终端界面

```
初始化仓库：
git init

配置用户信息（如果是第一次用 Git）：
git config --global user.name "duanxueli"
git config --global user.email "17777055510@163.com"

连接远程库 
git remote add origin https://github.com/duanxueli08-cell/K8S-.git
```

由于没有了解清楚，导致需要切换连接仓库类型！所以推荐 SSH 

```
生成你自己的“身份证”（SSH Key）
ssh-keygen -t ed25519 -C "duanxueli08@gmail.com"

查看公钥，把公钥交给 GitHub （SSH and GPG keys 页面）
cat ~/.ssh/id_ed25519.pub


修改远程仓库地址（关键的“回退”/切换）
# 格式：git remote set-url origin git@github.com:用户名/仓库名.git
git remote set-url origin git@github.com:duanxueli08-cell/K8S-.git

查看结果
git remote -v

把文件添加到“暂存区”
git add README.md

提交到“本地仓库”，并写上备注
git commit -m "这是我的第一次提交：初始化项目"

强制把主分支改名为 main（GitHub 现在默认叫 main，以前叫 master）
git branch -M main

把代码推上去，-u 表示以后默认就推到这个地方了
git push -u origin main

很重要！一定要先测试一下哦！！！
ssh -T git@github.com

推送
git push -u origin main
```

### 故障
因为一些原因导致 SSH 端口不能访问，类似这个情况
```
Administrator@Shirley MINGW64 /c/Program Files/Obsidian/data/Obsidian Vault/Typora (main)

$ ssh -T git@github.com

Connection closed by 198.18.0.10 port 22
```
解决步骤 (Windows 系统)
如果没有 Git 工具，需要去C:\Users\你的用户名\.ssh\下面新建一个config文本文件
让 GitHub 走 443 端口，伪装成 HTTPS 流量 
```
vim ~/.ssh/config
Host github.com 
	Hostname ssh.github.com 
	Port 443 
	User git
```


## 安装 Git 插件
插件配置根据自己需求打开或关闭
忽略权限指令
```
cd /c/Program Files/Obsidian/data/Obsidian Vault
git config core.fileMode false
# 检查是否生效,如果返回 false ，说明搞定了!
git config --get core.fileMode
```
清理 Git 索引
```
git rm -r --cached . 
git add . 
git commit -m .
```
在 git 仓库中创建一个文件  .gitignore
```
# --- Obsidian 缓存与临时文件 ---
.obsidian/cache/
.obsidian/workspace.json
.obsidian/workspaces/
.obsidian/trash/

# --- 忽略插件生成的特定数据（避免多设备同步冲突） ---
.obsidian/plugins/obsidian-git/data.json
.obsidian/plugins/recent-files-obsidian/data.json
.obsidian/workspace-mobile.json
.trash/
.smart-env

# --- 忽略操作系统生成的干扰文件 ---
.DS_Store
Thumbs.db
desktop.ini
*.bak
*.tmp

# --- 特殊配置：保留插件和主题，但忽略它们的缓存 ---
!.obsidian/plugins/
!.obsidian/themes/
```


切换连接方式 ; SSH —— HTTPS
```
git remote set-url origin https://github.com/duanxueli08-cell/K8S-.git
```

# 安装 Template  插件

🛠️ SRE 生产力工具配置：Templater 自动化笔记指南

> **文档说明**：本手册用于指导如何在 Windows 环境下配置 Obsidian 的 Templater 插件，实现笔记的“自动化部署”与“全键盘操作”。

---

## 一、 基础安装与环境初始化 (Infrastructure Setup)

1. **插件下载**：进入 `Settings` -> `Community plugins` -> 搜索 `Templater` -> 安装并启用。
    
2. **创建“仓库中心”**：在 Obsidian 根目录新建文件夹 `99_Templates` (建议加数字前缀使其置底，保持目录整洁)。
    
3. **路径绑定**：
    
    - 进入 `Templater` 插件设置。
        
    - 找到 **Template folder location**，将其指向刚才创建的 `99_Templates`。
        

---

## 二、 核心参数调优 (Configuration Tuning)

为了实现真正的自动化，必须开启以下三个“生产开关”：

|**配置项**|**操作**|**SRE 原理/效果**|
|---|---|---|
|**新建自动触发**|开启 `Trigger Templater on new file creation`|监听文件创建事件，发现空文件立即注入代码。|
|**光标瞬间跳变**|开启 **`Automatic jump to cursor`**|**原理**：启用后，插件会扫描 `<%tp.file.cursor()%>` 占位符。若不开启，光标无法定位，代码会残留为原始文本。|
|**目录自动化部署**|开启 **`Enable folder templates`**|**效果**：实现“路径即逻辑”。在 `Linux` 文件夹下新建文件自动用 Linux 模板，在 `K8s` 下新建则自动用 K8s 模板。|

---

## 三、 高阶进阶：快捷键与全键盘流 (Automation)

作为运维，能用键盘解决的绝不动鼠标。

1. **模板热键绑定**：
    
    - 在 Templater 设置的 `Template hotkeys` 区域，点击 **Add new hotkey for template**。
        
    - 选择你的“运维实战笔记模板”。
        
2. **系统层关联**：
    
    - 前往 Obsidian `Settings` -> `Hotkeys`。
        
    - 搜索刚才添加的模板，绑定为 `Ctrl + Shift + T` (或你顺手的组合)。
        
    - **操作流**：`Ctrl + N` (新建文件) -> `Ctrl + Shift + T` (喷涌模板) -> 直接打字。
        

---

## 四、 补充

存算分离：配合图床使用

- **规范**：笔记中凡是涉及实验截图，一律通过 `Ctrl + V` 由 PicGo 自动上传至 GitHub 仓库。
    
- **好处**：保持本地 `.md` 文件轻量化，方便 Git 快速同步，避免因图片过多导致的“同步风暴”。
    



# 图床插件

目的：需要完成 文图分离、存算分离 的架构

#### 第一步：核心组件安装 (The Infrastructure)

1. **下载 PicGo (Windows 客户端)**：[PicGo 官网](https://picgo.github.io/PicGo-Doc/)。它是你的“图片路由器”。
    
2. **Obsidian 插件**：在插件市场搜 **`Image Auto Upload Plugin`**。它是你的“触发器”。
    

#### 第二步：配置 GitHub 仓库 (The Storage)

1. 在 GitHub 新建一个仓库，名字叫 `Obsidian-Images`，设置为 **Public**（公开）。
    
2. **生成 Token**：
    
    - 进入 GitHub 设置 -> `Developer settings` -> `Personal access tokens` -> `Tokens (classic)`。
        
    - 勾选 `repo` 权限。**把生成的这一串字符复制下来，它只出现一次！**
        
```
# Token 都在 Bitwarden 软件中保存
```

```
#### 第三步：PicGo 联动 (The Configuration)

打开 PicGo，选择“GitHub 图床”，填入：

- **仓库名**：`你的用户名/Obsidian-Images`
    
- **分支**：`main`
    
- **Token**：刚才复制的那串字符。
    
- **存储路径**：可以写 `img/`（这样图片会自动归类到文件夹下）。
    
```
duanxueli08-cell/Obsidian-Images
main
```
#### 第四步：最后一步“握手”

在 Obsidian 的 `Image Auto Upload Plugin` 插件设置里，把 `Default upload service` 选为 **PicGo**。

### 🎨 效果演示：你以后怎么写笔记？

1. **截图**：按下 `Win + Shift + S`。
    
2. **粘贴**：在 Obsidian 里 `Ctrl + V`。
    
3. **魔法发生**：你会看到右下角弹出 PicGo 的上传成功提示。
    
4. **结果**：你的笔记里自动生成了类似 `![](https://raw.githubusercontent.com/...)` 的链接。
    

**为什么要这么折腾？**

- **高可用**：你的图片存在 GitHub 全球节点上，只要有网络，你的笔记去哪都能看。
    
- **极简**：你的 Obsidian 文件夹里再也不会有一堆乱七八糟的 `.png` 文件了，只有纯粹的 Markdown。

图灵测试
![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20251224170803576.png)

```


### 后续问题

在 Obsidian + PicGo + GitHub 的图文分离架构中，默认只支持增量上传（即“用到才传”），不支持自动删除远端（GitHub）已失效的图片。要实现“全量同步”（包括删除不再引用的图片），需要额外的策略或工具。以下是推荐的方案：

#### 方案：使用脚本定期清理 GitHub 中未被引用的图片

1. 原理：
- 扫描 Obsidian 笔记库中所有 .md 文件，提取所有引用的图片文件名（如 20240512102345.png）。
- 列出 GitHub 图床仓库中的所有图片。
- 对比两者，删除 GitHub 中存在但笔记中未引用的图片。

2. 实现步骤：
获取本地引用的图片列表
```powershell
# 在 Obsidian 库根目录执行（Linux/macOS）
grep -rhoE '!\[.*\](https://raw\.githubusercontent\.com/你的用户名/图床仓库/分支/images/[^)]+)' . --include="*.md" \
  | sed 's/.*\/images\///' > /tmp/used_images.txt
```

> 注意：URL 需根据你的 PicGo 配置调整
> （如是否用 raw.githubusercontent.com 或自定义 CDN）

获取 GitHub 图床仓库中的图片列表
可通过 GitHub API 或直接 clone 图床仓库：

```powershell
git clone https://github.com/你的用户名/图床仓库.git /tmp/image-repo

ls /tmp/image-repo/images > /tmp/all_images.txt
```


3. 计算差集并删除远端图片

```powershell
comm -23 <(sort /tmp/all_images.txt) <(sort /tmp/used_images.txt) > /tmp/to_delete.txt

# 删除本地副本并推送到 GitHub
cd /tmp/image-repo
cat /tmp/to_delete.txt | xargs -I {} git rm "images/{}"
git commit -m "Auto clean unused images"
git push
```


4. 自动化（可选）
用 cron（Linux/macOS）或 Task Scheduler（Windows）每周运行一次。
或集成到 Obsidian 的“每日笔记”工作流中（通过 Templater + Shell commands 插件）。