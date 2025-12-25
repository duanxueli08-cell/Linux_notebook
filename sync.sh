#!/bin/bash
# 简单的错误检查：如果任一命令失败，则停止运行
set -e

echo "🚀 开始同步 K8S 笔记..."

# 执行 Git 指令
git add .

# 使用动态时间戳作为 commit message
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"

git push

echo "✅ 同步成功！数据已上传至 GitHub。"