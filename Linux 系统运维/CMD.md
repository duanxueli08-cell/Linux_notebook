要求：把所有在 F:\马哥教育\ 目录下以 “马哥教育M65期” 开头的文件名，改成以 “M65期” 开头，后面内容保持不变。
指令：
```powershell
Get-ChildItem "F:\马哥教育" -Filter "马哥教育M65期*" | Rename-Item -NewName {$_.Name -replace "^马哥教育M65期","M65期"}
```

```
接口列表
  5...b0 25 aa 2a e6 64 ......Realtek PCIe GbE Family Controller
 12...04 d3 b0 fd be b2 ......Microsoft Wi-Fi Direct Virtual Adapter
 10...00 50 56 c0 00 08 ......VMware Virtual Ethernet Adapter for VMnet8
 14...04 d3 b0 fd be b1 ......Intel(R) Wireless-AC 9462
 11...04 d3 b0 fd be b5 ......Bluetooth Device (Personal Area Network)
  1...........................Software Loopback Interface 1

# 查看网卡接口（无线14  ； 以太网5）
route print

# 临时路由（重启失效，做测试用）
route add 172.18.0.0 mask 255.255.0.0 172.18.0.1 if 5
route add 106.38.195.163 mask 255.255.0.0 192.168.0.1 if 14
# 永久路由
route add 172.18.0.0 mask 255.255.0.0 172.18.0.1 if 5 -p
route add 106.38.195.163 mask 255.255.0.0 192.168.0.1 if 14 -p
route add 111.225.214.23 mask 255.255.0.0 192.168.0.1 if 14 -p


# 删除路由
route delete 106.38.195.163
```