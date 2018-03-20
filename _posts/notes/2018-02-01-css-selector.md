---
layout: post
title:  CSS Selector Collection
date:   2018-02-01
categories: CSS
---

## CSS 选择器小结

|实例|描述|
|---|---|
|`*`| 统配所有|
|`div`| 所有div标签|
|`div,p`| 所有div和p|
|`.class-name`| 含有 class-name 类的所有标签|
|`div.class-name`| 含有 class-name 类的div|
|`.class1.class2`| 同时含有 class1 和 class2 的所有标签|
|`#id_name`| ID 为 id_name 的任意标签.(全页面唯一)|
|`div#id_name`| ID 为 id_name 的 div.(全页面唯一)|
|`img[alt]`| 含有 alt 属性的 img 标签.(alt可以为空字符串)|
|`[href]`| 所有含有href属性的标签.(href可以为空字符串)|
|`[lang|="zh"]`| lang 属性值为 `zh` 或 以 `zh-` 开头.("zh"和"zh-"和"zh-CN"和"zh- CN" 可以匹配, " zh"和" zh "和"zh "和"hi zh"不能匹配)|
|`[data-type~="good"]`| `data-type` 属性值由空格切分, 含有 good 的所有标签|
|`[data-type*="good"]`| 属性值中字符串含有子串 `good` 的所有标签|
|`[data-type^="good"]`| 属性值以 `good` 开头的标签|
|`[data-type$="good"]`| 属性值以 `good` 结尾的标签|
|`[class|="btn"][class*="-arrow"]`| class 以 `btn` 开头并且含有 `-arrow` 子串("btn-arrow"和"btn-good bad-arrow" 都能匹配到)|
