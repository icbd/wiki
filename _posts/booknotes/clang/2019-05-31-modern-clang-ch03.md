---
layout: post
title:  Modern Clang Chapter-03
date:   2019-05-31
categories: Clang
---

## printf

负号表示左对齐, 正号表示显示符号;
 
如果位数不足则如实显示.

`-10.3f`, 表示, 以浮点数显示, 至少显示10位, 小数点后保留3位(四舍五入) .
 

```
#include <stdio.h>

int main(void) {
    int num = 123456;
    printf("%10d\n", num);
    //    123456
    printf("%-10d\n", num);
    //123456

    printf("%3d\n", num);
    //123456
    printf("%-3d\n", num);
    //123456

    printf("%.10d\n", num);
    //0000123456

    return 0;
}
```


## scanf

```
#include <stdio.h>

int main(void) {
    int a, b;

    scanf("%d %d", &a, &b);
    printf("%d\t%d", a, b);

    return 0;
}
```

`scanf` 本质上模式匹配函数, 试图把输入的字符组与转换说明相匹配;

`scanf` 模板字符串中, 空格可以匹配输入的零个或任意多个空白字符;

`scanf` 会把不匹配的字符放回原处;

