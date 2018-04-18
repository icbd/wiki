---
layout: post
title:  jQuery和CSS选第几个元素
date:   2018-04-18
categories: notes
---

```
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <style>
        li.hi:nth-of-type(2) {
            background-color: orange;
        }
    </style>
</head>
<body>

<ul class="no1">
    <br class="hi"/>
    <br class="hi"/>
    <li class="hi">1</li>
    <li>2</li>
    <li class="hi">3</li>
    <li class="hi">4</li>
</ul>
<ul class="no2">
    <br/>text
    <br/>
    <li>1</li>
    <li class="hi">2</li>
    <li>3</li>
    <li>4</li>
</ul>

<script
        src="http://code.jquery.com/jquery-3.3.1.min.js"
        integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
        crossorigin="anonymous"></script>
<script>
    $(function () {

        // JQuery串连操作: 先选出所有 li 得到一个数组, 再选择数组下标为 3 的元素, 即第四个 li
        $("li:eq(3)").css('color', "red");

        // CSS选择器: 选择 li, 并且要求该 li 是第3个子元素.
        // 子元素可以是其他非li元素和文本元素
        $("li:nth-child(3)").css('font-size', "2em");

        // CSS选择器: 选择 li, 并且要求该 li 是第 3 个 li 元素.
        $("li:nth-of-type(3)").css('font-weight', "900");



        // CSS选择器: 选择 li, 并且要求该 li 有 hi 类, 并且要求该 li 是第 3 个子元素
        $("li.hi:nth-child(3)").css('border', '1px solid green');

        // Jquery串连操作: 先选出所有 li.hi 得到一个数组, 再选择数组下标为 3 的元素, 即第四个 li:hi
        $("li.hi:eq(3)").css('border', '1px solid green');
    });
</script>
</body>
</html>
```