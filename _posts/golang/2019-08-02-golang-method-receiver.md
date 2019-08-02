---
layout: post
title:  Golang method receiver
date:   2019-08-02
categories: golang
---

```ruby
class User
  attr_reader :name, :age

  def initialize(name:, age:)
    @name = name
    @age = age
  end

  def happy_birthday
    puts 'Happy Birthday:)'

    @age += 1
  end
end

xiao_ming = User.new(name: '小明', age: 18)
xiao_ming.happy_birthday
puts xiao_ming.age
```

这是一段 Ruby 代码, 很清楚地展示了 User 里的数据(name, age)和方法(happy_birthday).

对于 Golang , 如果想要实现 `xiao_ming.happy_birthday`: 向 `xiao_ming` 发送 `happy_birthday` 消息, 需要写成下面这样:

```golang
package main

import (
	"fmt"
)

type User struct {
	name string
	age  int
}

func (user User) HappyBirthday() {
	fmt.Println("Happy Birthday:)")
	user.age += 1
}

func (user *User) UnhappyBirthday() {
	fmt.Println("Unhappy Birthday:(")
	user.age += 1
}

func main() {
	xiaoMing := User{"小明", 18}
	xiaoMing.HappyBirthday()
	fmt.Println(xiaoMing.age)

	xiaoHong := User{"小红", 18}
	xiaoHong.UnhappyBirthday()
	fmt.Println(xiaoHong.age)
}

```

Golang 中, 参数是按值传递的, 接收者亦然. `HappyBirthday` 方法的接收者是 `User` 类型本身, 也就是说会复制一份然后在副本上调用方法; `UnhappyBirthday` 方法的接收者是 `*User` 引用类型, 通过指针来操作原始数据. 所以以上的outputs:

```text
小明 18
18
小红 18
19
```

Golang 的编译器对引用类型比较宽容, 我们要求 `UnhappyBirthday` 的接收者是一个指针, 但是 `xiaoHong` 是一个 `User` 变量, 不是指针, 这种情况下也可以正常工作.

如何选择呢?

当需要修改当前值时, 使用指针接收者;

当需要创建一个新的对象时, 使用值接收者.
