---
layout: post
title:  docker daemon tcp security
date:   2018-03-29
categories: notes
---

|名词|含义|
|---|---|
|X.509|证书格式, 包含证书持有人的公钥,支持的加密算法等|
|pkcs1~pkcs12|非对称加密的标准, 如.p12, 包含证书和密钥|
|.der|证书的二进制存储格式|
|.pem|证书或密钥的base64存储格式|
|.key|.pem文件的密钥部分|
|.crt .cer|证书|
|.csr|证书签名请求|


```
#!/bin/bash

# DIY
HOST=*.hello233world.com
PASWD=PASSWORD


echo "生成CA密钥:ca-key.pem"
openssl genrsa -passout pass:$PASWD -aes256 -out ca-key.pem 4096

echo "生成CA证书:ca.pem"
openssl req -passin pass:$PASWD -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj "/CN=$HOST"

echo "生成服务端密钥:server-key.pem"
openssl genrsa -out server-key.pem 4096

echo "生成服务端证书请求:server.csr"
openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

echo "生成服务端证书:server-cert.pem"
echo extendedKeyUsage = serverAuth > extfile_server.cnf
openssl x509 -passin pass:$PASWD -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile_server.cnf
rm server.csr

echo "生成客户端密钥:key.pem"
openssl genrsa -out key.pem 4096

echo "生成客户端证书请求:client.csr"
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo "生成客户端证书:cert.pem"
echo extendedKeyUsage = clientAuth > extfile_client.cnf
openssl x509 -passin pass:$PASWD -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile_client.cnf

rm -f client.csr server.csr ca.srl extfile_client.cnf extfile_server.cnf
```


> /etc/docker/daemon.json

```
{
	"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
,	"tlsverify": true
,	"tlscacert": "/root/.docker/ca.pem"
,	"tlscert": "/root/.docker/server-cert.pem"
,	"tlskey": "/root/.docker/server-key.pem"
}
```

## 本地终端

```
docker --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem -H=ss1.hello233world.com:2375 images
```

将这三个文件放到 `~/.docker` 目录下, 可以省略参数, 默认寻找.


## 注意

制作证书签名的时候不能用"客户端证书加密", 见 [Use encrypted client certificate to connect to a docker host](https://github.com/moby/moby/issues/30935)


> https://docs.docker.com/engine/security/https/#create-a-ca-server-and-client-keys-with-openssl

> https://www.jianshu.com/p/7ba1a93e6de4

> https://www.cnblogs.com/ederwin/articles/5553556.html

> https://www.oschina.net/translate/remote-access-to-docker-with-tls

