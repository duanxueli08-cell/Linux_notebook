```
#!/bin/bash

# 自动同步脚本：add -> commit -> push
echo "开始同步代码到远程仓库..."

# 添加所有更改
git add .
sleep 1

# 提交更改（使用默认提交信息）
git commit -m "Auto sync"
sleep 1

# 推送到远程仓库
git push
sleep 1

# 完成提示
echo ""
echo "✅ 同步完成！"
sleep 3  # 停顿3秒后自动关闭

# 如果是在 Git Bash 中双击运行，可能需要 exit 来关闭窗口
exit 0
```