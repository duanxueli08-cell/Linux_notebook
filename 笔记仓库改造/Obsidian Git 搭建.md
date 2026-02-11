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


### 全量同步

在 Obsidian + PicGo + GitHub 的图文分离架构中，默认只支持增量上传（即“用到才传”），不支持自动删除远端（GitHub）已失效的图片。要实现“全量同步”（包括删除不再引用的图片），需要额外的策略或工具。以下是编写了一个 **一体式 PowerShell 脚本**：

1. 扫描你本地 Obsidian 笔记库中所有 `.md` 文件；
2. 提取所有引用的 GitHub 图床图片文件名（匹配你的 URL 格式）；
3. 克隆或更新你的图床仓库到临时目录；
4. 对比找出未被引用的图片；
5. 自动从 GitHub 仓库中删除这些“孤儿图片”并推送。

---

#### ✅ 使用前提

请确保以下工具已安装并配置好：

- **Git for Windows**（命令行可用 `git`）
- **PowerShell 5.1+**（Win10 默认自带）
- 你的系统能通过 HTTPS 访问 GitHub（建议配置 [GitHub Personal Access Token](https://github.com/settings/tokens) 用于写权限）

> 🔐 如果你的仓库是 **私有仓库**，请使用 PAT（Personal Access Token）代替密码。如果是公开仓库但需推送，也建议用 PAT。

---

#### 📜 一体式清理脚本
（保存为 `clean-obsidian-images.ps1`）

二选一 （临时变量）

```
$env:Token="duanxueli_github_Token_here"
```

由于 该脚本放置在 obsidian 笔记仓库中，若是将 Token 直接写入脚本，则直接将 Token 在 github 中进行暴露；所以进行分离设计，即：每次执行脚本前手动执行一遍环境变量；

二选一 （永久变量）

```
[Environment]::SetEnvironmentVariable("Token", "你的实际token", "User")
```

注意："User" 表示 当前用户级别；
设置后在当前已打开的终端窗口不会立即生效，退出重新进入！



```powershell
# clean-obsidian-images.ps1
# 作者：Qwen / 针对 duanxueli08-cell 的 Obsidian + GitHub 图床环境定制
# 功能：自动删除 GitHub 图床中未被本地笔记引用的图片

# === 配置区 ===
$OBSIDIAN_VAULT_PATH = "C:\Program Files\Obsidian\data\Obsidian Vault\"
$GITHUB_REPO_URL = "https://github.com/duanxueli08-cell/Obsidian-Images.git"
$IMAGE_SUBDIR = "img"  # 图片在仓库中的子目录
$TEMP_REPO_PATH = "$env:TEMP\Obsidian-Images-Clean"

# 可选：如果你的仓库是私有的，或需要写权限，请使用带 token 的 URL
# 格式：https://<TOKEN>@github.com/duanxueli08-cell/Obsidian-Images.git
$GITHUB_REPO_URL = "https://$Token@github.com/duanxueli08-cell/Obsidian-Images.git"

# === 开始执行 ===
Write-Host "[+] 开始清理未使用的 GitHub 图床图片..." -ForegroundColor Cyan

# 1. 扫描所有 .md 文件，提取引用的图片文件名（仅 img/ 下的）
Write-Host "[1/4] 扫描本地笔记中引用的图片..."
$usedImages = @()
Get-ChildItem -Path $OBSIDIAN_VAULT_PATH -Recurse -Include "*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    # 匹配形如 https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/xxx.png 的 URL
    $matches = [regex]::Matches($content, 'https://raw\.githubusercontent\.com/duanxueli08-cell/Obsidian-Images/main/img/([^)\s]+)')
    foreach ($m in $matches) {
        $filename = $m.Groups[1].Value
        if ($filename -match '\.(png|jpg|jpeg|gif|webp)$') {
            $usedImages += $filename
        }
    }
}
$usedImages = $usedImages | Sort-Object -Unique
Write-Host "  -> 共找到 $($usedImages.Count) 个被引用的图片文件"

# 2. 克隆或更新图床仓库到临时目录
Write-Host "[2/4] 同步图床仓库到临时目录..."
if (Test-Path $TEMP_REPO_PATH) {
    Remove-Item -Recurse -Force $TEMP_REPO_PATH
}
git clone --branch main --depth 1 $GITHUB_REPO_URL $TEMP_REPO_PATH
if ($LASTEXITCODE -ne 0) {
    Write-Error "克隆仓库失败，请检查网络或权限（是否需要 PAT？）"
    exit 1
}

# 3. 获取仓库中所有图片文件
$imageDir = Join-Path $TEMP_REPO_PATH $IMAGE_SUBDIR
if (-not (Test-Path $imageDir)) {
    Write-Host "  -> img 目录不存在，无图片可清理。" -ForegroundColor Yellow
    exit 0
}
$allImages = Get-ChildItem -Path $imageDir -File | ForEach-Object { $_.Name }
Write-Host "  -> 仓库中共有 $($allImages.Count) 个图片文件"

# 4. 找出未被引用的图片
$unusedImages = @()
foreach ($img in $allImages) {
    if ($usedImages -notcontains $img) {
        $unusedImages += $img
    }
}
Write-Host "  -> 发现 $($unusedImages.Count) 个未被引用的图片"

if ($unusedImages.Count -eq 0) {
    Write-Host "[✓] 无需清理，所有图片均被引用。" -ForegroundColor Green
    exit 0
}

# 5. 删除未使用的图片并提交推送
Write-Host "[3/4] 删除未使用的图片..."
foreach ($img in $unusedImages) {
    $filePath = Join-Path $imageDir $img
    git -C $TEMP_REPO_PATH rm "$IMAGE_SUBDIR/$img"
    Write-Host "  -> 删除 $img"
}

Write-Host "[4/4] 提交并推送到 GitHub..."
git -C $TEMP_REPO_PATH config user.name "Obsidian Cleaner"
git -C $TEMP_REPO_PATH config user.email "cleaner@example.com"
git -C $TEMP_REPO_PATH commit -m "Auto clean: remove $($unusedImages.Count) unused images"
git -C $TEMP_REPO_PATH push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[✓] 清理完成！已成功推送删除操作。" -ForegroundColor Green
} else {
    Write-Error "推送失败！请手动检查权限或网络。"
}

# 可选：清理临时目录（注释掉以便调试）
# Remove-Item -Recurse -Force $TEMP_REPO_PATH
```

---

#### 🔧 使用步骤

1. **修改脚本中的 `$OBSIDIAN_VAULT_PATH`**  
   这里我根据我的需求将路径设置为 Obsidian 仓库的根目录，如此操作，脚本当前所在路径也不会影响实际执行的路径参数！


2. **允许 PowerShell 执行脚本**（首次运行）(永久生效)：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **运行脚本**：
   ```powershell
   .\clean-obsidian-images.ps1
   ```

---

#### ⚠️ 注意事项

- 脚本默认 **不删除本地 Obsidian 中的图片文件**（因为你是图文分离，本地可能没存图）。
- 所有操作基于 **远程 URL 引用分析**，确保你的笔记中图片链接是 `https://raw.githubusercontent.com/.../main/img/xxx.png` 格式。
- 首次运行建议先 **备份图床仓库**，或注释掉最后的 `push` 行进行 dry-run 测试。

---

