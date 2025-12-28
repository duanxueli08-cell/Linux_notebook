# 笔记整理脚本
# 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$basePath = "C:\Program Files\Obsidian\data\Obsidian Vault"

# 创建目录结构
Write-Host "创建目录结构..."
$dirs = @(
    "重复文档",
    "草稿和临时文件",
    "01-基础知识\Linux系统运维",
    "02-容器与编排\Docker",
    "02-容器与编排\Kubernetes\基础概念",
    "02-容器与编排\Kubernetes\安全体系",
    "02-容器与编排\Kubernetes\故障排查",
    "02-容器与编排\Kubernetes\部署",
    "03-微服务架构\微服务基础",
    "03-微服务架构\网关与路由",
    "04-中间件\监控",
    "06-实验与实战\实验记录",
    "06-实验与实战\故障案例",
    "06-实验与实战\运维脚本",
    "07-面试与总结\面试笔记",
    "00-工具与模板\Templates",
    "00-工具与模板\脚本"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "创建目录: $dir"
    }
}

Write-Host "`n开始移动文件..."

# 移动重复文档
Write-Host "`n移动重复文档..."
$duplicates = @(
    @{Source = "Typora\微服务.md"; Dest = "重复文档\Typora-微服务.md"},
    @{Source = "SRE学习笔记\微服务.md"; Dest = "重复文档\SRE学习笔记-微服务.md"},
    @{Source = "Typora\D+J+P.md"; Dest = "重复文档\Typora-D+J+P.md"},
    @{Source = "SRE学习笔记\G+J+P.md"; Dest = "重复文档\SRE学习笔记-G+J+P.md"},
    @{Source = "搭建模型.md"; Dest = "重复文档\根目录-搭建模型.md"},
    @{Source = "Typora\搭建模型.md"; Dest = "重复文档\Typora-搭建模型.md"}
)

foreach ($dup in $duplicates) {
    $src = Join-Path $basePath $dup.Source
    $dst = Join-Path $basePath $dup.Dest
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "复制重复文档: $($dup.Source) -> $($dup.Dest)"
    }
}

# 移动草稿文件
Write-Host "`n移动草稿文件..."
$drafts = @(
    @{Source = "Linux 系统运维\草稿.md"; Dest = "草稿和临时文件\Linux系统运维-草稿.md"},
    @{Source = "Typora\初期_待整理\草稿纸.md"; Dest = "草稿和临时文件\Typora-草稿纸.md"},
    @{Source = "Linux 系统运维\草稿纸.canvas"; Dest = "草稿和临时文件\Linux系统运维-草稿纸.canvas"}
)

foreach ($draft in $drafts) {
    $src = Join-Path $basePath $draft.Source
    $dst = Join-Path $basePath $draft.Dest
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "复制草稿文件: $($draft.Source) -> $($draft.Dest)"
    }
}

Write-Host "`n文件移动完成！"
Write-Host "注意：原文件仍然保留，请检查新位置的文件后手动删除原文件。"

