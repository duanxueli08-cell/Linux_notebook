
### 解释


#### 核心运行配置

- **`"commandline"`**: 指定启动该配置文件时运行的可执行程序路径。这里指向的是系统默认的 **Windows PowerShell 5.1**。
    
- **`"name"`**: 在下拉菜单和标签页上显示的名称。
    
- **`"guid"`**: 该配置文件的唯一标识符。系统通过这个 ID 来锁定该配置，建议不要手动随意修改。
    
- **`"hidden": false`**: 设置为 `false` 表示该选项会在下拉菜单中显示。如果设为 `true` 则会被隐藏。
    

#### 字体设置

- **`"font": { "face": "JetBrainsMono NF" }`**:
    
    - 这里使用了 **JetBrains Mono Nerd Font**。
        
    - **重要提示**：因为你打算配合 **Starship** 使用，Nerd Font（带有 `NF` 后缀）是必须的，因为它包含了 Starship 显示图标所需的各种特殊符号。
        

#### 背景图片自定义 (美化核心)

这段配置将你的终端从纯色背景变成了“壁纸模式”：

- **`"backgroundImage"`**: 图片文件的绝对路径（指向了你下载的一个村庄图片 `village.png`）。
    
- **`"backgroundImageOpacity": 0.3`**: 背景图片的**透明度**。`0.3` 表示图片比较淡（30% 可见度），这样不会干扰你看清前面的终端文字。
    
- **`"backgroundImageStretchMode": "uniformToFill"`**: 图片的缩放模式。`uniformToFill` 会按比例拉伸图片以填满整个窗口，超出部分会被裁切，这是最常用的壁纸填充方式。
    
- **`"backgroundImageAlignment": "topLeft"`**: 图片相对于窗口的对齐方式。这里设置在左上角。

#### 展示图

![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20251230220648508.png)


### JSON 文件

```powershell
{
    "$help": "https://aka.ms/terminal-documentation",
    "$schema": "https://aka.ms/terminal-profiles-schema",
    "actions": 
    [
        {
            "command": 
            {
                "action": "swapPane",
                "direction": "left"
            },
            "id": "User.swapPane.2A0DA8E0"
        },
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "id": "User.copy.644BA8F2"
        },
        {
            "command": 
            {
                "action": "moveFocus",
                "direction": "right"
            },
            "id": "User.moveFocus.87C324ED"
        },
        {
            "command": 
            {
                "action": "switchToTab",
                "index": 1
            },
            "id": "User.switchToTab.2A0DA8E0"
        },
        {
            "command": 
            {
                "action": "moveFocus",
                "direction": "previous"
            },
            "id": "User.moveFocus.75247157"
        },
        {
            "command": "toggleBlockSelection",
            "id": "User.toggleBlockSelection"
        },
        {
            "command": "paste",
            "id": "User.paste"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "id": "User.splitPane.A6751878"
        },
        {
            "command": "find",
            "id": "User.find"
        },
        {
            "command": 
            {
                "action": "moveTab",
                "direction": "forward"
            },
            "id": "User.moveTab.793E2350"
        },
        {
            "command": "closePane",
            "id": "User.closePane"
        },
        {
            "command": 
            {
                "action": "swapPane",
                "direction": "right"
            },
            "id": "User.swapPane.87C324ED"
        },
        {
            "command": 
            {
                "action": "moveFocus",
                "direction": "left"
            },
            "id": "User.moveFocus.2A0DA8E0"
        }
    ],
    "alwaysOnTop": false,
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "initialCols": 180,
    "initialRows": 50,
    "keybindings": 
    [
        {
            "id": null,
            "keys": "ctrl+shift+tab"
        },
        {
            "id": "User.copy.644BA8F2",
            "keys": "ctrl+c"
        },
        {
            "id": null,
            "keys": "ctrl+shift+d"
        },
        {
            "id": "User.splitPane.A6751878",
            "keys": "ctrl+v"
        },
        {
            "id": "User.find",
            "keys": "ctrl+shift+f"
        },
        {
            "id": null,
            "keys": "ctrl+comma"
        },
        {
            "id": "Terminal.OpenSettingsUI",
            "keys": "ctrl+s"
        },
        {
            "id": null,
            "keys": "alt+down"
        },
        {
            "id": null,
            "keys": "ctrl+shift+t"
        },
        {
            "id": "Terminal.SwitchToTab0",
            "keys": "alt+1"
        },
        {
            "id": null,
            "keys": "alt+f4"
        },
        {
            "id": "Terminal.CloseWindow",
            "keys": "ctrl+shift+w"
        },
        {
            "id": null,
            "keys": "ctrl+alt+left"
        },
        {
            "id": "User.closePane",
            "keys": "ctrl+w"
        },
        {
            "id": "User.paste",
            "keys": "shift+v"
        },
        {
            "id": null,
            "keys": "alt+shift+down"
        },
        {
            "id": null,
            "keys": "alt+enter"
        },
        {
            "id": "Terminal.SwitchToTab3",
            "keys": "alt+4"
        },
        {
            "id": null,
            "keys": "ctrl+numpad0"
        },
        {
            "id": null,
            "keys": "f11"
        },
        {
            "id": null,
            "keys": "ctrl+alt+2"
        },
        {
            "id": null,
            "keys": "ctrl+alt+9"
        },
        {
            "id": "Terminal.ToggleCommandPalette",
            "keys": "ctrl+p"
        },
        {
            "id": null,
            "keys": "ctrl+shift+p"
        },
        {
            "id": null,
            "keys": "ctrl+shift+m"
        },
        {
            "id": null,
            "keys": "alt+up"
        },
        {
            "id": null,
            "keys": "alt+right"
        },
        {
            "id": "Terminal.SwitchToTab2",
            "keys": "alt+3"
        },
        {
            "id": null,
            "keys": "ctrl+shift+6"
        },
        {
            "id": null,
            "keys": "ctrl+insert"
        },
        {
            "id": null,
            "keys": "enter"
        },
        {
            "id": "User.moveFocus.75247157",
            "keys": "alt+z"
        },
        {
            "id": null,
            "keys": "ctrl+alt+8"
        },
        {
            "id": null,
            "keys": "ctrl+shift+v"
        },
        {
            "id": null,
            "keys": "shift+insert"
        },
        {
            "id": null,
            "keys": "alt+shift+up"
        },
        {
            "id": null,
            "keys": "ctrl+alt+5"
        },
        {
            "id": null,
            "keys": "alt+shift+right"
        },
        {
            "id": null,
            "keys": "ctrl+alt+1"
        },
        {
            "id": null,
            "keys": "alt+shift+left"
        },
        {
            "id": "Terminal.SwitchToTab4",
            "keys": "alt+5"
        },
        {
            "id": "Terminal.OpenNewTab",
            "keys": "ctrl+n"
        },
        {
            "id": null,
            "keys": "ctrl+shift+9"
        },
        {
            "id": "User.moveFocus.75247157",
            "keys": "alt+x"
        },
        {
            "id": null,
            "keys": "ctrl+shift+8"
        },
        {
            "id": null,
            "keys": "ctrl+shift+7"
        },
        {
            "id": null,
            "keys": "ctrl+shift+5"
        },
        {
            "id": null,
            "keys": "ctrl+alt+3"
        },
        {
            "id": null,
            "keys": "ctrl+alt+7"
        },
        {
            "id": null,
            "keys": "ctrl+alt+4"
        },
        {
            "id": null,
            "keys": "ctrl+alt+6"
        },
        {
            "id": "User.switchToTab.2A0DA8E0",
            "keys": "alt+2"
        },
        {
            "id": null,
            "keys": "alt+shift+plus"
        },
        {
            "id": null,
            "keys": "alt+shift+minus"
        }
    ],
    "newTabMenu": 
    [
        {
            "type": "remainingProfiles"
        }
    ],
    "profiles": 
    {
        "defaults": 
        {
            "colorScheme": "Dark+",
            "cursorShape": "filledBox",
            "experimental.retroTerminalEffect": false,
            "font": 
            {
                "builtinGlyphs": true,
                "cellHeight": "1.2",
                "colorGlyphs": true,
                "face": "JetBrainsMono NF",
                "size": 10,
                "weight": "extra-black"
            },
            "intenseTextStyle": "all",
            "opacity": 80,
            "padding": "8",
            "useAcrylic": true
        },
        "list": 
        [
            {
                "backgroundImage": "C:\\Users\\Administrator\\Downloads\\village.png",
                "backgroundImageAlignment": "topLeft",
                "backgroundImageOpacity": 0.3,
                "backgroundImageStretchMode": "uniformToFill",
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "font": 
                {
                    "face": "JetBrainsMono NF"
                },
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": false,
                "name": "Command Prompt"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": false,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a999ec441b8}",
                "hidden": false,
                "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
                "startingDirectory": "%USERPROFILE%"
            }
        ]
    },
    "schemes": 
    [
        {
            "background": "#1E1E2E",
            "black": "#45475A",
            "blue": "#89B4FA",
            "brightBlack": "#585B70",
            "brightBlue": "#89B4FA",
            "brightCyan": "#94E2D5",
            "brightGreen": "#A6E3A1",
            "brightPurple": "#F5C2E7",
            "brightRed": "#F38BA8",
            "brightWhite": "#A6ADC8",
            "brightYellow": "#F9E2AF",
            "cursorColor": "#F5E0DC",
            "cyan": "#94E2D5",
            "foreground": "#CDD6F4",
            "green": "#A6E3A1",
            "name": "Catppuccin Mocha",
            "purple": "#F5C2E7",
            "red": "#F38BA8",
            "selectionBackground": "#585B70",
            "white": "#BAC2DE",
            "yellow": "#F9E2AF"
        },
        {
            "background": "#000000",
            "black": "#0C0C0C",
            "blue": "#0037DA",
            "brightBlack": "#767676",
            "brightBlue": "#3B78FF",
            "brightCyan": "#61D6D6",
            "brightGreen": "#16C60C",
            "brightPurple": "#B4009E",
            "brightRed": "#E74856",
            "brightWhite": "#F2F2F2",
            "brightYellow": "#F9F1A5",
            "cursorColor": "#FFFFFF",
            "cyan": "#3A96DD",
            "foreground": "#FFFFFF",
            "green": "#13A10E",
            "name": "Color Scheme 15",
            "purple": "#881798",
            "red": "#C50F1F",
            "selectionBackground": "#FFFFFF",
            "white": "#CCCCCC",
            "yellow": "#C19C00"
        },
        {
            "background": "#282A36",
            "black": "#21222C",
            "blue": "#BD93F9",
            "brightBlack": "#6272A4",
            "brightBlue": "#D6ACFF",
            "brightCyan": "#A4FFFF",
            "brightGreen": "#69FF94",
            "brightPurple": "#FF92DF",
            "brightRed": "#FF6E6E",
            "brightWhite": "#FFFFFF",
            "brightYellow": "#FFFFA5",
            "cursorColor": "#F8F8F2",
            "cyan": "#8BE9FD",
            "foreground": "#F8F8F2",
            "green": "#50FA7B",
            "name": "Dracula",
            "purple": "#FF79C6",
            "red": "#FF5555",
            "selectionBackground": "#44475A",
            "white": "#F8F8F2",
            "yellow": "#F1FA8C"
        }
    ],
    "tabWidthMode": "titleLength",
    "theme": "dark",
    "themes": [],
    "useAcrylicInTabRow": true
}

```


### 操作步骤

网页地址
```powershell
https://github.com/fastfetch-cli/fastfetch

https://github.com/SleepyCatHey/Ultimate-Win11-Setup

https://www.youtube.com/watch?v=z3NpVq-y6jU

https://www.nerdfonts.com/font-downloads
```

通过 winget 下载 
- 这个工具我是之前在微软官方网站下载的，这里就不多做赘述了！
```powershell
winget install fastfetch
```

开始之前需要安装 JetBrains Mono Nerd 字体；网址已经放在上面了！
- 右键安装 JetBrainsMonoNerdFont-Regular.ttf
- 安装完成一定要看该字体的实际名称哦！不然后面难搞……
- 为 WT 设置该字体；


- 进入你的用户文件夹：C 盘 —— 用户 —— 你的用户名 
- 该路径下有一个 .config 文件夹，没有就创建它！
	- 在该文件夹中创建一个文件夹：fastfetch
	- 将下面两个文件放在这个文件夹中；
	- 编辑 config.jsonc 文件将 C:/Users/Administrator 更改为自己的用户名
- 进入 C:\Users\Administrator\Documents\WindowsPowerShell 文件夹
- 打开 profile.ps1文件，将下面的 Microsoft.PowerShell_profile.ps1 文件拷贝进去；
	- 同样的依照上面的步骤更改为自己的用户名；


### config.jsonc 文件
---
```powershell
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "C:/Users/%USERPROFILE%/.config/fastfetch/ascii.txt",
    "color": {
      "1": "#F5E0DC",
      "2": "#F2CDCD",
      "3": "#F5C2E7",
      "4": "#FAB387",
      "5": "#F9E2AF",
      "6": "#A6E3A1",
      "7": "#94E2D5",
      "8": "#89DCEB",
      "9": "#74C7EC"
    },
    "padding": {
      "top": 1,
      "right": 3
    }
  },
  "display": {
    "separator": " "
  },
  "modules": [
    "break",
    {
      "type": "title",
      "color": {
        "user": "#F5C2E7",
        "at": "#CDD6F4",
        "host": "#89DCEB"
      }
    },
    "break",
    {
      "type": "os",
      "key": "",
      "keyColor": "#89DCEB"
    },
    {
      "type": "cpu",
      "key": "",
      "keyColor": "#F5C2E7"
    },
    {
      "type": "board",
      "key": "󰚗",
      "keyColor": "#FAB387"
    },
    {
      "type": "memory",
      "key": "",
      "keyColor": "#A6E3A1",
      "format": "{used} / {total} ({percentage})"
    },
    {
      "type": "disk",
      "key": "",
      "keyColor": "#94E2D5"
    },
    "break",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
```

### ascii.txt 文件
```powershell
$1⠀⠀⠀⠀⣀⡀
$1⠀⠀⠀⠀⣿⠙⣦⠀⠀⠀⠀⠀⠀⣀⣤⡶⠛⠁
$2⠀⠀⠀⠀⢻⠀⠈⠳⠀⠀⣀⣴⡾⠛⠁⣠⠂⢠⠇
$2⠀⠀⠀⠀⠈⢀⣀⠤⢤⡶⠟⠁⢀⣴⣟⠀⠀⣾
$3⠀⠀⠀⠠⠞⠉⢁⠀⠉⠀⢀⣠⣾⣿⣏⠀⢠⡇
$3⠀⠀⡰⠋⠀⢰⠃⠀⠀⠉⠛⠿⠿⠏⠁⠀⣸⠁
$4⠀⠀⣄⠀⠀⠏⣤⣤⣀⡀⠀⠀⠀⠀⠀⠾⢯⣀
$4⠀⠀⣻⠃⠀⣰⡿⠛⠁⠀⠀⠀⢤⣀⡀⠀⠺⣿⡟⠛⠁
$5⠀⡠⠋⡤⠠⠋⠀⠀⢀⠐⠁⠀⠈⣙⢯⡃⠀⢈⡻⣦
$5⢰⣷⠇⠀⠀⠀⢀⡠⠃⠀⠀⠀⠀⠈⠻⢯⡄⠀⢻⣿⣷
$6⠀⠉⠲⣶⣶⢾⣉⣐⡚⠋⠀⠀⠀⠀⠀⠘⠀⠀⡎⣿⣿⡇
$6⠀⠀⠀⠀⠀⣸⣿⣿⣿⣷⡄⠀⠀⢠⣿⣴⠀⠀⣿⣿⣿⣧
$7⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⠇⠀⢠⠟⣿⠏⢀⣾⠟⢸⣿⡇
$7⠀⠀⢠⣿⣿⣿⣿⠟⠘⠁⢠⠜⢉⣐⡥⠞⠋⢁⣴⣿⣿⠃
$8⠀⠀⣾⢻⣿⣿⠃⠀⠀⡀⢀⡄⠁⠀⠀⢠⡾ᵇʸ ᵗⁿᵏᵃ⠁
$8⠀⠀⠃⢸⣿⡇⠀⢠⣾⡇⢸⡇⠀⠀⠀⡞
$9⠀⠀⠀⠈⢿⡇⡰⠋⠈⠙⠂⠙⠢
$9⠀⠀⠀⠀⠈⢧
```


```powershell
$profile

New-Item -Path $profile.CurrentUserAllHosts -Type File -Force
```
### Microsoft.PowerShell_profile.ps1 文件
```powershell
# Minimal profile: UTF‑8 + Oh My Posh (if installed) + Fastfetch with explicit config path
try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host

# Force Fastfetch to use YOUR config every time (bypass path confusion)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "C:/Users/Administrator/.config/fastfetch/config.jsonc"
}
```


### WSL

#### 下载安装

- WSL（Windows Subsystem for Linux，Windows 子系统 for Linux）;
- 运行 Linux 命令行工具
- 与 Windows 文件系统无缝集成
- WSL 2 使用轻量级虚拟机技术，但性能接近原生 Linux，尤其在 I/O 和系统调用方面大幅优化。
- 无需额外配置 X Server。


```powershell
wsl --install
```

安装程序会自动：
启用“虚拟机平台”和“WSL”可选功能
下载并安装 WSL 2 Linux 内核
设置 WSL 2 为默认版本
默认安装 Ubuntu 发行版（来自 Microsoft Store）

重启后，会弹出一个终端界面自动下载安装 Ubuntu 系统
![](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20260103143906638.png)



系统会自动启动 Ubuntu 并提示你：
创建一个 Linux 用户名（可以和 Windows 用户名不同）
```
administrator
123123
```
设置 密码（输入时不会显示字符，正常输入后回车即可）
✅ 安装完成！之后你可以在开始菜单中找到 “Ubuntu” 或通过 wsl 命令进入 Linux 环境。

#### 优化

- 关闭侧通道缓解 (根据个人需求决定)

⚠️ 警告：关闭此功能会降低系统对 Spectre/Meltdown 等硬件级漏洞的防护能力。仅建议在隔离测试环境中操作。
```
# 禁用基于 Hypervisor 的侧通道缓解
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride" -Value 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverrideMask" -Value 3
```

```
# 恢复默认（如需重新启用）：
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride"
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverrideMask"
```

#### 回退

```
# 查看已安装的发行版：
wsl -l -v
# 逐个卸载每个发行版
wsl --unregister Ubuntu

# 卸载 WSL 内核
打开 设置 → 应用 → 已安装的应用
搜索 “Windows Subsystem for Linux Kernel”
卸载它（这是一个独立的 .msi 组件）
```

### SSH 认证

在 Windows 上生成密钥对
- 连续按 3 次回车（不设置密码，否则就达不到“自动登录”的效果）。
- 此时公钥和私钥已经保存在 C:\Users\你的用户名\.ssh\ 目录下。

```powershell
ssh-keygen -t rsa -b 4096
```

```powershell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh root@10.0.0.101 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && sed -i -e 's#.*ssh#ssh#' -e 's#Shirley.*#Shirley#' ~/.ssh/authorized_keys"

———— 批量追加密钥 ————

$ips = "104", "105", "106"
$pubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"

foreach ($ip in $ips) {
    Write-Host "正在处理 10.0.0.$ip ..."
    echo $pubKey | ssh "root@10.0.0.$ip" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && sed -i -e 's#.*ssh#ssh#' -e 's#Shirley.*#Shirley#' ~/.ssh/authorized_keys"
}
```

打开 Windows Terminal 设置 -> “打开 JSON 文件”。
在 profiles.list 里添加：( 确保 guid 的唯一性 )
==切记不要用 Windows 系统自带的 notepod ！Never Never Never==
```
{
    "name": "My_101"
    "commandline": "ssh root@10.0.0.101",
    "guid": "{0767c611-ea67-578b-8bb9-fdf7f75fcde3}",
}
```


### 操作

最有用的操作：

	上一个选项卡 / 下一个选项卡  =  切换窗格 
	新建标签页  = 新建窗格
	关闭窗格
	打开设置
	打开设置文件（JSON）
	重新启动连接



### 快捷键启动窗格

背景：
	我在之前设计了两个虚拟机的远程免密 SSH 认证，现在想要进一步做快捷键启动，系统有自定义的快捷键，但是敲击后无法生效！

解决经过：

- 修改默认终端应用程序
![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20260103182237146.png)

- 修改 JSON 文件，将 "keybindings" 字段下涉及到对应快捷键的空绑定删除！
![image.png](https://raw.githubusercontent.com/duanxueli08-cell/Obsidian-Images/main/img/20260103182415883.png)
