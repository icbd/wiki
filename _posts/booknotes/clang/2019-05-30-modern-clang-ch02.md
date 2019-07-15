---
layout: post
title:  Modern Clang Chapter-02
date:   2019-05-30
categories: Clang
---

```c
#include <stdio.h>

int main(void) {
    printf("To C, or not to C: that is the question.\n");

    return 0;
}
```

---

* 预处理: 处理指令, 来修改程序内容
* 编译: 程序 => 指令(目标代码)
* 链接: 整合目标代码和库函数


---

C 不支持连续赋值:

```
#include <stdio.h>

int main(void) {
    int a, b = 10;
    printf("\n%d\t%d\n", a, b);

    int aa = 9, bb = 10;
    printf("\n%d\t%d\n", aa, bb);

    return 0;
}
//
//271556662	10
//
//9	10
//
```

---

```
#include <stdio.h>

int main(void) {
    int a, b;
    scanf("a:%db:%d", &a, &b);

    printf("a+b=%d\n", a + b);

    return 0;
}
```

Clang 大小写敏感.

Clang 对标识符的最大长度没有限制.

关键字:

* auto
* break
* case
* char
* const
* continue
* default
* do
* double
* else
* enum
* extern
* float
* for
* goto
* if
* inline
* int
* long
* register
* restrict
* return
* short
* signed
* sizeof
* static
* struct
* switch
* typedef
* union
* unsigned
* void
* volatile
* while
* _Bool
* _Complex
* _Imaginary

Clang 编译器会把注释替换为一个空格字符.

main 函数中, `exit(0);` 和 `return 0;` 等效.

对于标量, `3.14` 表示 double 型, `3.14f` 表示 float .
