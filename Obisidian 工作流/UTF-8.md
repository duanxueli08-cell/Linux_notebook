
## 一劳永逸方案：**启用 Windows 全局 UTF-8 支持**

这是微软官方提供的设置，能从根本上解决问题。

### 🔧 操作步骤（Windows 10/11）：

1. 打开 **设置 → 时间和语言 → 语言 → 管理语言设置**
    - 或直接搜索 “区域” → 点击 **“区域”** 设置
2. 在弹出窗口中，点击底部 **“管理”** 选项卡
3. 点击 **“更改系统区域设置…”**
4. ✅ 勾选 **“Beta 版：使用 Unicode UTF-8 提供全球语言支持”**
5. 点击 **确定** → 重启电脑

✅ 完成后：

- 所有新创建的文件默认用 UTF-8
- PowerShell、CMD、Git、Python、Node.js 等工具自动识别 UTF-8
- Cursor、VS Code、Obsidian 不再出现中文路径乱码

> ⚠️ 注意：极少数老旧软件（如某些国产安装包）可能不兼容，但现代开发工具完全没问题。
![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20251228172815990.png)

## 🛠️ 补充：强制命令行使用 UTF-8（即使未改系统设置）

如果你暂时不想改系统全局设置，也可以在脚本中临时启用：

### 在 PowerShell 中：

powershell

编辑

```
# 强制输入输出使用 UTF-8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 设置环境变量（影响子进程）
$env:PYTHONIOENCODING = "utf-8"
$env:GIT_CONFIG_PARAMETERS = "'core.quotepath=false' 'i18n.logoutputencoding=utf8'"
```

### 在 CMD 中：

cmd

编辑

```
chcp 65001
```

> `65001` 是 UTF-8 的代码页编号

---

## 📦 对 Git 的额外配置（重要！）

即使系统设为 UTF-8，Git 仍需单独配置：

bash

编辑

```
# 全局设置 Git 使用 UTF-8
git config --global core.quotepath false        # 显示真实中文文件名（而非 \xxx 转义）
git config --global i18n.logoutputencoding utf8 # 提交日志用 UTF-8
git config --global gui.encoding utf8           # Git GUI 工具编码
```

✅ 这样 `git status` 就会显示 `西游释厄传.md` 而不是 `\350\245\277\346\270\264...`

---

## ⚖️ 改为 UTF-8 后有什么影响？

|方面|影响|是否安全|
|---|---|---|
|✅ **现代软件**（VS Code, Obsidian, Cursor, Chrome, Python, Node.js）|完全兼容，体验更好|✅ 安全|
|✅ **Git / GitHub**|中文文件名正常显示|✅ 安全|
|⚠️ **极老软件**（如 WinXP 时代程序、某些银行控件）|可能乱码或崩溃|❌ 需测试|
|✅ **你的笔记库**|所有 `.md` 文件天然兼容跨平台|✅ 强烈推荐|
|✅ **未来兼容性**|符合国际标准，避免技术债|✅ 长期受益|

> 📌 绝大多数用户（尤其是开发者、学生、知识工作者）**完全可以安全启用**！

## 📚 常见代码页速查表

| 代码页 | 名称           | 用途                        |
| ------ | -------------- | --------------------------- |
| 437    | OEM - US       | 英文 DOS                    |
| 850    | OEM - Latin-1  | 西欧 DOS                    |
| 932    | Shift-JIS      | 日文                        |
| 936    | GBK            | 简体中文                    |
| 949    | EUC-KR         | 韩文                        |
| 950    | Big5           | 繁体中文                    |
| 1252   | ANSI - Latin-1 | 西欧 Windows GUI            |
| 65001  | UTF-8          | Unicode（推荐现代开发使用） |


## ✅ 总结：如何一劳永逸？

|步骤|操作|
|---|---|
|1️⃣|**启用 Windows 全局 UTF-8**（设置 → 区域 → 勾选 Beta 选项）|
|2️⃣|**配置 Git**：`git config --global core.quotepath false`|
|3️⃣|**所有编辑器保存为 UTF-8（无 BOM）**（Cursor/VS Code 默认如此）|
|4️⃣|**重启电脑**，让设置生效|

✅ 完成后，你在 **任何地方**（本地、GitHub、Cursor、Obsidian、终端）都能看到正确的中文，不再有乱码烦恼！