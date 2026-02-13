# SSH 公钥认证失败故障复盘笔记（终极修订版）

---

## 一、故障现象

- 用户无法通过 SSH 公钥认证登录目标服务器（`master1`）。
- 手动检查 `~/.ssh/authorized_keys` 文件内容，**表面格式正常**：
  ```
  ssh-rsa AAAAB3NzaC1yc2E... administrator@Shirley
  ```
- 但 SSH 登录时提示需要密码，或直接拒绝公钥认证。

---

## 二、初步排查

| 检查项                                    | 结果       | 说明               |
| ----------------------------------------- | ---------- | ------------------ |
| `authorized_keys` 文件权限                | ✅ 600      | 符合要求           |
| `.ssh` 目录权限                           | ✅ 700      | 符合要求           |
| 公钥格式                                  | ⚠️ 表面正常 | 肉眼未见异常       |
| `sshd` 配置（`PubkeyAuthentication yes`） | ✅ 启用     | 服务端支持公钥认证 |

> ❗ 初步判断：**问题不在常规配置，而在文件内容本身存在“隐形”异常。**

---

## 三、深入分析：发现隐藏字符（关键突破）

### 1. 使用 `xxd` 确认 BOM
```bash
xxd .ssh/authorized_keys | head -n 1
```
输出：
```
00000000: efbb bf73 7368 2d72 7361 ...
```
✅ **证据**：开头 `ef bb bf` = **UTF-8 BOM（U+FEFF）**  
❌ 正常公钥应以 `73 73 68`（ASCII `"ssh"`）开头。

### 2. 为什么肉眼/普通工具看不到？
- **BOM 是 Unicode 控制字符**，非 ASCII 空白字符。
- `:set list`（Vim）和 `cat -A`（Linux）**无法显示 BOM**（仅处理 ASCII 0x00-0x1F）。
- `cat -A` 输出：`M-oM-;M-?ssh-rsa...` → **BOM 的乱码表示**。

---

## 四、根本原因：Windows 编码策略的致命陷阱

### 🔥 核心问题
> **Windows 10 1903+ 记事本默认保存文件为 "UTF-8 with BOM"**  
> → 导致 `authorized_keys` 文件开头多出 `EF BB BF`（BOM）字节。

### 🌐 为什么 Windows 会这样设计？
| Windows 编码特性             | 说明                                             | 与故障的关联                  |
| ---------------------------- | ------------------------------------------------ | ----------------------------- |
| **系统内核**                 | 使用 UTF-16 作为内部编码                         | 与 SSH 无关                   |
| **记事本（Notepad）**        | **Windows 10 1903+ 默认保存为 "UTF-8 with BOM"** | **直接导致 BOM 问题**         |
| **控制台（CMD/PowerShell）** | 默认使用本地代码页（如 GBK 936）                 | 与 SSH 无关                   |
| **BOM 用途**                 | 用于标识 UTF-8 文件（Windows 习惯）              | **在 Linux/SSH 中是致命错误** |

> 💡 **关键矛盾**：  
> Windows 推荐用 BOM 标识 UTF-8，但 **Linux/Unix 系统（包括 SSH）严格禁止 BOM**。

---

## 五、故障根源链（完整逻辑）

```mermaid
graph LR
A[用户在 Windows 10 1903+ 用记事本编辑公钥] --> B[记事本默认保存为 UTF-8 with BOM]
B --> C[文件开头插入 EF BB BF 字节]
C --> D[SSH 服务解析 authorized_keys]
D --> E[sshd 检测到非 ssh-rsa 开头的行]
E --> F[整行被忽略，公钥认证失败]
```

---

## 六、解决方案（含 Windows 专属修复）

### 1. 删除 BOM（立即执行）
```bash
# 备份原文件
cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak

# 删除开头的 BOM（仅作用于第一行）
sed -i '1s/^\xEF\xBB\xBF//' ~/.ssh/authorized_keys
```

### 2. 验证修复
```bash
head -c 5 ~/.ssh/authorized_keys | xxd
# ✅ 正确输出：00000000: 7373 682d 72  (ssh-r)
```

### 3. 修复 Windows 编辑习惯（预防复发）
| 操作           | 步骤                                                         |
| -------------- | ------------------------------------------------------------ |
| **VS Code**    | 1. 打开文件<br>2. 右下角点击编码 → **UTF-8**<br>3. 保存时自动移除 BOM |
| **Notepad++**  | 1. 编辑 → 编码 → **UTF-8**<br>2. 保存为 → **UTF-8 without BOM** |
| **避免记事本** | **永远不要用 Windows 记事本编辑 SSH 密钥文件**               |

> ⚠️ **重要提醒**：  
> Windows 10 1903+ 的记事本**已默认加 BOM**！这是故障的直接诱因。

---

## 七、经验总结与预防措施（全面升级）

| 领域           | 问题                           | 解决方案                                                     | 为什么有效                   |
| -------------- | ------------------------------ | ------------------------------------------------------------ | ---------------------------- |
| **文件创建**   | 用 Windows 记事本保存 SSH 密钥 | 用 VS Code/Nano 保存为 **UTF-8 without BOM**                 | 避免 BOM 生成                |
| **文件传输**   | 手动复制粘贴公钥               | 用 `ssh-copy-id` 或 `scp` 传输                               | 保持原始编码                 |
| **系统兼容性** | Windows BOM 与 Linux 冲突      | **全局启用 UTF-8**<br>(设置 → 语言 → Beta: 使用 Unicode UTF-8) | 使 Windows 与 Linux 编码统一 |
| **自动化检测** | 未检查文件编码                 | 添加脚本到 CI/CD：<br>`if head -c 3 file | xxd -p | grep -q '^efbbbf'; then echo "BOM detected!"; fi` | 事前拦截问题                 |
| **编码规范**   | 混淆 UTF-8 与 BOM              | **所有文本文件 = UTF-8 without BOM**<br>(Web/SSH/脚本/配置文件) | 一统江湖，避免冲突           |

---

## 八、Windows 编码知识速查（关键点）

| 项目                     | 说明                                                       | 与本故障的关联       |
| ------------------------ | ---------------------------------------------------------- | -------------------- |
| **Windows 默认文本编码** | 1903+ 记事本：**UTF-8 with BOM**<br>系统 API：UTF-16       | **BOM 是故障根源**   |
| **Linux 默认编码**       | **UTF-8 without BOM**                                      | SSH 服务要求此格式   |
| **BOM 是否有害**         | ❌ 在 Linux/SSH 中**绝对禁止**<br>✅ 在 Windows 中**被推荐** | **冲突点！**         |
| **如何避免 BOM**         | 保存时选择 **"UTF-8 without BOM"**                         | **修复本故障的核心** |

---

## 九、总结：一条铁律

> **在 Linux 服务器环境中，任何文本文件（包括 SSH 密钥、配置文件、脚本）必须使用 `UTF-8 without BOM` 编码。**  
> **Windows 用户必须主动配置编辑器移除 BOM（如 VS Code 默认行为），否则将导致无法排查的“隐形故障”。**

---

**记录人**：运维工程师  
**日期**：2026年1月3日  
**故障编号**：SSH-KEY-001  
**关键词**：UTF-8 BOM、Windows 记事本、SSH 公钥、编码冲突、预防措施

> 💡 **终极教训**：  
> **“BOM 是 Windows 的礼物，却是 Linux 的毒药”** —— 从此刻起，**永远在 Windows 编辑器中选择 "UTF-8 without BOM"**。