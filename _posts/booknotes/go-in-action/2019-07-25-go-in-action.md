---
layout: post
title:  go-in-action
date:   2019-07-25
categories: golang
---

## Chapter1

> 目的是多核心时代高效编写网络应用程序

2007, Rob Pike, Robert Griesmier, Ken Thompson

Gopher

Golang 的特性和特点:

* 并发: goroutine, channel
* 类型: 组合, 鸭子类型(接口)
* 内存: 自动GC

## Chapter2

`main` 包中的 `main` 方法为程序的唯一入口.

每个文件都属于一个包.

惯例: 包跟目录同名.

同一个目录下的go文件必须使用同一个包名.

GO编译器不允许声明导入某个包缺不使用, 可以用 `_` 来接受这种导入.

每个go源文件的 `init()` 函数在main之前会自动调用.

小写字母开头的标识符仅包内可见, 大写字母开头的对包外公开. 如果非公开的数据结构经由公开方法返回, 那么调用者也可以访问.

编译器查找包的时候, 总是会到环境变量 `GOROOT` 和 `GOPATH` 引用的位置查找.

变量初始化为其零值.

`log.Fatal("Error Message")` 打印错误消息之后, 结束该程序.

切片 clice, 通道 channel, 映射 map 都是引用类型.

golang 中, 函数是 **第一类值**, 有类型, 有值, 变量能做的函数也能做.

函数的零值是 `nil`, 函数可以跟 `nil` 比较,  但是两个函数之间不能比较.

main 函数返回, 整个程序即停止运行. 停止后会关闭本程序内的所有 goroutine , 推荐手动清理 goroutine, 来避免 Bug .

golang 中, 所有变量传递都是值传递. 指针变量传递的是指针本身的值.

golang 支持匿名函数, 可以作为闭包使用. 闭包内可以访问其上下文的变量.

## Chapter3

`.go` 文件, 除空行和注释, 第一句应该申请自己所属的包.

每个包只能在一个单独的目录里; 同一个目录下的文件必须都属于同一个包.

包名习惯上跟目录名一致.

包名习惯使用简洁, 清晰 并且全小写.

Golang 的程序唯一入口是 `main` 包的 `main()` 方法.

## Chapter4

Golang 的数组是长度固定的.

Golang 声明变量时, 总会使用对应类型的零值来对变量进行初始化.
数组内的每个元素都初始化为对应类型的零值.

如果两个数组长度相同, 每个对应元素的类型相同, 那么这两个数组就是类型相同的数组, 可以进行相互赋值.

由于 Golang 的函数传参都是值传递, 也就是说如果参数是数组, 会把数组的每个原色都复制一份到参数. 推荐的做法是用数组指针.

切片可以自动增长和缩小. 切片有长度和容量的概念.

切片是对底层数组的包装, 操作的是底层数组.

`slice[i:j]` 左开右闭, 包含 `slice[i]`, 不包含 `slice[j]` .

对底层数组容量是 l 的切片 `slice[i:j:k]`:
 切片长度: j-i
 切片容量: k-i
k 为可选项, 默认等于 l .

append 函数会处理好底层数组的容量增长. 切片容量<1000时, 翻倍增长; 之后会增长为 1.25 倍.

64位机, 一个切片占用24byte, 8个byte存指针, 8个存长度, 8个存容量. 函数传切片, 只会复制切片不会复制下层的数组.

映射没有容量限制.

映射的key可以是任意类型.

## Chapter5

Golang 是静态类型的, 编译器在编译时需要知道每个值的类型.

类型向编译器传达两个信息: 这个值占了多少内存 和 这段内存表示什么.

| 类型 | 占用空间 |
| --- | --- |
| int64 | 8字节 (64位) |
| float32 | 4字节 (32位) |
| bool | 1字节 (8位) |
| int | 8字节(64位) 或者 4字节(32位) |

用结构体自定义类型:

```golang
	type user struct {
		name string
		age  int
		sex  string
	}

	xiaoMing := user{
		name: "Xiaoming",
		age:  20,
		sex:  "Boy",
	}

	xiaoHong := user{"Xiaohong", 19, "Girl"}
```

用已有的类型自定义类型:

`type mybigint int64`

新的类型是独立的类型, 他们之间不能相互赋值. 编译器不会对不同类型的值做隐式的转换.

Golang 内置类型: 数值, 字符串, 布尔. 对他们修改会创建新值, 传递都是按值传递.

引用类型: 切片, 映射, 通道, 接口, 函数.

|类型|零值|
|---|---|
|数值类型|0|
|字符串|""|
|布尔型|false|

`func (u user) notify() {}` user 是 notify 方法的接收者, Golang 用这种方式来绑定类型和方法.

`func (u user) notify() {}` 和 `func (u *user) notify() {}` 接收者也是类似值传递一样, 分 `值接收者` 和 `指针接收者` .


```golang
func (u user) improve1(add_points int) {
	u.point += add_points
}

func (u *user) improve2(add_points int) {
	u.point += add_points
}

func main() {
	user1 := user{"user1", 60}
	user1.improve1(20)
	fmt.Println(user1)
	//{user1 60}

	user2 := &user{"user2", 60}
	user2.improve1(20)
	fmt.Println(*user2)
	//{user2 60}

	user3 := user{"user3", 60}
	user3.improve2(20)
	fmt.Println(user3)
	//{user3 80}

	user4 := &user{"user4", 60}
	user4.improve2(20)
	fmt.Println(*user4)
	//{user4 80}
}
```

由此可见, 方法定义了值接收者, 会在复制的副本上执行; 方法定义了指针接收者, 会直接操作源数据.

无论变量是值本身还是值的指针, 调用方法都可以执行, 编译器会自动处理好.

***编译器会帮助指针值找到对应的对象, 然后再调用对象的方法; 但是不能帮助对象创建一个新的指针值.***

无论选哪种, 一致性很重要.

Golang 中, 继承的逻辑通过 struct 的嵌入类型实现.

Golang 允许公开方法返回非公开类型.

## Chapter6

Web 服务需要在各自独立的 socket 上同时接收多个请求;
每个 socket 都是独立的;
如果具有并行执行多个请求的能力, 可以显著提供系统性能.

通信顺序进程: CSP (Communicating Sequential Processes)

goroutine: 独立的工作单元.

channel: 用于 goroutine 之间同步和传递数据.
