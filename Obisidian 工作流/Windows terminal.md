
### JSON 文件
---

```powershell
{
    "$help": "https://aka.ms/terminal-documentation",
    "$schema": "https://aka.ms/terminal-profiles-schema",
    "actions": [],
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "keybindings": 
    [
        {
            "id": "Terminal.CopyToClipboard",
            "keys": "ctrl+c"
        },
        {
            "id": "Terminal.PasteFromClipboard",
            "keys": "ctrl+v"
        },
        {
            "id": "Terminal.DuplicatePaneAuto",
            "keys": "alt+shift+d"
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
        "defaults": {},
        "list": 
        [
            {
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "commandline": "%SystemRoot%\\System32\\cmd.exe",
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "hidden": false,
                "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
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
    "schemes": [],
    "theme": "dark",
    "themes": []
}

```


### JSON 文件_美化
---
```powershell
{
    "$help": "https://aka.ms/terminal-documentation",
    "$schema": "https://aka.ms/terminal-profiles-schema",
    "actions": 
    [
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "id": "User.copy.644BA8F2"
        },
        {
            "command": "paste",
            "id": "User.paste"
        },
        {
            "command": "find",
            "id": "User.find"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "id": "User.splitPane.A6751878"
        }
    ],
    "alwaysOnTop": false,
    "copyFormatting": "none",
    "copyOnSelect": false,
    "defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "keybindings": 
    [
        {
            "id": "User.copy.644BA8F2",
            "keys": "ctrl+c"
        },
        {
            "id": "User.find",
            "keys": "ctrl+shift+f"
        },
        {
            "id": "User.paste",
            "keys": "ctrl+v"
        },
        {
            "id": "User.splitPane.A6751878",
            "keys": "alt+shift+d"
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
            "colorScheme": "Catppuccin Mocha",
            "cursorShape": "filledBox",
            "experimental.retroTerminalEffect": false,
            "font": 
            {
                "builtinGlyphs": true,
                "cellHeight": "1.2",
                "colorGlyphs": true,
                "face": "JetBrainsMono Nerd Font Mono",
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
                "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
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
    "themes": [],
    "useAcrylicInTabRow": true
}

```

### 网页地址

```powershell
https://github.com/fastfetch-cli/fastfetch

https://github.com/SleepyCatHey/Ultimate-Win11-Setup
```

```powershell
winget install fastfetch
```


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