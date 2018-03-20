---
layout: post
title:  mysql5.7 手册 String Functions
date:   2017-12-14
categories: mysql
---

> https://dev.mysql.com/doc/refman/5.7/en/string-functions.html#function_insert

对于长度超出系统变量 `max_allowed_packet` 限制的结果, 字符串处理函数返回 `NULL` (译者注:该限制默认4MB).

对于字符串操作函数, 字符串下标从 1 开始.

对于需要长度参数的函数, 非整型的参数会四舍五入到整型.

# ASCII(str)
返回字符串最左边那个字符对应的数值. 空字符串返回 `0` ,  `NULL` 返回 `NULL`. ASCII() 只对8位编码的字符有效.

```
mysql> SELECT ASCII('2');
        -> 50
mysql> SELECT ASCII(2);
        -> 50
mysql> SELECT ASCII('dx');
        -> 100
```

# BIN(N)
数字N的二进制表示, 以字符串的形式返回. 其中N是 `long long(BITINT)` 类型. 等价于 `CONV(N,10,2)` .  `NULL` 返回 `NULL` .

```
mysql> SELECT BIN(12);
        -> '1100'
```

# BIT_LENGTH(str)

返回字符串的比特长度.

``` 
mysql> SELECT BIT_LENGTH('text');
        -> 32
```

# CHAR(N,... [USING charset_name])

CHAR() 将每个参数N作为整型转化为其对应的字符, 返回将这些字符拼接起来的字符串. 跳过N为 `NULL` 的参数.

```
mysql> SELECT CHAR(77,121,83,81,'76');
        -> 'MySQL'
mysql> SELECT CHAR(77,77.3,'77.3');
        -> 'MMM'
```

CHAR() 将大于255的参数转化为多位结果. 例如, CHAR(256) 等价于 CHAR(1,0), CHAR(256*256) 等价于 CHAR(1,0,0):

```
mysql> SELECT HEX(CHAR(1,0)), HEX(CHAR(256));
+----------------+----------------+
| HEX(CHAR(1,0)) | HEX(CHAR(256)) |
+----------------+----------------+
| 0100           | 0100           |
+----------------+----------------+
mysql> SELECT HEX(CHAR(1,0,0)), HEX(CHAR(256*256));
+------------------+--------------------+
| HEX(CHAR(1,0,0)) | HEX(CHAR(256*256)) |
+------------------+--------------------+
| 010000           | 010000             |
+------------------+--------------------+
```

CHAR() 默认返回二进制的字符串. 可以使用 `USING` 子句设置输出字符串的字符集;

```
mysql> SELECT CHARSET(CHAR(X'65')), CHARSET(CHAR(X'65' USING utf8));
+----------------------+---------------------------------+
| CHARSET(CHAR(X'65')) | CHARSET(CHAR(X'65' USING utf8)) |
+----------------------+---------------------------------+
| binary               | utf8                            |
+----------------------+---------------------------------+
```

如果使用了 `USING` 且 输出字符是跟所设置的字符集不匹配, 会抛出警告. 开启严格 SQL 模式时会返回 `NULL` . 

# CHAR_LENGTH(str)
# CHARACTER_LENGTH(str)

返回字符串长度, 以字符为计量单位. 多字节字符算做一个字符. 这意味着对于一个包含5个 2-byte 字符的字符串, `LEHGTH()` 返回10, 但 `CHAR_LENGTH()` 返回5.

# CONCAT(str1,str2,...)

返回参数拼接而成的字符串.参数可能有一个或多个. 如果所有参数都是非二进制字符串, 结果就是一个非二进制字符串.如果所有参数都是二进制字符串, 结果就是一个二进制字符串. 数字参数会转换成为与之等价的非二进制字符串形式. 参数中存在 `NULL` 则返回 `NULL`.

```
mysql> SELECT CONCAT('My', 'S', 'QL');
        -> 'MySQL'
mysql> SELECT CONCAT('My', NULL, 'QL');
        -> NULL
mysql> SELECT CONCAT(14.3);
        -> '14.3'
```

对于引号包裹的多个字符串, 会自动连接:

```
mysql> SELECT 'My' 'S' 'QL';
        -> 'MySQL'
```

# CONCAT_WS(separator,str1,str2,...)

CONCAT_WS() 是 CONCAT() 的特殊形式, 表示用分隔符连接. 第一个参数是分隔符, 被加在之后每个参数之间. 分隔符可以是个字符串也可以是之后参数中的一个. 如果分隔符是 `NULL`, 结果为 `NULL`.

```
mysql> SELECT CONCAT_WS(',','First name','Second name','Last Name');
        -> 'First name,Second name,Last Name'
mysql> SELECT CONCAT_WS(',','First name',NULL,'Last Name');
        -> 'First name,Last Name'
```

CONCAT_WS() 不会跳过空字符串参数, 但会跳过 `NULL` 参数.

# ELT(N,str1,str2,str3,...)

ELT() 返回字符串列表的第N个元素, str1 是第一个, N=1. str2 是第二个, N=2.等等.
如果N小于1或者超出列表范围, 返回 `NULL` . ELT() 是 FIELD() 的补充.

```
mysql> SELECT ELT(1, 'ej', 'Heja', 'hej', 'foo');
        -> 'ej'
mysql> SELECT ELT(4, 'ej', 'Heja', 'hej', 'foo');
        -> 'foo'
```

# EXPORT_SET(bits,on,off[,separator[,number_of_bits]])

返回一个字符串, 它是由第一个参数每一位的比特值决定.`bits` 的最高位在结果的最左端. number_of_bits 默认64, 超出64静默截断为64. number_of_bits 以无符号整型处理, 所以 -1 跟 64 等价.

```
mysql> SELECT EXPORT_SET(5,'Y','N',',',4);
        -> 'Y,N,Y,N'
mysql> SELECT EXPORT_SET(6,'1','0',',',10);
        -> '0,1,1,0,0,0,0,0,0,0'
```

# FIELD(str,str1,str2,str3,...)

返回 str 在 列表中的位置(第一个位置为1), 如果str不在列表中则返回0.

如果列表中元素都是字符串, 根据字符串比较的规则进行比较. 如果列表中元素都是数字, 就按照数字的规则进行比较. 其他情况按照 double 的规则比较.

如果 str 是 `NULL` 结果为0, 因为 `NULL` 不跟任何值相等. FIELD() 是 ELT() 的补充.

```
mysql> SELECT FIELD('ej', 'Hej', 'ej', 'Heja', 'hej', 'foo');
        -> 2
mysql> SELECT FIELD('fo', 'Hej', 'ej', 'Heja', 'hej', 'foo');
        -> 0
```

# FIND_IN_SET(str,strlist)

如果str在strlist中, 则返回在其中的位置. strlist 是由逗号分隔的列表. 如果str是字符串常量而且strlist是SET类型, FIND_IN_SET() 方法将使用位算法. 如果str不在strlist中或strlist为空字符串, 返回0.str或strlist有一个为 `NULL` 则返回 `NULL`. 如果str中包含逗号, FIND_IN_SET() 方法不能正常工作.

```
mysql> SELECT FIND_IN_SET('b','a,b,c,d');
        -> 2
```

# FORMAT(X,D[,locale])

把数字X格式化为 '#,###,###.##' 的格式, 四舍五入保留D位小数, 结果以字符串的形式返回. 如果D为0, 结果将略去小数点和小数部分.
第三个参数为可选参数, 允许使用本地格式来格式化结果的小数点显示, 千位分隔符显示和分组显示. 可用的本地化格式选项跟 lc_time_names 的系统变量相同. 默认值为 'en_US', 简体中文为 'zh_CN'. 

```
mysql> SELECT FORMAT(12332.123456, 4);
        -> '12,332.1235'
mysql> SELECT FORMAT(12332.1,4);
        -> '12,332.1000'
mysql> SELECT FORMAT(12332.2,0);
        -> '12,332'
mysql> SELECT FORMAT(12332.2,2,'de_DE');
        -> '12.332,20'
```

# FROM_BASE64(str)

使用 `TO_BASE64()` 的 `base-64` 编码方式, 返回解码后的二进制字符串. 如果 str 为 `NULL` 或 str不是一个合法的 base-64 字符串, 结果返回 `NULL`.

```
mysql> SELECT TO_BASE64('abc'), FROM_BASE64(TO_BASE64('abc'));
        -> 'JWJj', 'abc'
```

# HEX(str), HEX(N)

对于字符串参数 str, HEX() 返回一个十六进制表示的字符串, 它由 str 每一位以两位十六进制数组成. 多字节字符则转为多个数字.UNHEX() 方法是它的逆方法.

对于一个数字参数N, N被认为是 long long(BIGINT) 型, 等价于 CONV(N,10,16). CONV(HEX(N),16,10) 方法是它的逆方法.

```
mysql> SELECT X'616263', HEX('abc'), UNHEX(HEX('abc'));
        -> 'abc', 616263, 'abc'
mysql> SELECT HEX(255), CONV(HEX(255),16,10);
        -> 'FF', 255
```

# INSERT(str,pos,len,newstr)

返回字符串, pos 表示替换开始的位置, len 表示str中需要被替换掉的字符串长度. 如果pos超出str字符的范围, 返回str. 如果len超出了str剩余字符串的长度, 就将剩余部分全部替换. 参数中存在 `NULL` 则返回 `NULL`.
该方法多字节字符安全.

```
mysql> SELECT INSERT('Quadratic', 3, 4, 'What');
        -> 'QuWhattic'
mysql> SELECT INSERT('Quadratic', -1, 4, 'What');
        -> 'Quadratic'
mysql> SELECT INSERT('Quadratic', 3, 100, 'What');
        -> 'QuWhat'
```

# INSTR(str,substr)

返回 substr 第一次出现在 str 中的位置的下标. LOCATE() 作用相同, 参数位置对调.

```
mysql> SELECT INSTR('foobarbar', 'bar');
        -> 4
mysql> SELECT INSTR('xbar', 'foobar');
        -> 0
```

该方法多字节字符安全. 当至少有一个参数为二进制字符串时, 大小写敏感.

# LEFT(str,len)

返回str最左边的len个字符, 多字节字符安全. 任何参数为 `NULL` 时, 返回 `NULL`.

```
mysql> SELECT LEFT('foobarbar', 5);
        -> 'fooba'
```

# LENGTH(str)

返回以字节计算的字符串长度. 一个多字节字符算作多个字节. 这意味着对于一个包含五个双字节字符的字符串, LENGTH() 返回10, CHAR_LENGTH() 返回5.

```
mysql> SELECT LENGTH('text');
        -> 4
```

> OpenGIS 空间方法被迁移到 ST_Length().

# LOAD_FILE(file_name)

读文件, 将文件内容以字符串返回. 使用这个方法前, 该文件必须存在于服务器上, 且有访问权限. 该文件必须可读 并且文件大小小于 ` max_allowed_packet` 规定的字节数. 如果系统设置了 `secure_file_priv` , 则该文件必须在此目录下.

如果文件不存在或不可读, 返回 `NULL`.

`character_set_filesystem` 控制文件名的解释.

```
mysql> UPDATE t
            SET blob_col=LOAD_FILE('/tmp/picture')
            WHERE id=1;
```

# LOCATE(substr,str), LOCATE(substr,str,pos)

返回substr在str中出现的位置, 可选pos指明从第几个开始. 如果substr不在str中返回0. 参数存在 `NULL` 则返回 `NULL`.

```
mysql> SELECT LOCATE('bar', 'foobarbar');
        -> 4
mysql> SELECT LOCATE('xbar', 'foobar');
        -> 0
mysql> SELECT LOCATE('bar', 'foobarbar', 5);
        -> 7
```
多字节字符安全, 有参数为二进制字符串时大小写敏感.

# LOWER(str)

根据字符集, 将str所有字符转换为小写. 默认为 latin1 字符集(cp1252 West European).

```
mysql> SELECT LOWER('QUADRATICALLY');
        -> 'quadratically'
```

LOWER() (and UPPER())  对二进制字符串无效. (BINARY, VARBINARY, BLOB) 想在这种情况下进行大小写转换, 需要先将字符串转为非二进制类型.

```
mysql> SET @str = BINARY 'New York';
mysql> SELECT LOWER(@str), LOWER(CONVERT(@str USING latin1));
+-------------+-----------------------------------+
| LOWER(@str) | LOWER(CONVERT(@str USING latin1)) |
+-------------+-----------------------------------+
| New York    | new york                          |
+-------------+-----------------------------------+
```

该方法多字节字符安全.

# LPAD(str,len,padstr)

返回一个字符串, 在str上由左填充padstr至len个字符.如果len比str的长度还小, 返回str的前len个字符.

```
mysql> SELECT LPAD('hi',4,'??');
        -> '??hi'
mysql> SELECT LPAD('hi',1,'??');
        -> 'h'
```

# LTRIM(str)

返回去除前导空格的字符串.多字节字符安全.

```
mysql> SELECT LTRIM('  barbar');
        -> 'barbar'
```

# MAKE_SET(bits,str1,str2,...)
# OCT(N)
# ORD(str)
# POSITION(substr IN str)
# QUOTE(str)
# REPEAT(str,count)
# REPLACE(str,from_str,to_str)
# REVERSE(str)
# RIGHT(str,len)
# RPAD(str,len,padstr)
# RTRIM(str)
# SOUNDEX(str)
# SPACE(N)
# SUBSTRING(str,pos), SUBSTRING(str FROM pos), SUBSTRING(str,pos,len), SUBSTRING(str FROM pos FOR len)
# SUBSTRING_INDEX(str,delim,count)
# TO_BASE64(str)
# TRIM([{BOTH | LEADING | TRAILING} [remstr] FROM] str), TRIM([remstr FROM] str)
# UNHEX(str)
# UPPER(str)
# WEIGHT_STRING(str [AS {CHAR|BINARY}(N)] [LEVEL levels] [flags])