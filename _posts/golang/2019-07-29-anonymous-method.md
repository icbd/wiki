---
layout: post
title:  Golang Anonymous Method
date:   2019-07-29
categories: golang
---

## Anonymous Method

在 Golang 中, 函数作为第一类值有着很灵活的使用方式. 简单的说, 变量能做什么, 函数就能做什么.

Golang 中匿名函数即闭包. 闭包可以直接使用其作用域内的变量, 闭包内的变量会一直被持有直到GC.

最基础的例子:

```go
package main

import "fmt"

func main() {
	a := 2
	b := 3

	anonymousFunc := func() int {
		a *= 10
		b *= 10

		return a + b
	}

	fmt.Println("anonymousFunc", anonymousFunc)
	fmt.Println("anonymousFunc()", anonymousFunc())
}
```

outputs:

```text
anonymousFunc 0x1093100
anonymousFunc() 50
```

`anonymousFunc` 内可以直接使用 `a` 和 `b`.

`anonymousFunc` 本身是一个引用类型, 它指向一个闭包(匿名方法).

打印 `anonymousFunc` 显示引用地址, 打印 `anonymousFunc()` 才显示运算结果.

`anonymousFunc` 即可以使用 `a` 和 `b` , 对他们的修改也会影响他们 `a` 和 `b` 本身的值, 修改上面例子:

```go
package main

import (
	"fmt"
)

func main() {
	a := 2
	b := 3
	fmt.Println("a:", a, "b:", b)
	anonymousFunc := func() int {
		a *= 10
		b *= 10

		return a + b
	}
	fmt.Println("a:", a, "b:", b)
	fmt.Println("anonymousFunc", anonymousFunc)
	fmt.Println("a:", a, "b:", b)
	fmt.Println("anonymousFunc()", anonymousFunc())
	fmt.Println("a:", a, "b:", b)
}

```

outputs:

```go
a: 2 b: 3
a: 2 b: 3
anonymousFunc 0x10934d0
a: 2 b: 3
anonymousFunc() 50
a: 20 b: 30
```

等闭包执行之后才改变了 `a` 和 `b` 的值.

再看这个例子, 展示了闭包内的变量是闭包环境变量中变量的引用:

```go
package main

import (
	"fmt"
)

func main() {
	a := 2
	b := 3
	anonymousFunc := func() int {
		a *= 10
		b *= 10

		return a + b
	}

	a = 5
	b = 6
	fmt.Println("anonymousFunc()", anonymousFunc())
}

```

outputs:
```text
anonymousFunc() 110
```

下面来看稍微复杂一点的例子, 当一个函数返回一个闭包的时候:

```go
package main

import "fmt"

func main() {
	a := 2
	b := 3

	fmt.Println("add(a, b)", add(a, b))
	fmt.Println("add(a, b)()", add(a, b)())
	
	fmt.Println("a:", a, "b:", b)
}

func add(a int, b int) func() int {
	anonymousFunc := func() int {
		a *= 10
		b *= 10

		return a + b
	}

	fmt.Println("anonymousFunc()", anonymousFunc(), "a:", a, "b:", b)

	return anonymousFunc
}
```

outputs:

```text
anonymousFunc() 50 a: 20 b: 30
add(a, b) 0x10933a0
anonymousFunc() 50 a: 20 b: 30
add(a, b)() 500
a: 2 b: 3
```

`add` 方法返回一个闭包, 也就是一个匿名方法的引用.

`add` 是引用, `add()` 是对匿名方法的调用.

由于函数传值都是按值传递的, 所以 `add` 的入参 `a` `b` 是按值赋值到 `add` 中的.
`add` 方法起到了隔绝标量变量的作用,
`anonymousFunc` 的操作不会影响回 `main` 中的 `a` `b` .

关于闭包对变量的引用, 我们再看一个很容易犯错的例子:

```go
package main

import "fmt"

func main() {
	var arr []func()

	// set arr
	for i := 0; i < 3; i++ {
		arr = append(arr, func() {
			fmt.Println("i:", i)
		})
	}

	// show arr
	for j := 0; j < 3; j++ {
		fmt.Println("\nj:", j)
		arr[j]()
	}
}

```

outputs:
```text

j: 0
i: 3

j: 1
i: 3

j: 2
i: 3
```

由此可见, j 是正常的, i的表现好像跟预期不一致?

`arr` 中的每个闭包中的 `i`, 都是原作用域中的 `i` 的引用, `i` 最后成了 3,
所以每个 `i` 打印出来都是 3.

那么如何避免这种情况呢?

方法一: 额外添加变量

```go
package main

import "fmt"

func main() {
	var arr []func()

	// set arr
	for i := 0; i < 3; i++ {
		var ii = i // 额外的变量
		arr = append(arr, func() {
			fmt.Println("ii:", ii)
		})
	}

	// show arr
	for j := 0; j < 3; j++ {
		fmt.Println("\nj:", j)
		arr[j]()
	}
}

```

方法二: 在外面再包装一个方法, 利用方法的参数按值传递的效应:

```go
package main

import "fmt"

func main() {
	var arr []func()

	// set arr
	for i := 0; i < 3; i++ {
		func(ii int) {
			arr = append(arr, func() {
				fmt.Println("ii:", ii)
			})
		}(i) // 以参数传入
	}

	// show arr
	for j := 0; j < 3; j++ {
		fmt.Println("\nj:", j)
		arr[j]()
	}
}

```

总之, 如果让闭包立即执行的话, 就会减少 Bug 的可能性. 但是很多时候就是利用闭包的延时执行能力, 那就要格外小心其中变量的引用问题.
