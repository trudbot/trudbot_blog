---
title: 博客迁移记录
mathjax: true
tags:
  - 笔记
  - git
  - nginx
  - ssl
categories: 杂谈
abbrlink: 41626
date: 2023-07-06 18:57:44
---

主要记录一下本次耗时一两天博客的迁移过程。

<!--more-->

## 服务器部署

Hexo框架的原理就是生成模板式的静态页面， 然后通过git推送到仓库。

所以在服务器上要做的事也很简单:

* 创建git仓库
* 创建静态web服务器

### 创建git仓库

这里其实可以细化为两步， 因为git仓库中的代码必须要暴露出来供web服务器访问， 所以就多了一个创建钩子和静态目录的过程。

为了避免麻烦的权限问题， 我选择全部在root账号下完成。

* 安装git
* 将公钥上传到服务器root用户下(推送无需输入密码)

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@server-ip
```

* 在`/var`目录下创建仓库(此步完成后， 可以使用git clone root@server-ip:/var/repo/blog.git 来测试是否能正常连接仓库

```bash
mkdir /var/repo
cd /var/repo
git init --bare blog.git
```

* 创建静态文件目录

```bash
mkdir /var/www/hexo
```

* 配置钩子

```bash
vim /var/repo/blog.git/hooks/post-receive

写入如下内容: 
#!/bin/bash
git --work-tree=/var/www/hexo --git-dir=/var/repo/blog.git checkout -f

特别重要的一步， 添加执行权限：
chmod +x /var/repo/blog.git/hooks/post-receive
```

* 本地`_config.yml`, deploy选项中加入

```
  - type: git
    repository: root@server-ip:/var/repo/blog.git
    branch: master
```

完成后， 进行推送: `hexo d`， 成功推送到`/var/www/hexo`目录下即成功。

### 配置nginx服务器



* 安装nginx, `yum install nginx -y`
* 使用yum安装nginx时， 默认的目录如下

```F#
/etc/nginx, 配置文件目录
/var/log/nginx/error.log， 日志文件的路径
/usr/sbin/nginx， 可执行文件的路径
```

* 进入nginx目录(yum安装时， 为/etc/nginx)， 在`conf.d`目录下新建`blog.conf`文件， 写入如下内容

```
server {
    listen    80 default_server;
    listen    [::] default_server;
    server_name    trudbot.cn;
    root    /var/www/hexo;
    error_page 404 404.html;
}
```

* 打开nginx目录下的`nginx.conf`文件， 修改用户为'root'

```
user root;
```

* 重启nginx服务

```
systemctl restart nginx
```

完成后， 浏览器访问服务器ip, 显示博客界面即为成功。

### 扩展——nginx配置文件详解

nginx的主配置文件为`nginx.conf`, 结构大致如下

```nginx
# 全局配置
user root;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;


include /usr/share/nginx/modules/*.conf;

# event配置
events {
    worker_connections 1024;
}

# http配置
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
```

#### 全局模块

> 全局块是默认配置文件从开始到events块之间的一部分内容，主要设置一些影响Nginx服务器整体运行的配置指令，因此，这些指令的作用域是Nginx服务器全局。
>
> 通常包括配置运行Nginx服务器的用户（组）、允许生成的worker process数、Nginx进程PID存放路径、日志的存放路径和类型以及配置文件引入等。

#### events模块

> events块涉及的指令主要影响Nginx服务器与用户的网络连接。常用到的设置包括是否开启对多worker process下的网络连接进行序列化，是否允许同时接收多个网络连接，选取哪种事件驱动模型处理连接请求，每个worker process可以同时支持的最大连接数等。
>
> 这一部分的指令对Nginx服务器的性能影响较大，在实际配置中应该根据实际情况灵活调整。

```
events {
    worker_connections 1024;    # 每个工作进程最大并发连接数
    use epoll;                  # 使用epoll网络模型，提高性能
    multi_accept on;            # 开启支持多个连接同时建立
}
```

#### http模块

> http块是Nginx服务器配置中的重要部分，代理、缓存和日志定义等绝大多数的功能和第三方模块的配置都可以放在这个模块中。
>
> 前面已经提到，http块中可以包含自己的全局块，也可以包含server块，server块中又可以进一步包含location块，在本书中我们使用“http全局块”来表示http中自己的全局块，即http块中不包含在server块中的部分。

##### server模块

一个server就相当于一个虚拟主机，一台nginx内部可有多台虚拟主机联合提供服务，一起对外提供在逻辑上关系密切的一组服务（或网站）。

常用配置如下

```nginx
listen：监听的端口，默认为80

server_name：服务器名，如localhost、www.example.com，可以通过正则匹配

root：站点根目录，即网站程序存放目录 

index：查询排序，先查询第一个文件是否存在，再查询第二个，一直查询下去，直到查询到

error_page ：错误页面， 如error_page 404 404.html

```

1、基于ip的虚拟主机， (一个主机绑定多个ip地址)

```
server{
  listen       192.168.1.1:80;
  server_name  localhost;
}
server{
  listen       192.168.1.2:80;
  server_name  localhost;
}
```
2、基于域名的虚拟主机(servername)
```
#域名可以有多个，用空格隔开
server{
  listen       80;
  server_name  www.nginx1.com www.nginx2.com;
}
server{
  listen       80;
  server_name  www.nginx3.com;
}
```
3、基于端口的虚拟主机(listen不写ip的端口模式)
```
server{
  listen       80;
  server_name  localhost;
}
server{
  listen       81;
  server_name  localhost;
}
```
##### location模块

location模块用于处理一个server中特定的url。

在Nginx的官方文档中定义的location的语法结构为：

```nginx
location [ = | ~ | ~* | ^~ ] uri { ... }
```

> 其中，uri变量是待匹配的请求字符串，可以是不含正则表达的字符串，如/myserver.php等；也可以是包含有正则表达的字符串，如 .php$（表示以.php结尾的URL）等。为了下文叙述方便，我们约定，不含正则表达的uri称为“标准uri”，使用正则表达式的uri称为“正则uri”。
>
> 其中方括号里的部分，是可选项，用来改变请求字符串与 uri 的匹配方式。在介绍四种标识的含义之前，我们需要先了解不添加此选项时，Nginx服务器是如何在server块中搜索并使用location块的uri和请求字符串匹配的。
>
> 在不添加此选项时，Nginx服务器首先在server块的多个location块中搜索是否有标准uri和请求字符串匹配，如果有多个可以匹配，就记录匹配度最高的一个。然后，服务器再用location块中的正则uri和请求字符串匹配，当第一个正则uri匹配成功，结束搜索，并使用这个location块处理此请求；如果正则匹配全部失败，就使用刚才记录的匹配度最高的location块处理此请求。
>
> 了解了上面的内容，就可以解释可选项中各个标识的含义了：
>
> - “=”，用于标准uri前，要求请求字符串与uri严格匹配。如果已经匹配成功，就停止继续向下搜索并立即处理此请求。
> - “^～”，用于标准uri前，要求Nginx服务器找到标识uri和请求字符串匹配度最高的location后，立即使用此location处理请求，而不再使用location块中的正则uri和请求字符串做匹配。
> - “～”，用于表示uri包含正则表达式，并且区分大小写。
> - “～`*`”，用于表示uri包含正则表达式，并且不区分大小写。注意如果uri包含正则表达式，就必须要使用“～”或者“～*”标识。

location下常用的配置有:

```
root: 根目录
alisa: 
index： 入口文件
error_page: 异常处理
proxy_pass： 反省代理配置
```



## 图床迁移

在此之前图床一直是白嫖的`github`免费仓库， 但github图床的连接是被墙的， 既然博客已经迁移到国内服务器， 图片还流落海外就不太合适。

我的解决方案是**阿里云OSS** + **picgo**, 没错， 还是picgo， 主要是它配合typora是真舒服。

**阿里云OSS图床创建**： [Hexo + Butterfly 建站指南（七）阿里云 OSS 图床](https://www.nickxu.top/2022/03/28/Hexo-Butterfly-建站指南（七）阿里云-OSS-图床/)

**picgo插件进行图床迁移**: [利用 PicGo 快速迁移 Gitee 图床外链图片到服务器](https://cloud.tencent.com/developer/article/1975652)

## 域名备案

域名备案到服务器厂商。

## HTTPS配置

* 为域名申请SSL证书， 这里不赘述这部分。

* 下载证书文件包含`域名.pem，域名.key`， 将两个文件上传到服务器。

* 在`/etc/nginx/conf.d`目录下新增配置文件`ssl.conf`， 写入如下内容

```nginx
server {
        listen          443 ssl http2;    #使用http2协议
        server_name     trudbot.cn;       #申请SSL证书的域名
  			root    /var/www/hexo;

        ssl_certificate /etc/nginx/ssl/www.trudbot.cn.pem;  #申请的证书文件，写上全路径
        ssl_certificate_key     /etc/nginx/ssl/www.trudbot.cn.key;   #申请的证书文件，写上全路径
        ssl_protocols   TLSv1 TLSv1.1 TLSv1.2;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;preload" always;

       #https性能优化
       ssl_prefer_server_ciphers on;
       ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_trusted_certificate /etc/nginx/ssl/www.trudbot.cn.pem;
        ssl_buffer_size 4k;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        #减少点击劫持
        add_header X-Frame-Options DENY;
        #禁止服务器自动解析资源类型
        add_header X-Content-Type-Options nosniff;
        #防XSS攻擊
        add_header X-Xss-Protection 1;
			  #资源目录配置
        location = / {
                         index   index.html;
        }
}
```

注意前提是nginx安装了ssl模块， 使用yum安装的nginx已经自带， 使用其它方法安装时可能需要手动安装nginx的ssl模块。

添加完后访问`https://IP`测试是否能成功通过https访问。

## CDN失效替换

jsdelivr目前处于半墙状态， 而很多npm包中都使用了jsdelivr托管css和js文件， 其实包括mathjax和katex， 缺少这些博客文章将无法渲染。

解决方法之一是， 将这些文件下载到本地， 然后在public中替换所有的cdn.jsdelivr链接。

这种方法的好处是一劳永逸， 不用再担心cdn失效问题。

* 下载所有文件到指定路径， 如`https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js`下载为`source/npm/mathjax@3/es5/tex-mml-chtml.js`
* 编写shell脚本进行替换, 保存为`switch.sh`文件

```
#!/usr/bin/env sh
# author: trudbot
# Description: invalid cdn switch script

echo "---------------- Invalid CDN switch local path file ----------------"
# 遍历指定目录及其子目录下的所有HTML文件
find ./public -type f -name "*.html" | while read -r file; do
    # 使用sed命令替换文件中的字符串
    sed -i 's#https://cdn.jsdelivr.net/#/#g' "$file"
    sed -i 's#//cdn.jsdelivr.net/#/#g' "$file"
    echo "替换文件：$file"
done
echo 'ok !'
```

* 在bash中运行shell脚本文件即可执行替换

---

第二种解决方法是替换cdn源， 这可以在next主题的配置文件尾部进行配置。

## 参考



[yum 安装nginx 后 nginx的 目录_用yam下载的nginx的路径是什么_上官二狗的博客-CSDN博客](https://blog.csdn.net/qq_36431213/article/details/78164286)

[Hexo部署到云服务器指南-知乎](https://zhuanlan.zhihu.com/p/356054248)

[Hexo cdn.jsdelivr.net 等部分CDN引用无效的一种低成本解决方案 | 程序员论坛 (learnku.com)](https://learnku.com/articles/68510)

[执行.sh文件（shell脚本）的几种方式_执行sh_Zero .的博客-CSDN博客](https://blog.csdn.net/admin123404/article/details/115707774)

[万字带你搞懂nginx的配置文件_nginx 配置_way_more的博客-CSDN博客](https://blog.csdn.net/qq_36551991/article/details/118612282)

[Nginx配置文件详解 - 程序员自由之路 - 博客园 (cnblogs.com)](https://www.cnblogs.com/54chensongxia/p/12938929.html)

