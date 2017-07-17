---
layout: post
title:  微信分享带缩略图和标题
date:   2017-07-17
categories: notes
---

## 目标问题

当用户在微信里打开我们的web页面后, 点击微信自己的分享按钮分享给朋友或朋友圈, 这时候没有缩略图和简介文案.


## 解决

long long ago, 在页面上摆一个 300X300 px以上的图片就会自动抓取. 后来微信要求接入JSSDK才可以, 遂有此文.

官方文档: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421141115



首先, 这是公众平台的功能(Open API 是 OAuth的功能, 其他功能主要在公众平台).
Hash算法注意key的顺序 -- 按照ASCII码升序排序.

![wx_jssdk.png](/wiki/wiki/wx_jssdk.png)

逻辑上没啥特别的, 主要是注意配置.

1. appSecret这个值得到后记得保存好, 不然只能重置.
2. 需要设置安全域名(只能设置三个), 分享的链接都在该域名下.
3. 需要设置IP白名单.(特别注意Nginx做负载均衡的时候是哪台机器请求的微信接口)
4. token接口有频率限制, 注意使用缓存策略.

## Demo

以下是PHP的例子, 文件缓存写在 Runtime目录下了.

> PHP (ThinkPHP 3.2.3)

```
<?php

class JSSDK
{
    private $appId;
    private $appSecret;
    private $access_token_file = RUNTIME_PATH . "access_token.php";
    private $jsapi_ticket_file = RUNTIME_PATH . 'jsapi_ticket.php';

    public function __construct($appId, $appSecret)
    {
        $this->appId = $appId;
        $this->appSecret = $appSecret;
    }

    public function getSignPackage()
    {
        $jsapiTicket = $this->getJsApiTicket();

        if (APP_DEBUG) {
            \Think\Log::write("jsapiTicket\n" . json_encode($jsapiTicket), \Think\Log::INFO);
        }


        // 注意 URL 一定要动态获取，不能 hardcode.
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? "https://" : "http://";
        $url = "$protocol$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";

        if (APP_DEBUG) {
            \Think\Log::write("url\n" . json_encode($url), \Think\Log::INFO);
        }


        $timestamp = time();
        $nonceStr = $this->createNonceStr();

        // 这里参数的顺序要按照 key 值 ASCII 码升序排序
        $string = "jsapi_ticket=$jsapiTicket&noncestr=$nonceStr&timestamp=$timestamp&url=$url";

        $signature = sha1($string);

        $signPackage = array(
            "appId" => $this->appId,
            "nonceStr" => $nonceStr,
            "timestamp" => $timestamp,
            "url" => $url,
            "signature" => $signature,
            "rawString" => $string
        );
        return $signPackage;
    }

    private function createNonceStr($length = 16)
    {
        $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        $str = "";
        for ($i = 0; $i < $length; $i++) {
            $str .= substr($chars, mt_rand(0, strlen($chars) - 1), 1);
        }
        return $str;
    }

    private function getJsApiTicket()
    {
        // jsapi_ticket 应该全局存储与更新，以下代码以写入到文件中做示例
        $data = json_decode($this->get_php_file($this->jsapi_ticket_file));
        if ($data->expire_time < time()) {
            $accessToken = $this->getAccessToken();
            // 如果是企业号用以下 URL 获取 ticket
            // $url = "https://qyapi.weixin.qq.com/cgi-bin/get_jsapi_ticket?access_token=$accessToken";
            $url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=jsapi&access_token=$accessToken";
            $res = json_decode($this->httpGet($url));
            $ticket = $res->ticket;

            if (APP_DEBUG) {
                \Think\Log::write("ticket\n" . json_encode($ticket), \Think\Log::INFO);
            }

            if ($ticket) {
                $data->expire_time = time() + 7000;
                $data->jsapi_ticket = $ticket;
                $this->set_php_file($this->jsapi_ticket_file, json_encode($data));
            }
        } else {
            $ticket = $data->jsapi_ticket;
        }

        return $ticket;
    }

    private function getAccessToken()
    {
        // access_token 应该全局存储与更新，以下代码以写入到文件中做示例

        $data = json_decode($this->get_php_file($this->access_token_file));
        if ($data->expire_time < time()) {
            // 如果是企业号用以下URL获取access_token
            // $url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$this->appId&corpsecret=$this->appSecret";
            $url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$this->appId&secret=$this->appSecret";
            $res = json_decode($this->httpGet($url));
            $access_token = $res->access_token;

            if (APP_DEBUG) {
                \Think\Log::write("access_token url \n" . $url, \Think\Log::INFO);
                \Think\Log::write("access_token\n" . json_encode($access_token), \Think\Log::INFO);
            }

            if ($access_token) {
                $data->expire_time = time() + 7000;
                $data->access_token = $access_token;
                $this->set_php_file($this->access_token_file, json_encode($data));
            }
        } else {
            $access_token = $data->access_token;
        }
        return $access_token;
    }

    private function httpGet($url)
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_TIMEOUT, 500);
        // 为保证第三方服务器与微信服务器之间数据传输的安全性，所有微信接口采用https方式调用，必须使用下面2行代码打开ssl安全校验。
        // 如果在部署过程中代码在此处验证失败，请到 http://curl.haxx.se/ca/cacert.pem 下载新的证书判别文件。
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, true);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, true);
        curl_setopt($curl, CURLOPT_URL, $url);

        $res = curl_exec($curl);
        curl_close($curl);

        return $res;
    }

    private function get_php_file($filename)
    {
        return trim(substr(file_get_contents($filename), 15));
    }

    private function set_php_file($filename, $content)
    {
        $fp = fopen($filename, "w");
        fwrite($fp, "<?php exit();?>" . $content);
        fclose($fp);
    }
}

```


> JS

```
<!--WX JSSDK-->
<script src="http://res.wx.qq.com/open/js/jweixin-1.2.0.js"></script>
<script>
    if (window.navigator.userAgent.toLowerCase().match(/MicroMessenger/i) == 'micromessenger' && typeof(wx) === 'object') {
        wx.config({
            debug: false,
            appId: "", // 必填，公众号的唯一标识
            timestamp: "", // 必填，生成签名的时间戳
            nonceStr: "", // 必填，生成签名的随机串
            signature: "",// 必填，签名，见附录1
            jsApiList: ['onMenuShareTimeline', 'onMenuShareAppMessage', 'onMenuShareQQ', 'onMenuShareQZone']
        });

        var wx_share_title = ''; // 分享标题
        var wx_share_imgUrl = ''; // 分享图标
        var wx_share_desc = '''; // 分享描述
        var wx_share_link = ''; // 分享链接

        wx.ready(function () {
            wx.onMenuShareTimeline({
                title: wx_share_title,
                link: wx_share_link,
                imgUrl: wx_share_imgUrl,
            });

            wx.onMenuShareAppMessage({
                title: wx_share_title,
                desc: wx_share_desc,
                link: wx_share_link,
                imgUrl: wx_share_imgUrl,
                type: 'link',
                dataUrl: '',
            });

            wx.onMenuShareQQ({
                title: wx_share_title,
                desc: wx_share_desc,
                link: wx_share_link,
                imgUrl: wx_share_imgUrl,
            });

            wx.onMenuShareQZone({
                title: wx_share_title,
                desc: wx_share_desc,
                link: wx_share_link,
                imgUrl: wx_share_imgUrl,
            });


        });
    }
</script>
```