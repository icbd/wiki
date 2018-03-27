---
layout: post
title:  Docker daemon config
date:   2018-03-27
categories: notes
---

官方文档: [https://docs.docker.com/engine/reference/commandline/dockerd/#examples](https://docs.docker.com/engine/reference/commandline/dockerd/#examples)

Docker 是跨平台的, Docker Daemon 在 Linux 和 Mac 的实现还不一样, 导致配置迁移遇到一些问题.

## daemon.json (全部版本支持)

先说推荐的做法: 所有配置都写到 `daemon.json` 文件中.

例如:

```
{
        "registry-mirrors": ["http://3045a9bc.m.daocloud.io"]
,       "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}
```

该文件在 Linux 的位置: `/etc/docker/daemon.json`

该文件在 Windows 的位置: `%programdata%\docker\config\daemon.json`

在 Docker for mac 18.03.0 中, 需要在GUI中设置, 每次保存修改都得重启 Docker.

![/wiki/wiki/docker-config.png](/wiki/wiki/docker-config.png)

注意: 该配置的键名多为复数, 比如 `labels` 对应的是个数组, 正确的写法是 `"labels": ["name=docker_daemon_on_linux"]`

注意: JSON 不能写注释, 最后不能多写逗号.

### 坑

万一写错了会导致 Docker 启动失败, 然后就再也启动不起来了...

他提示要不要 reset, 这个操作会弄丢我们所有的 image 和 container !

docker 启动的时候 icon 会转圈圈, 在这个间隙里 daemon.json 可编辑, 手速要快~


## DOCKER_OPTS (限Linux版本)


随 dockerd 命令行启动的选项可以写到 `/etc/default/docker`,

例如:

```
DOCKER_OPTS="--label name=docker_on_linux_vm_opts"
```

在使用 systemd 的系统下(Centos7 / Ubuntu16.04), 重启 Docker 发现配置无效.

还要手动修改 systemd 对 Docker 的启动项:

> /lib/systemd/system/docker.service

```
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target rhel-push-plugin.socket registries.service
Wants=docker-storage-setup.service
Requires=docker-cleanup.timer

[Service]
Type=notify
NotifyAccess=all
EnvironmentFile=-/run/containers/registries.conf
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
Environment=GOTRACEBACK=crash
Environment=DOCKER_HTTP_HOST_COMPAT=1
Environment=PATH=/usr/libexec/docker:/usr/bin:/usr/sbin

EnvironmentFile=-/etc/default/docker

ExecStart=/usr/bin/dockerd-current \
          --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current \
          --default-runtime=docker-runc \
          --exec-opt native.cgroupdriver=systemd \
          --userland-proxy-path=/usr/libexec/docker/docker-proxy-current \
          --seccomp-profile=/etc/docker/seccomp.json \
          $OPTIONS \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY \
          $REGISTRIES \
          $DOCKER_OPTS

ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
Restart=on-abnormal
MountFlags=slave
KillMode=process

[Install]
WantedBy=multi-user.target
```

编辑好 service 文件后要 `systemctl daemon-reload` 让它生效.

最后 `systemctl restart docker` .


注意: `daemon.json` 里的配置选项跟 `DOCKER_OPTS` 不能冲突, 否则启动失败. (感觉这样设计不太好, 让命令行选项覆盖 json 比较合适)

注意: 同一个选项在两者中有单复数的差别, 但是还是算相同选项, 比如`--label` 和 `"labels": []` .


另外, docker client 需要单独指定 `-H` 选项, 或者使用环境变量 `DOCKER_LABELS` .


## daemon.json example

```
{
	"authorization-plugins": [],
	"data-root": "",
	"dns": [],
	"dns-opts": [],
	"dns-search": [],
	"exec-opts": [],
	"exec-root": "",
	"experimental": false,
	"storage-driver": "",
	"storage-opts": [],
	"labels": [],
	"live-restore": true,
	"log-driver": "",
	"log-opts": {},
	"mtu": 0,
	"pidfile": "",
	"cluster-store": "",
	"cluster-store-opts": {},
	"cluster-advertise": "",
	"max-concurrent-downloads": 3,
	"max-concurrent-uploads": 5,
	"default-shm-size": "64M",
	"shutdown-timeout": 15,
	"debug": true,
	"hosts": [],
	"log-level": "",
	"tls": true,
	"tlsverify": true,
	"tlscacert": "",
	"tlscert": "",
	"tlskey": "",
	"swarm-default-advertise-addr": "",
	"api-cors-header": "",
	"selinux-enabled": false,
	"userns-remap": "",
	"group": "",
	"cgroup-parent": "",
	"default-ulimits": {},
	"init": false,
	"init-path": "/usr/libexec/docker-init",
	"ipv6": false,
	"iptables": false,
	"ip-forward": false,
	"ip-masq": false,
	"userland-proxy": false,
	"userland-proxy-path": "/usr/libexec/docker-proxy",
	"ip": "0.0.0.0",
	"bridge": "",
	"bip": "",
	"fixed-cidr": "",
	"fixed-cidr-v6": "",
	"default-gateway": "",
	"default-gateway-v6": "",
	"icc": false,
	"raw-logs": false,
	"allow-nondistributable-artifacts": [],
	"registry-mirrors": [],
	"seccomp-profile": "",
	"insecure-registries": [],
	"no-new-privileges": false,
	"default-runtime": "runc",
	"oom-score-adjust": -500,
	"node-generic-resources": ["NVIDIA-GPU=UUID1", "NVIDIA-GPU=UUID2"],
	"runtimes": {
		"cc-runtime": {
			"path": "/usr/bin/cc-runtime"
		},
		"custom": {
			"path": "/usr/local/bin/my-runc-replacement",
			"runtimeArgs": [
				"--debug"
			]
		}
	}
}
```