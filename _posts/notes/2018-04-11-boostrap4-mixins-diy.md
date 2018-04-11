---
layout: post
title:  利用Boostrap4的mixins制作定制类
date:   2018-04-11
categories: Bootstrap
---

## html

```
<div class="container-diy">
  <div class="row-diy">
    <div class="col-diy-main"></div>
    <div class="col-diy-side"></div>
  </div>
</div>
```

## scss

```
.container-diy {
  @include make-container();
  background-color: #eee;
  height: 300px;
}

.row-diy {
  @include make-row();
  height: 100%;
}

.col-diy-main {
  @include make-col(6);
  @include make-col-offset(2);
  background-color: lightblue;
  height: 50%;
  align-self: start;
}

.col-diy-side {
  @include make-col(2);
  background-color: lightsalmon;
  height: 50%;
  align-self: flex-end;
}
```

![/wiki/wiki/bootstrap4-mixins-diy.png](/wiki/wiki/bootstrap4-mixins-diy.png)

> https://getbootstrap.com/docs/4.1/layout/grid/#mixins