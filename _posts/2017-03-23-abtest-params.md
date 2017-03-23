 ---
 layout: post
 title:  ab压力测试的GET参数
 date:   2017-03-23
 categories: TOOLS
 ---

如果URL中含有&,ab将会截断.
对于普通参数可以在URL两边加`"`来包含GET参数, 对于复杂参数或者POST参数,可以使用-p参数:


> Apache ab command

```
 ab -n 1000 -c 100 -p param.txt -T application/x-www-form-urlencoded http://statistics.cbd/Log/add
```

> param.txt

```
 proid=2&log={"info":{"from":2,"version":"1.0.5","channel":"ch9","oid":"","uid":"UID-1","os_version":"10.12","brand":"MAC OS","screen":"2560*1600","ram":"8000"},"data":[{"actype":1,"subno":1,"subid":0,"ct":1490251210}]}

```