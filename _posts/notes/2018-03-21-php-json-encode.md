---
layout: post
title:  json_encode unescape unicode
date:   2018-03-21
categories: PHP
---

在调试API的时候常遇到这样的情况, 不能直接读出API的信息:

```
{"hello":"\u4f60\u597d","smile":"\ud83d\ude0a","single_quotation_mark":"'","double_quotation_mark":"\""}
```

这不是编码的Bug, 是 `json_encode` 的默认特性, 把多字节unicode字符转成 `\uxxxx` 的样子.
如果不希望这样的escape, 可以使用 `JSON_UNESCAPED_UNICODE` 参数 (php version >= 5.4).

```
$data = [
            'hello' => '你好',
            'smile' => '😊',
            'single_quotation_mark' => '\'',
            'double_quotation_mark' => '"',
        ];
        echo json_encode($data, JSON_UNESCAPED_UNICODE);

        //{"hello":"你好","smile":"😊","single_quotation_mark":"'","double_quotation_mark":"\""}
```


# 参考

> [https://stackoverflow.com/questions/7462394/php-json-string-escape-double-quotes-for-js-output](https://stackoverflow.com/questions/7462394/php-json-string-escape-double-quotes-for-js-output)