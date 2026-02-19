### 背景描述

我在 obsidian 中插入了一个图片，也搭建好的图文分离的框架，通过 Image Auto Upload 这个插件自动将笔记中的图片通过picgo上传到github中，但是现在文字上传同步没有问题，但是图片不能上传。下面是一段picgo的日志！

```
2026-02-19 15:58:57 [PicGo INFO] [PicGo Server] upload result 2026-02-19 15:58:57 [PicGo WARN] [PicGo Server] upload failed, see picgo.log for more detail ↑ 2026-02-19 22:35:55 [PicGo INFO] [PicGo Server] get the request {"list":["C:/Users/Administrator/AppData/Roaming/Typora/typora-user-images/image-20260219223554992.png"]} 2026-02-19 22:35:55 [PicGo INFO] [PicGo Server] upload files in list 2026-02-19 22:35:55 [PicGo INFO] Before transform 2026-02-19 22:35:55 [PicGo INFO] Transforming... Current transformer is [path] 2026-02-19 22:35:55 [PicGo INFO] Before upload 2026-02-19 22:35:55 [PicGo INFO] beforeUploadPlugins: renameFn running 2026-02-19 22:35:55 [PicGo INFO] Uploading... Current uploader is [github] 2026-02-19 22:35:56 [PicGo WARN] failed 2026-02-19 22:35:56 [PicGo ERROR] { "method": "PUT", "url": "https://api.github.com/repos/duanxueli08-cell/Obsidian-Images/contents/img/image-20260219223554992.png", "statusCode": 401, "message": "Request failed with status code 401", "stack": {}, "response": { "status": 401, "statusCode": 401, "body": { "message": "Bad credentials", "documentation_url": "https://docs.github.com/rest", "status": "401" } } } 2026-02-19 22:35:56 [PicGo ERROR] { "method": "PUT", "url": "https://api.github.com/repos/duanxueli08-cell/Obsidian-Images/contents/img/image-20260219223554992.png", "statusCode": 401, "message": "Request failed with status code 401", "stack": {}, "response": { "status": 401, "statusCode": 401, "body": { "message": "Bad credentials", "documentation_url": "https://docs.github.com/rest", "status": "401" } } } 2026-02-19 22:35:56 [PicGo INFO] [PicGo Server] upload result 2026-02-19 22:35:56 [PicGo WARN] [PicGo Server] upload failed, see picgo.log for more detail ↑
```

软件的日志路径：C:\Users\Administrator\AppData\Roaming\picgo\picgo.log

### 问题解决过程

经过 chatgpt 分析，很可能是 token 失效了！
