# SSH 公钥认证失败故障复盘笔记

---

## 一、故障现象

- 用户无法通过 SSH 公钥认证登录目标服务器（`master1`）。
- 手动检查 `~/.ssh/authorized_keys` 文件内容，看似格式正常：
  ```
  ssh-rsa AAAAB3NzaC1yc2E... administrator@Shirley
  ```
- 但 SSH 登录时仍提示需要密码，或直接拒绝公钥认证。

---

## 二、初步排查

### 1. 常规检查项
| 检查项                                    | 结果       | 说明               |
| ----------------------------------------- | ---------- | ------------------ |
| `authorized_keys` 文件权限                | ✅ 600      | 符合要求           |
| `.ssh` 目录权限                           | ✅ 700      | 符合要求           |
| 公钥格式                                  | ⚠️ 表面正常 | 肉眼未见异常       |
| `sshd` 配置（`PubkeyAuthentication yes`） | ✅ 启用     | 服务端支持公钥认证 |

> ❗ 初步判断：**问题不在常规配置，而在文件内容本身存在“隐形”异常。**

---

## 三、深入分析：发现隐藏字符

### 1. 使用 `xxd` 查看十六进制内容
```bash
xxd .ssh/authorized_keys | head -n 1
```
输出：
```
00000000: efbb bf73 7368 2d72 7361 ...
```

🔍 **关键发现**：
- 开头三个字节 `ef bb bf` 是 **UTF-8 BOM（Byte Order Mark）** 的标准编码。
- 正常的 SSH 公钥应以 `73 73 68...`（即 ASCII 字符 `"ssh"`）开头。

### 2. 使用 `cat -A` 辅助验证
```bash
cat -A .ssh/authorized_keys
```
输出开头为：
```
M-oM-;M-?ssh-rsa ...
```
- `M-oM-;M-?` 是终端对非 ASCII 字节 `EF BB BF` 的乱码显示，进一步确认存在非法前缀。

### 3. 在 Vim 中尝试可视化
- 即使执行 `:set list`，也无法显示该 BOM 字符。
- 原因：Vim 的 `list` 模式仅处理 ASCII 空白字符（如 tab、行尾空格），**不识别 Unicode 控制字符或 BOM**。

> 🧠 **结论**：  
> **`authorized_keys` 文件开头存在 UTF-8 BOM（U+FEFF）**，导致 `sshd` 无法识别该行为有效公钥，从而忽略整行。

---

## 四、根本原因

### 引入 BOM 的可能途径：
- 使用 **Windows 记事本（Notepad）** 或某些图形化编辑器（如旧版 VS Code、WordPad）编辑或保存了 `authorized_keys` 文件。
- 这些工具在保存 UTF-8 文件时**默认添加 BOM**，而 Linux/Unix 系统及 SSH 协议**完全不兼容 BOM**。

> 💡 SSH 协议规范要求 `authorized_keys` 每行必须以合法密钥类型（如 `ssh-rsa`）开头，**任何前导字符（包括不可见字符）都会导致解析失败**。

---

## 五、解决方案

### 1. 删除 BOM
```bash
# 备份原文件
cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak

# 删除第一行开头的 BOM（EF BB BF）
sed -i '1s/^\xEF\xBB\xBF//' ~/.ssh/authorized_keys
```

### 2. 验证修复结果
```bash
# 检查开头是否干净
head -c 5 ~/.ssh/authorized_keys | xxd
```
✅ 期望输出：
```
00000000: 7373 682d 72                             ssh-r
```

### 3. 测试 SSH 登录
```bash
ssh -i ~/.ssh/id_rsa user@master1
```
→ 应能**无需密码直接登录**。

---

## 六、经验总结与预防措施

| 类别           | 建议                                                         |
| -------------- | ------------------------------------------------------------ |
| **编辑工具**   | ❌ 禁止使用 Windows 记事本编辑 SSH 密钥文件<br>✅ 推荐使用 `vim`、`nano`、VS Code（确保设置 `"files.encoding": "utf8"` 且无 BOM） |
| **文件传输**   | 使用 `scp`、`rsync` 或 `ssh-copy-id` 传输公钥，避免手动复制粘贴到带格式的编辑器 |
| **自动化检测** | 可编写脚本定期检查 `authorized_keys` 是否包含非法前缀：<br>`if head -c 3 file | xxd -p | grep -q '^efbbbf'; then echo "BOM detected!"; fi` |
| **权限与格式** | 始终确保：<br>- `.ssh` 目录权限为 `700`<br>- `authorized_keys` 权限为 `600`<br>- 文件无 BOM、无前导/尾随空格 |

---

## 七、附录：BOM 相关知识

| 编码         | BOM 字节序列 | 是否推荐用于 SSH/Shell 脚本 |
| ------------ | ------------ | --------------------------- |
| UTF-8        | `EF BB BF`   | ❌ 绝对禁止                  |
| UTF-16 BE    | `FE FF`      | ❌                           |
| UTF-16 LE    | `FF FE`      | ❌                           |
| 无 BOM UTF-8 | —            | ✅ 推荐                      |

> 📌 **Linux/Unix 系统下的所有配置文件、脚本、密钥文件都应使用无 BOM 的纯 ASCII 或 UTF-8 编码。**

---

**记录人**：运维工程师  
**日期**：2026年1月3日  
**关键词**：SSH、公钥认证失败、BOM、UTF-8、authorized_keys、sshd、不可见字符