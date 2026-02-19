### 背景描述

我在 obsidian 中插入了一个图片，也搭建好的图文分离的框架，通过 Image Auto Upload 这个插件自动将笔记中的图片通过picgo上传到github中，但是现在文字上传同步没有问题，但是图片不能上传。下面是一段picgo的日志！

```
2026-02-19 15:58:57 [PicGo INFO] [PicGo Server] upload result 2026-02-19 15:58:57 [PicGo WARN] [PicGo Server] upload failed, see picgo.log for more detail ↑ 2026-02-19 22:35:55 [PicGo INFO] [PicGo Server] get the request {"list":["https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/image-20260219223554992.png"]} 2026-02-19 22:35:55 [PicGo INFO] [PicGo Server] upload files in list 2026-02-19 22:35:55 [PicGo INFO] Before transform 2026-02-19 22:35:55 [PicGo INFO] Transforming... Current transformer is [path] 2026-02-19 22:35:55 [PicGo INFO] Before upload 2026-02-19 22:35:55 [PicGo INFO] beforeUploadPlugins: renameFn running 2026-02-19 22:35:55 [PicGo INFO] Uploading... Current uploader is [github] 2026-02-19 22:35:56 [PicGo WARN] failed 2026-02-19 22:35:56 [PicGo ERROR] { "method": "PUT", "url": "https://api.github.com/repos/duanxueli08-cell/Obsidian-Images/contents/img/image-20260219223554992.png", "statusCode": 401, "message": "Request failed with status code 401", "stack": {}, "response": { "status": 401, "statusCode": 401, "body": { "message": "Bad credentials", "documentation_url": "https://docs.github.com/rest", "status": "401" } } } 2026-02-19 22:35:56 [PicGo ERROR] { "method": "PUT", "url": "https://api.github.com/repos/duanxueli08-cell/Obsidian-Images/contents/img/image-20260219223554992.png", "statusCode": 401, "message": "Request failed with status code 401", "stack": {}, "response": { "status": 401, "statusCode": 401, "body": { "message": "Bad credentials", "documentation_url": "https://docs.github.com/rest", "status": "401" } } } 2026-02-19 22:35:56 [PicGo INFO] [PicGo Server] upload result 2026-02-19 22:35:56 [PicGo WARN] [PicGo Server] upload failed, see picgo.log for more detail ↑
```

软件的日志路径：C:\Users\Administrator\AppData\Roaming\picgo\picgo.log

### 问题分析

经过 chatgpt 分析，很可能是 token 失效了！

> 判断依据：

```
# 日志中关键信息提到：
statusCode: 401
"message": "Bad credentials"

# 这说明了什么？
401 = 未授权
Bad credentials = 凭证错误

我的 GitHub Token 已经失效、填错、或者权限不足。
不是网络问题
不是仓库名问题
不是分支问题
就是 Token 问题。
```


```
我现在用的是 GitHub API 上传
PicGo 是通过 GitHub REST API 调用：
PUT /repos/{owner}/{repo}/contents/{path}

这个接口必须使用 Personal Access Token (PAT)。

如果：
Token 过期
Token 被撤销
Token 权限不包含 repo
Token 复制时多了空格
换了 GitHub 账号

都会直接报这个 401。
```


### 解决步骤

#### 第一步：去 GitHub 重新生成 Token

进入：

https://github.com/settings/tokens

建议使用：

✔ Fine-grained token（推荐）

创建新 Token 时：

```
Repository access：

选择 Only select repositories

勾选：Obsidian-Images

Permissions 里：

Contents → Read and write ✅

然后生成。

复制生成的 Token（只会显示一次）。
```

#### 第二步：重新填入 PicGo

打开 PicGo：

图床设置 → GitHub

设定仓库名：duanxueli08-cell/Obsidian-Images

分支：main（确认一下你仓库默认分支）

Token：粘贴新的

⚠ 不要有空格
⚠ 不要带引号

保存。


---

### 补充

到这一步其实已经解决了问题，但是还有一些历史遗留问题没有解决！
笔记中有很多本地绝对文件路径，这样中本地查看笔记中的图片没有问题，但是中 github 中，以及另一台设备中就看不到对应的图片信息，为此需要将图片的路径信息进行更改！

- 第一，确定图片的文件路径，然后将该路径下的图片手动拖到 Picgo 中上传 github；
- 第二，批量更改笔记中的文件路径，比如：

```
C:\Program Files\Obsidian\data\Obsidian_Vault\Image\

https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/
```

如此，图片的文件名称不变，仅仅将本地存储路径改变为 URL 路径即可！