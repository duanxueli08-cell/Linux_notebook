- ### shell编程


##### if

> **嵌套 if**：条件之间是 **逐级递进、层层限制** 的关系。
>
> **if 里嵌套 elif**：在某个条件成立的前提下，进行 **多分支互斥选择**。

```powershell
if [ "$周树人" = "$鲁迅" ]; then
	echo "对，是我说的！"
	if [ "$鲁达" = "$周树人" ]; then
		echo "可以把周树人抓起来了"
	else
		echo "把鲁迅抓起来！"
	fi
elif [ "$鲁迅" = "$周迅" ]; then
	echo "抓捕周迅"
	if [ "$周迅" = "star" ]; then
		echo "将错就错"
	else
		echo "放人"
	fi
else
	echo "这不是我说的"
fi

		
if [[ "$OS" =~ ^(rocky|centos|rhel)$ ]]
[[ ... ]]
	• 这是 Bash 的高级条件测试，比 [ ... ] 功能更强。
	• 支持正则匹配、模式匹配等。
=~
	• 表示 正则表达式匹配。
	• 左边是字符串，右边是正则表达式。
如果字符串满足正则，条件为真（true），否则为假（false）


```

##### case

> **if**：适合做逻辑判断（大于/小于/组合条件）
>
> **case**：适合做 **等值匹配、模式匹配**，特别是对字符串匹配更直观

```powershell
case 变量 in
    模式1)
        命令1
        ;;
    模式2)
        命令2
        ;;
    模式3|模式4)   # 多个模式用 | 隔开
        命令3
        ;;
    *)
        默认命令    # 相当于 else
        ;;
esac

case … esac 是成对出现的（注意：esac 就是 case 倒过来）
每个模式后面跟 )
分支语句最后必须以 ;; 结束
* 表示默认匹配（类似 else）

```

##### for

```powershell
1. 列表循环（最常见）
for 变量 in 值1 值2 值3 ... 值N
do
    命令
done
# 变量 会依次取列表中的每个值
# 常用于遍历字符串、文件名、命令结果
******************
```

```powershell
2. 遍历命令结果
可以结合命令替换 `command` 或 $(command)：
for file in $(ls /etc/*.conf)
do
    echo "找到配置文件: $file"
done
******************
```

```powershell
3. C 风格 for（和 C 语言一样）
for (( 初始化; 条件; 递增 ))
do
    命令
done

示例：
for ((i=1; i<=5; i++))
do
    echo "第 $i 次循环"
done
```



##### 表达式

```powershell
[ ]：条件判断（字符串、数字比较等）。[]中的条件需要左右有空格，且不能省略。
-f：	检查文件是否存在且为普通文件。
-d：	检查文件是否存在且为目录。
=：	字符串相等。
-eq：数字相等。
-gt：数字大于。
-lt：数字小于。

{} 用来组织命令、进行范围扩展，或者表示函数体、控制结构等。
命令之间必须用分号 ; 分隔，或者换行。
{} 内的命令会在同一个 shell 环境下执行，不产生子进程。

[[]] 是 扩展的条件测试，提供比 [] 更强大的功能。
[[]] 是 Bash 和其他现代 shell 特有的扩展（非 POSIX 标准）。
[[]] 中不需要对某些特殊字符（如 <、>）进行转义，[] 中需要转义。
字符串比较：可以使用 == 和 !=，且支持通配符。
正则表达式：可以使用 =~ 进行正则匹配。
逻辑运算符：可以直接使用 && 和 || 进行多个条件的判断。


解释2>&1 &
2>&1
👉 把 标准错误输出 (stderr) 重定向到 标准输出 (stdout) 的位置。
效果：stdout 和 stderr 会合并。
再看 &
👉 把命令放到 后台运行。
后台进程会得到一个 作业号 (job id) 和 进程号 (PID)。
```

##### 函数

**封装代码块**，实现**功能复用**和组织

###### 示例一

```postgresql
#!/bin/bash
# 日志备份脚本
# 执行脚本后，会将 /var/log 目录下的 .log 文件打包成一个带时间戳的压缩包，存放在 /tmp 目录下。
# 定义函数：实现备份
backup_logs() {
    src_dir=$1      # 源目录
    dst_dir=$2      # 目标目录
    timestamp=$(date +"%Y%m%d_%H%M%S")

    # 检查源目录是否存在
    if [ ! -d "$src_dir" ]; then
        echo "源目录不存在: $src_dir"
        return 1	# 如果源目录不存在，函数返回1，后续的命令不会执行
    fi

    # 创建目标目录
    mkdir -p "$dst_dir"

    # 打包备份
    tar -czf "$dst_dir/logs_backup_$timestamp.tar.gz" "$src_dir"/*.log 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ 备份成功: $dst_dir/logs_backup_$timestamp.tar.gz"
    else
        echo "❌ 备份失败"
    fi
}

# 调用函数
backup_logs "/var/log" "/tmp"

```

##### expect自动化

```powershell

set 设定环境变量
	格式：set 变量名 变量值
send 接收一个字符串参数，并将该参数发送到新进程。
	样式：send "$password\r"
expect 识别用户输入的位置关键字
	格式：expect "yes"
spawn 启动新的进程，模拟手工在命令行启动服务
	样式：spawn ssh python@$host
	


```

##### 颜色

```powershell
前景色（文本颜色）	
颜色	代码
黑色	30		白色	37
红色	31		绿色	32
黄色	33		蓝色	34
紫色	35		青色	36
默认	0

PS1='\[\e[31m\]\u@\h\w:$\[\e[0m\]'
```



##### 变量

```powershell
 变量格式：
本地变量：变量名=变量值
全局变量：export		变量名=变量值
局部变量：local      变量名=变量值
普通变量：变量名="字符串"
命令变量：
	定义一：变量名=$(命令)       #建议用这个
	定义二：变量名=`变量名`      #注意这是反引号
	
查看所有的全局变量：env    |   grep   变量名
删除变量：unset   变量名

TOOLS=("net-tools" "vim" "curl" "wget" "git")
这是 Bash 的数组变量定义，不是普通字符串变量。
• 在 Bash 里，圆括号 () 表示创建一个数组。
• 数组里的元素用 空格 分隔。
给元素加上双引号，保证字符串里即使有空格，也会被当成一个整体。
```



