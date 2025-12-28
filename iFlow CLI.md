---
create_time: 2025-12-28 13:36
tags: SRE/Learning
status: 📝 沉淀中……
---

## 🛠️ 运维实战：未命名

- **实验日期**: 2025-12-28
- **操作人员**: 段学立 (SRE Engineer)
- **环境信息**: 
    Windows 专业工作站版本

---

### 1. 🎯 实验/故障目标
> **场景描述**：完成系统 AI 管家的目标

官方文档：[快速开始 | 心流开放平台](https://platform.iflow.cn/cli/quickstart)

### 2. ⚡ 核心操作步骤

1. 访问 https://nodejs.org/zh-cn/download 下载最新的 Node.js 安装程序
- 推荐选择 Windows 安装程序 ，而不是独立文件，不然要花费实践学习相关的环境安装！
2. 重启终端：CMD(Windows + r 输入cmd) 或 PowerShell
- 推荐使用 Windows Terminal：为了获得更好的兼容性和使用体验，强烈推荐使用 [Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701) 运行 iFlow CLI，可以大幅减少环境兼容性问题。
```
# 将当前用户的执行策略设为 `RemoteSigned`（允许本地脚本运行）：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
2. 运行 `npm install -g @iflow-ai/iflow-cli@latest` 来安装 iFlow CLI
```
# 查看版本信息
iflow --version
# 启动 iFlow CLI
iflow
```

- **建议**：最好在**项目专用文件夹**中运行，这样可以更好地管理上下文、配置和输出文件，避免混淆。
```
# 在用户家目录下生成项目专用的文件夹
mkdir ~/iflow_run
cd ~/iflow_run
# 进入专用的路径下启动
iflow
```


这里是 iFlow CLI（心流 AI 团队开发的终端 AI 助手）的一些常用使用技巧，帮助你快速提升效率：

1. 先用 /init 初始化项目  
    在项目目录下运行 iflow，进入交互模式后输入 /init。这会让 iFlow CLI 自动扫描当前代码仓库结构、生成 IFLOW.md 文件，并理解项目上下文。后续所有任务（如代码生成、调试）都会更准确，避免反复解释项目背景。
2. 精准投喂文件内容  
    用 @文件名 的方式快速引用特定文件，例如：@src/main.js 这个文件有什么问题？ 或 @views/register.tsx 解释一下这个组件的功能。适合快速分析或修改单个文件，而不用每次上传整个项目。
3. 支持多模态输入（贴图）  
    在终端中直接 Ctrl+V 粘贴图片（截图、设计稿、错误界面等），iFlow CLI 会自动识别并分析。非常适合描述 UI 问题、原型图转代码，或调试界面 bug。
4. 使用 /clear 或 /resume 管理对话  
    对话太长时输入 /clear 清空上下文，避免 token 浪费。需要恢复上一次对话时，用 iflow --resume 启动，能直接继续之前的会话历史。
5. 结合 Shell 命令辅助  
    在交互中输入 !命令 执行本地 shell，例如 !ls -la 列出文件，或 !git status 查看状态。然后让 AI 分析输出结果，比如接着问“根据上面的 git status，有什么需要 commit 的？”
6. 安装 MCP 或 SubAgents 扩展功能  
    通过心流开放市场一键安装常用工具（如 fetch、context7 等），扩展能力如网络请求、上下文压缩等。命令如 iflow mcp list 查看已安装，或直接在市场搜索安装。