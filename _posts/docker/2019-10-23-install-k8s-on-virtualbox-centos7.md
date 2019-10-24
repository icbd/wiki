---
layout: post
title:  在 VirtualBox 的 Centos7 中安装 K8S 集群
date:   2019-10-23
categories: k8s
---

# 准备

## 配置 VM network
  添加 `Host-Only Adapter` 和 `Internal Network` 
  
## 配置 hostname, 修改 hosts 文件

## 实验用途的最好清空 iptables 

```shell script
cat > clear-iptables <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
EOF
iptables-restore < clear-iptables
iptables -L -nv --line-numbers
```
  
## 升级内核到 4.x-lt

```shell script
yum install kernel-lt.x86_64 --enablerepo=elrepo-kernel
```

## 关闭防火墙(optional)
```shell script
systemctl stop firewalld
systemctl disable firewalld
```

## 禁用 selinux
```shell script
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0
```

## 禁用 swap
注释 `/etc/fstab` 中 swap 的 line.
使用 `free` 或 `swapon` 查看.
```shell script
swapoff -a
```

## 配置 net bridge for centos
```shell script
cat > /etc/sysctl.d/k8s-iptables.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
EOF
sysctl --system
```

## 安装 docker
如果需要最新版本, 注意 K8S 要求的 Docker 版本.

```shell script
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install yum-utils device-mapper-persistent-data lvm2 docker-ce-18.06.1.ce-3.el7 -y

mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl start docker
```

## 安装 CRI-O
```shell script
modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

yum-config-manager --add-repo=https://cbs.centos.org/repos/paas7-crio-115-release/x86_64/os/
yum install --nogpgcheck cri-o -y
systemctl enable crio
systemctl start crio
```

## 安装 containerd
```shell script
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
yum install containerd.io -y
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl enable containerd
systemctl start containerd
```

## 安装 kubernetes
```shell script
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install kubelet-1.13.3 kubeadm-1.13.3 kubectl-1.13.3 kubernetes-cni-0.6.0 -y
systemctl enable kubelet
systemctl start kubelet
```

# 初始化 master
注意init时候的网络参数:
`netstat -rn`

```shell script
kubeadm init \
  --apiserver-advertise-address <MASTER-NODE-IP> \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.13.3 \
  --pod-network-cidr=10.244.0.0/16 

echo "注意保留生成的token!"

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
cat >> /etc/profile <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF
```

## 安装 Pod 网络插件
```shell script
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
```

## check nodes pods
```shell script
kubectl get nodes
kubectl get pods -n kube-system
```
**debug** 如果配置出问题, 使用下面来重置, 然后再 `kebeadm init ...`
```shell script
kubeadm reset
ip link delete cni0
ip link delete flannel.1
```

## 在 node 上执行join
```shell script
kubeadm join <MASTER-NODE-IP>:6443 --token <YOUR-TOKEN> \
    --discovery-token-ca-cert-hash <YOUR-CA-CERT>
```

# 测试

## nginx
```shell script
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

kubectl get pods,svc -o wide
```

## kubernetes-dashboard
### 安装
```shell script
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
```

### 创建登录 token:
```shell script
kubectl get pods,svc -o wide -n kube-system

cat > /root/k8s-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: k8s-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: k8s-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: k8s-admin
  namespace: kube-system
EOF

kubectl apply -f /root/k8s-sa.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep k8s-admin | awk '{print $1}')
#kubectl edit svc/kubernetes-dashboard --namespace=kube-system
```

特别注意, 访问 dashboard 必须使用 `https://` .