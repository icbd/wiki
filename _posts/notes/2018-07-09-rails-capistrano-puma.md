---
layout: post
title:  Rails Capistrano Puma  
date:   2018-07-09
categories: Rails
---

服务器系统:

```text
# lsb_release -a
LSB Version:	:core-4.1-amd64:core-4.1-noarch
Distributor ID:	CentOS
Description:	CentOS Linux release 7.5.1804 (Core)
Release:	7.5.1804
Codename:	Core
```

## 服务器基本设置
到系统上装好 RVM, Ruby, Node, Nginx, Git .
 
设置免密码登录Server:
 将mac的 `~/.ssh/id_rsa.pub` 拷贝到服务器 `/root/.ssh/authorized_keys`
 
## 安装 capistrano

注意小版本号.

```text
group :development do
  gem "capistrano", "~> 3.11.0", require: false
  gem 'capistrano-rvm', '~> 0.1.2', require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'capistrano3-puma', '~> 3.1.1', require: false
end
```

```text
bundle install 
```

## 配置 cap

初始化cap配置文件:

```text
bundle exec cap install
```

> Capfile

```ruby
# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"


require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git


require "capistrano/rvm"
require 'capistrano/rails'
require 'capistrano/puma'
require 'capistrano/puma/nginx'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

```



> config/deploy.rb

注意不要写 `set :scm, :git`, 因为前面已经使用了 `install_plugin Capistrano::SCM::Git`, 否则会导致 puma 出问题.

```ruby
lock "~> 3.11.0"

set :application, "项目名"
set :repo_url, "项目git地址"
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
```


正式环境配置文件:

> config/deploy/production.rb 

```ruby
server 'your_server_ip', user: 'root', roles: %w{app db web}
set :branch, :master
set :ssh_options, {
    keys: %w(/root/.ssh/authorized_keys),
    auth_methods: %w(publickey)
}
set :nginx_server_name, "your_server_name"
set :nginx_sites_available_path, '/etc/nginx/sites-available'
set :nginx_sites_enabled_path, '/etc/nginx/sites-enabled'
# set :nginx_ssl_certificate, "/etc/ssl/certs/#{fetch(:nginx_config_name)}.crt"
# set :nginx_ssl_certificate_key, "/etc/ssl/private/#{fetch(:nginx_config_name)}.key"
# set :nginx_use_ssl, false
```

capistrano 其实只是帮我们 SSH 到 Server 上, 做一些本来需要我们自己手动操作的事情. 
理解这一点后各个公钥的配置就不会晕了. 为了能让cap帮我们pull代码, 需要将指定的公钥加到 Gitlab 的公钥设置里.

## 正式部署

nginx 使用yum默认安装的, 配置目录跟Ubuntu有些区别.
为了避免不必要的问题, 先手动创建目录 `/etc/nginx/sites-available` 和 `/etc/nginx/sites-enabled`, 
在nginx的主配置中引入 `include /etc/nginx/sites-enabled/*;` 


部署前检查:

```
cap production deploy:check
```

配置puma:
这一步会生成 puma.rb , 里面写了 puma 的启动参数.
```
cap production puma:config
```

配置nginx:

默认使用sock的方式连接nginx和puma, 在tmp下生成nginx配置后, 会mv到 `sites-available`目录, 然后软连接到 `sites-enabled`.
最终

```
cap production puma:nginx_config
```

正式部署:

```
cap production deploy
```

快捷操作:

```
cap production puma:stop
cap production puma:start
cap production puma:restart

cap production nginx:stop
cap production nginx:start
cap production nginx:restart
cap production nginx:reload
```