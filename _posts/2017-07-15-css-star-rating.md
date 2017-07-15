---
layout: post
title:  极简CSS实现五角星评级
date:   2017-07-15
categories: CSS
---

不用JavaScript,用极简的CSS代码实现五角星评级效果.

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

```
<div class="rating">
    <!--从右向左书写, 所以一星应在最右-->
    <span>☆</span><span>☆</span><span>☆</span><span>☆</span><span>★</span>
</div>
```

```
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

```