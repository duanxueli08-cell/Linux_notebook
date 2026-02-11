



```powershell
#!/usr/bin/env python3
number = int(input("Enter an integer: "))
if number <= 100:
	print("Your number is less than or equal to 100")
else:
	print("Your number is greater than 100")
```



```powershell
#!/usr/bin/env python3
amount = float(input("Enter amount: "))
inrate = float(input("Enter Interest rate: "))
period = int(input("Enter period: "))
value = 0
year = 1
while year <= period:
	value = amount + (inrate * amount)
	print("Year {} Rs. {:.2f}".format(year, value))
	print("第 {} 年 {:.2f}" .format(year, value))
	amount = value
	year = year +1
```

> - 计算公式：本年金额 = 去年金额 + 去年金额 × 利率
>
>   - value = amount + (inrate * amount)
>
> - `float(input())` 的意思是：将用户输入的内容转换成小数类型（浮点数）。
>
> - 同理，`int(input())` 的意思是：将用户输入的内容转换成整数。
>
> - value 在第一次循环时一定会被重新计算；value = 0  这个只是占位，删除也不影响执行和计算；
>
> - `{:.2f}".format()` 这是 **Python 字符串格式化** 的一种写法。
>
>   - `{}` 表示一个占位符，需要被变量替换；
>
>   - `:` 表示开始指定格式
>
>   - `.2f` 表示小数点后保留 2 位 (`f = float`)
>
>   - ```powershell
>     "模板字符串".format(值1, 值2, 值3...)
>     "第 {} 年 金额 {:.2f}".format(year, value)
>     ```
>
>     