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

主要记录一下本次耗时半天博客的迁移过程。

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
                         root    /var/www/hexo;
                         index   index.html;
        }
}
```

