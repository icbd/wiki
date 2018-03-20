---
layout: post
title:  极简CSS实现五角星评级
date:   2017-07-15
categories: CSS
---

不用JavaScript,用极简的CSS代码实现五角星评级效果.
关键点在与如何保持住多个星星的选中效果. 
CSS3中有 `~` 选择符号, 表示连续选择.

## DEMO效果

<style type="text/css">
.rating {
    unicode-bidi: bidi-override;
    direction: rtl; /* 从右向左书写 */
    text-align: left;
    color: gold;
}

.rating > span {
    display: inline-block;
    position: relative;
    width: 2em;
    padding-right: 20px; /* 与rating的左对齐呼应 */
}

.rating > span:hover,
.rating > span:hover ~ span {
    color: transparent; /* 隐去原始颜色,防止重影 */
}

.rating > span:hover:before,
.rating > span:hover ~ span:before { /* ~ 兄弟选择符*/
    content: "★"; /* 或者使用unicode码 "\2605" */
    position: absolute;
    left: 0;
    top: 0;
    color: gold;
}
</style>
<div class="rating">
    <!--从右向左书写, 所以一星应在最右-->
    <span>☆</span><span>☆</span><span>☆</span><span>☆</span><span>★</span>
</div>



> HTML

```
<div class="rating">
    <span>☆</span><span>☆</span><span>☆</span><span>☆</span><span>☆</span>
</div>
```


# 思路

## step1

```
.rating > span:hover
{
    color: gold;
}
```

当hover时改变颜色, 但是不能把空心五角星改成实心的, 所以想到用伪类.

## step2

```
.rating > span {
    position: relative;
}

.rating > span:hover:before {
    content: "★";
    color: gold;
    position: absolute;
    top: 0;
    left: 0;
}
```

此时hover可以把空心五角星改为实心的, 但只能改当前选中的. 后面考虑用`~`连续选择出多个五角星.

## step3

```
.rating > span {
    position: relative;
}

.rating > span:hover:before,
.rating > span:hover ~ span:before {
    content: "★";
    color: gold;
    position: absolute;
    top: 0;
    left: 0;
}
```

当hover三星,  前三个星都应该亮起来, 想当然使用 `.rating > span:before ~ span:hover`.
但是这里有个问题, `~` 前是 `span:before` , 之后的选择只能同级或子级, 不能回到父级.
所以我们只能反过来写, 导致的后果就是选了三星, 是三/四/五这后三个星亮了.
解决方案是用 `direction` 把字的顺序倒过来.
注意, 这里只是改变了书写顺序, 其他样式还是和原来一样.

## step4 Finally

```
.rating {
    direction: rtl;
    text-align: left;
    color: gold;
}
.rating > span {
    position: relative;
    padding-right: 20px;
}

.rating > span:hover:before,
.rating > span:hover ~ span:before {
    content: "★";
    color: gold;
    position: absolute;
    top: 0;
    left: 0;
}
```

如果需要给默认星级, 应该从最右边的span改起.

> more: https://css-tricks.com/star-ratings/