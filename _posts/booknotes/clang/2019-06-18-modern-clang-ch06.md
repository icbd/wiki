---
layout: post
title:  Modern Clang Chapter-06
date:   2019-06-18
categories: Clang
---

# 循环

`while(0) {//nothing}` 



`while(1) {//always}`

条件为整型 0 时, 跳过block;  条件为非0 时, 进入block;



C99中, 如果变量在 for 的第一个语句内声明, 则该变量仅用于该for. 如果之前已经声明相同的变量, 也不会干扰for内的变量.

```c
#include <stdio.h>

int main(void) {


    int i = 1000, j = 999;
    printf("i:%3d\tj:%3d\n", i, j);
    printf("---\n");

    for (int i = 1, j = 10; i < j; i *= 2, j += 2) {
        printf("i:%3d\tj:%3d\n", i, j);
    }

    printf("---\n");
    printf("i:%3d\tj:%3d\n", i, j);


    return 0;
}

//i:1000	j:999
//---
//i:  1	j: 10
//i:  2	j: 12
//i:  4	j: 14
//i:  8	j: 16
//i: 16	j: 18
//---
//i:1000	j:999
```





for 判断条件为空时, 默认为真:

```
for(;;) {
  // sth...
}
//等价于
while (a < 5) {
	// sth...
}
```



`,` 逗号, 拥有最低的运算优先级.



`break` 只能跳出一层嵌套.



break 把程序控制转移到循环体末尾之后(跳出循环), continue 把程序控制转移到循环体末尾之前(留在循环内).



`continue` 不能用于 switch, 只能用于 for 和 while.



