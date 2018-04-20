---
layout: post
title:  Rails 生成和展示二维码
date:   2018-04-20
categories: Rails
---


我们这里不讨论 QR 二维码的生成算法, 只说应用. 利用 rqrcode, 可以生成多种格式的二维码.


```
gem 'rqrcode', '~> 0.10.1'
```

如果只是纯展示, as_html 就够了, 会生成一个 table , 结合 CSS 布局, 看起来就是一个二维码~

如果我们希望用户可以下载这个图片, 那就要生成一个 png 格式的图片.

```
    require 'rqrcode'
    str = params[:str] || ""

    qr = RQRCode::QRCode.new(str)

    qr_img_stream = qr.as_png(
        border_modules: 2,
        color: "24292e"
    ).to_s
```

这样我们得到了二维码图片的二进制码流(qr_img_stream), 设置一下 HTTP 头尾图片格式, 再把码流作为 HTTP 的内容直接发给用户就行了, 如下:

```
    options = {type: 'image/png'}
    send_file_headers! options
    render body: qr_img_stream
```

如果单独访问这个图片, 图片会立即下载. 如果想让图片展示, 还需要设置 `Content-Disposition` 头.

[https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Disposition](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Disposition)

```
Content-Disposition: inline
Content-Disposition: attachment
Content-Disposition: attachment; filename="filename.jpg"
```

rails 封装好了一个 `send_data` 方法, 可以直接向用户发送文件, 完整方法如下:

```

  # render a qr image
  def qr
    require 'rqrcode'
    str = params[:str] || ""

    qr = RQRCode::QRCode.new(str)

    qr_img_stream = qr.as_png(
        border_modules: 2,
        color: "24292e"
    ).to_s

    send_data(qr_img_stream, type: 'image/png', disposition: 'inline')
  end

```








