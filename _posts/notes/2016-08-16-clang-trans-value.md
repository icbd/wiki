---
layout: post
title:  C语言 参数传递,值传递,地址传递,引用传递?
date:   2016-08-16
categories: Clang
---

C语言函数传参到底有几种?!

就一种, 按值传递!

首先, C语言里不存在引用传递的方式(注释掉的ex3,编辑就过不了).

习惯说的按值传递和地址传递实质上都是`值传递`,只不过前者传的是int值,后者传的是指针值.

看代码就一目了然了.


```
//
//  main.c
//  exchange
//
//  Created by cbd on 16/8/16.
//  Copyright © 2016年 cbd. All rights reserved.
//

#include <stdio.h>


void ex1(int, int);
void ex2(int *, int *);


int main(int argc, const char * argv[]) {
    int a = 4;
    int b = 6;
    printf("originally,a:%d,b:%d\n",a,b);
    ex1(a, b);
    printf("finally,a:%d,b:%d\n\n",a,b);

    int aa = 44;
    int bb = 66;
    printf("originally,aa:%d,bb:%d\n",aa,bb);
    ex2(&aa, &bb);
    printf("finally,aa:%d,bb:%d\n\n",aa,bb);

    return 0;
}

void
ex1(int x, int y){
    int temp = x;
    x = y;
    y = temp;

    printf("ex1按值传递, x:%d,y:%d\n", x, y);
}

void
ex2(int *x, int *y){
    int temp = *x;
    *x = *y;
    *y = temp;

    printf("ex2地址传递, x:%d,y:%d\n", *x, *y);
}

/*
c 语言没有引用传递

void
ex3(int &x, int &y){
    int temp = x;
    x = y;
    y = temp;

    printf("ex3引用传递, x:%d,y:%d\n", x, y);
}
 */

```

## 结果输出

```
originally,a:4,b:6
ex1 值传递, x:6,y:4
finally,a:4,b:6

originally,aa:44,bb:66
ex2地址传递, x:66,y:44
finally,aa:66,bb:44

Program ended with exit code: 0

```
