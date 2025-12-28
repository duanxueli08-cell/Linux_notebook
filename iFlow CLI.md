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


### 常用技巧（Windows 友好版）

#### 1. **引用文件内容**

需要操作的文件需要放置在项目专用的文件夹中

编辑

```
@~\微服务.md 请检查我这个关于微服务的学习笔记，做出评价
```

- 使用反斜杠 `\` 或正斜杠 `/` 都可以（Node.js/iFlow 会自动处理）。

#### 2. **执行 Windows 命令**

！表示执行

编辑

```
!dir /b
```

#### 3. **初始化项目上下文**

text

编辑

```
/init
```

→ 生成 `IFLOW.md` 文件，记录你的对话历史和操作步骤（便于复现）。

#### 4. **查看帮助**

text

编辑

```
/help
```

→ 显示所有支持的命令和快捷方式。

#### 5. **运行演示流程**

text

编辑

```
/demo
```

→ 自动执行一个预设的 AI 工作流（如头脑风暴 + 生成报告）。


