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
$GITHUB_REPO_URL = "https://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@github.com/duanxueli08-cell/Obsidian-Images.git"

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