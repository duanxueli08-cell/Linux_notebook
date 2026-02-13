### 背景说明
```python
- 我不需要 Windows 更新，但是我需要使用 Windows商店；
- 所以这个就导致我不能禁用Windows更新策略！
  - 这里推荐一个软件：Windows Update Blocker
    这个软件可以禁用 Windows 更新，非常稳定，而且干净简洁；
- 这里我是不需要这个软件的！要达到我的需求，最方便的就是修改注册表！
```


### 解决问题经过

使用 Gemini_Pro 一步到位

##### Gemini_Pro
```
### 操作步骤：解锁“无限期”暂停

我们需要修改注册表中的 `FlightSettingsMaxPauseDays` 值。

1. **打开注册表编辑器：**
按下 `Win + R`，输入 `regedit`，回车。
2. **定位路径：**
在地址栏粘贴以下路径并回车：
`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings`
3. **新建/修改键值：**
* 在右侧空白处，右键 -> **新建** -> **DWORD (32位) 值**。
* 命名为：`FlightSettingsMaxPauseDays`


4. **修改数值（关键一步）：**
* 双击你刚才创建的 `FlightSettingsMaxPauseDays`。
* **基数**选择：**十进制** (Decimal)。
* **数值数据**输入：`1825` （这是 5 年的天数，甚至你可以填 `3000`）。
* 点击确定。


5. **重启设置或电脑：**
为了确保生效，建议重启一下电脑，或者直接去任务管理器里重启 `Windows Explorer`。
6. **见证奇迹：**
* 打开 **设置** -> **Windows 更新**。
* 点击 **“暂停更新”** 旁边的下拉箭头，或者进入 **“高级选项”** -> **“暂停更新”**。
* 你会发现下拉菜单里，现在可以把日期选到 **2031年** 甚至更久之后了！
* **选中那个最远的日期。**



### 为什么这个方案完美符合你的需求？

* **微软商店 (Microsoft Store)：** ✅ **可用**。
因为 Windows Update 服务 (`wuauserv`) 依然是“正在运行”的状态，商店可以正常调用它来下载应用。
* **系统补丁：** ⏸️ **已暂停**。
系统会乖乖听话，直到你选定的那个 2031 年的日期到来之前，都不会自动给你推送系统更新。
* **手动控制：**
如果你哪天突然想更新了，只需要去设置里点一下“恢复更新”即可，非常灵活。

---
```

补充技巧：如何防止微软“耍流氓”重置它？

> 虽然上面的这个方法很稳，但微软有时候的大版本升级（Feature Update）会重置注册表。
	既然你会写脚本，我建议你把这个注册表修改保存为一个 `.reg` 文件，或者写个简单的 `.bat` 脚本放在桌面备用。如果哪天发现暂停失效了，双击运行一下脚本，然后去设置里重新选一下日期即可。

**BAT 脚本内容（以管理员身份运行）：**

```batch
@echo off
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v FlightSettingsMaxPauseDays /t REG_DWORD /d 2000 /f
echo 已将最大暂停天数修改为 2000 天！
pause

```

这个方案既保留了商店功能，又给了你长达数年的清净，是目前最平衡的解法。
