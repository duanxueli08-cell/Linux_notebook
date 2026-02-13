## Win10 LSTC 版本安装-微软商店安装包🍖

> 补充说明：Windows 10 LSTC 长期服务通道，专注于极致的稳定性和低维护，**默认不包含微软商店** 和许多内置应用。
>
> **21H1, 21H2, 22H2**：半年度频道版本，面向普通消费者和大多数企业，功能持续更新，**始终包含微软商店**。
>
> | 特性         | **LTSC 2019 / 2021**                                         | **21H1**                                            | **21H2**                                            | **22H2**                                                 |
> | :----------- | :----------------------------------------------------------- | :-------------------------------------------------- | :-------------------------------------------------- | :------------------------------------------------------- |
> | **目标用户** | 关键任务设备、工业控制系统、专用设备（如ATM、医疗设备）      | 普通消费者、办公用户、大多数企业                    | 普通消费者、办公用户、大多数企业                    | 普通消费者、办公用户、大多数企业                         |
> | **更新模式** | **5年主流支持 + 5年扩展支持**，**不**接收功能性更新，只接收安全更新 | **18个月服务周期**，定期接收新功能和安全更新        | **18个月服务周期**，定期接收新功能和安全更新        | **最终版本，支持至2025年10月14日**                       |
> | **微软商店** | **默认不包含**（但可手动安装）                               | **包含**                                            | **包含**                                            | **包含**                                                 |
> | **内置应用** | 极度精简，**无**Cortana、无Edge（经典版）、无天气、新闻等    | 完整，包含Cortana、Edge浏览器、相机、照片等全套应用 | 完整，包含Cortana、Edge浏览器、相机、照片等全套应用 | 完整，包含Cortana、Edge浏览器、相机、照片等全套应用      |
> | **新功能**   | **冻结**在发布时的状态，不添加新功能                         | 包含截至2021年5月的所有功能                         | 在21H1基础上小幅度更新，主要是安全性和质量改进      | 在21H2基础上小幅度更新，是21H2的一个启用包，核心功能一致 |
> | **系统要求** | 与对应基础版本一致                                           | 与早期版本如1909一致                                | 与21H1基本一致                                      | 与21H2基本一致                                           |
> | **基于内核** | LTSC 2019 基于 1809 LTSC 2021 基于 21H2                      | 基于 20H2                                           | 基于 21H1                                           | 基于 21H2                                                |

### 安装微软商店安装包的步骤

1.首先打开网页 https://store.rg-adguard.net/，在这个网页上可以下载到 Windows 应用商店的安装包。
2.在搜索框输入 https://www.microsoft.com/en-us/p/microsoft-store/9wzdncrfjbmp（这是 Windows 应用商店的网页地址），并选择Retail
3.下载如下资源包：

```powershell
Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx
Microsoft.NET.Native.Runtime.1.7_1.7.27422.0_x64__8wekyb3d8bbwe.Appx
Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.Appx
Microsoft.VCLibs.140.00_14.0.30704.0_x64__8wekyb3d8bbwe.Appx
Microsoft.WindowsStore_22207.1401.1.0_neutral___8wekyb3d8bbwe.Msixbundle
```

> 除了 Windows 应用商店的安装包外，还有其他的安装包，这些安装包是依赖包
>
> 由于 Microsoft Store 应用依赖于 .NET Framework、.NET Runtime、Microsoft.UI.Xaml 和 VC Libs，因此请下载列出的每个项的最新包。
>
> - 有些包是 Appx 后缀，也有 Msixbundle
> - 请忽略 BlockMap 后缀的文件
> - 注意选择最新版本
> - 注意选择正确的构架（一般是 `x64`）



4.以**管理员权限**打开 PowerShell ，使用如下指令一次安装

```powershell
Add-AppxPackage -Path "E:\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx"

Add-AppxPackage -Path "E:\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx"

Add-AppxPackage -Path "E:\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.Appx"

Add-AppxPackage -Path "E:\Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx"

Add-AppxPackage -Path "E:\Microsoft.WindowsStore_22508.1401.8.0_neutral_~_8wekyb3d8bbwe.Msixbundle"
```

> 如果您收到错误，请跳过该包。这很可能是因为包或依赖项已安装，并且当前正在由其他应用程序使用。`Deployment failed with HRESULT: 0x80073D02`

此外，还可以运行以下命令来检查是否已安装应用包：

```powershell
get-appxpackage | sort-object -Property PackageFullName | select packagefullname | out-gridview
```

如果已安装（相同版本的）包，则无需再次安装。



5.若要验证 Microsoft Store 应用信息，请打开 PowerShell（管理员）窗口并运行以下命令：

```powershell
Get-AppxPackage Microsoft.WindowsStore
```

```powershell
Name              : Microsoft.WindowsStore
Publisher         : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
Architecture      : X64
ResourceId        :
Version           : 22508.1401.8.0
PackageFullName   : Microsoft.WindowsStore_22508.1401.8.0_x64__8wekyb3d8bbwe
InstallLocation   : C:\Program Files\WindowsApps\Microsoft.WindowsStore_22508.1401.8.0_x64__8wekyb3d8bbwe
IsFramework       : False
PackageFamilyName : Microsoft.WindowsStore_8wekyb3d8bbwe
PublisherId       : 8wekyb3d8bbwe
IsResourcePackage : False
IsBundle          : False
IsDevelopmentMode : False
NonRemovable      : False
Dependencies      : {Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe, Microsoft.NET.Native.Runtime.2.
                    2_2.2.28604.0_x64__8wekyb3d8bbwe, Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbw
                    e, Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe...}
IsPartiallyStaged : False
SignatureKind     : Store
Status            : Ok
```

> 你将看到 Microsoft Store 应用及其依赖项已完全安装。
>
> *本文适用于 Windows 10 和 Windows 11。*

