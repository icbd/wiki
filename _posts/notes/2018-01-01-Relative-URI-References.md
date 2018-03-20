---
layout: post
title:  URI 相对路径
date:   2018-01-01
categories: HTTP
---

```
Berners-Lee, et. al.        Standards Track                    [Page 29]

RFC 2396                   URI Generic Syntax                August 1998


C. Examples of Resolving Relative URI References

   Within an object with a well-defined base URI of

      http://a/b/c/d;p?q

   the relative URI would be resolved as follows:

C.1.  Normal Examples

      g:h           =  g:h
      g             =  http://a/b/c/g
      ./g           =  http://a/b/c/g
      g/            =  http://a/b/c/g/
      /g            =  http://a/g
      //g           =  http://g
      ?y            =  http://a/b/c/?y
      g?y           =  http://a/b/c/g?y
      #s            =  (current document)#s
      g#s           =  http://a/b/c/g#s
      g?y#s         =  http://a/b/c/g?y#s
      ;x            =  http://a/b/c/;x
      g;x           =  http://a/b/c/g;x
      g;x?y#s       =  http://a/b/c/g;x?y#s
      .             =  http://a/b/c/
      ./            =  http://a/b/c/
      ..            =  http://a/b/
      ../           =  http://a/b/
      ../g          =  http://a/b/g
      ../..         =  http://a/
      ../../        =  http://a/
      ../../g       =  http://a/g
```