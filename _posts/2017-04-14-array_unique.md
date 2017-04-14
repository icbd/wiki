---
layout: post
title:  array_unique后不能信赖key
date:   2017-04-14
categories: notes
---

```

<?php

$arr1 = ['a', 'b', 'c', 'd'];
$arr2 = ['a', 'b', 'c', 'd', 'a', 'b'];

$merged1 = array_merge($arr1, $arr2);
echo json_encode($merged1);
//["a","b","c","d","a","b","c","d","a","b"]

$uniqued1 = array_unique($merged1);
echo json_encode($uniqued1);
//["a","b","c","d"]

/************************/
/************************/

$arra = ['a', 'b', 'c', 'd'];
$arrb = ['a', 'b', 'c', 'd', 'a', 'b', 'x'];

$merged2 = array_merge($arra, $arrb);
echo json_encode($merged2);
//["a","b","c","d","a","b","c","d","a","b","x"]

$uniqued2 = array_unique($merged2);
echo json_encode($uniqued2);
//{"0":"a","1":"b","2":"c","3":"d","10":"x"}

```

注意 $uniqued1 的结果是 Array, $unique2 的结果是 Hash.

为消除不确定, 返回 unique 结果前用 array_values() 清洗一篇比较稳妥.