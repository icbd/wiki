---
layout: post
title:  NaN and Infinity of double and float 
date:   2019-09-18
categories: Java
---

Java 中的 `float` 和 `double` 都是原始类型(primitive type), 存储空间分别为 4字节 和 8字节.

`3.14D` 和 `3.14d` 和 `3.14` 会被认为是 `double` 的;
 
`3.14F` 和 `3.14f` 会被认为是 `float` 的.


# 浮点数的无穷数和错误数

`3/0` 整型的3 除 0 会直接抛 `ArithmeticException`. 浮点型引入了无穷数和错误数的概念, 不会抛异常.

正的浮点数除零会得到 `Infinity`;

负的浮点数除零会得到 `-Infinity`;

零浮点数除除会得到 `NaN`;

对负浮点数开平方根会得到 `NaN`;


float 和 double 都引入了这三个常量:
```
    public static final float POSITIVE_INFINITY = 1.0f / 0.0f;
    public static final float NEGATIVE_INFINITY = -1.0f / 0.0f;
    public static final float NaN = 0.0f / 0.0f;
```

```
    public static final double POSITIVE_INFINITY = 1.0 / 0.0;
    public static final double NEGATIVE_INFINITY = -1.0 / 0.0;
    public static final double NaN = 0.0d / 0.0;
```

以下为 `true`:

`Double.NEGATIVE_INFINITY == Double.NEGATIVE_INFINITY`

`Double.NEGATIVE_INFINITY == Double.NEGATIVE_INFINITY * 2`

`Double.NEGATIVE_INFINITY == Float.NEGATIVE_INFINITY`

`Double.NEGATIVE_INFINITY == Float.NEGATIVE_INFINITY * 2`

`Double.NEGATIVE_INFINITY != Double.POSITIVE_INFINITY`

`Double.NaN != Double.NaN`

`Double.NaN != Float.NaN`

Java的浮点数中, 相同符号的 INFINITY 都相等, 任意两个 NaN 都不相等.
