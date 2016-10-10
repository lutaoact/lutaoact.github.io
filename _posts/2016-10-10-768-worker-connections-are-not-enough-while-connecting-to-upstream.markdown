---
layout: post
title:  "nginx proxy配置不当导致500错误"
date:   2016-10-10 14:57:39 +0800
categories: nginx
---

服务器报500错误，查看nginx的error log，发现如下报错：
{% highlight text %}
768 worker_connections are not enough while connecting to upstream
{% endhighlight %}
看起来似乎是连接数不够造成的，我查看了nginx.conf，相关配置为：
{% highlight sh %}
worker_processes 4;

events {
  worker_connections 768;
}
{% endhighlight %}
一般情况下，如果是生产环境，很有可能确实是由于并发数过大而造成的。

似乎调大这个配置数就够了，可我觉得不太对劲，因为我是在本地的测试环境遇到了这个问题，没啥并发啊。

以下是我的配置内容：
{% highlight sh %}
server
{
  listen 80;
  server_name domain.com;
  location / {
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:1111;
  }
}

server
{
  listen 80;
  server_name xxx.domain.com;
  location / {
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://domain.com;
  }
}
{% endhighlight %}
我希望在访问`http://xxx.domain.com`的时候，自动代理到`http://domain.com`，而后者再代理到这台服务器的1111端口。

经过细致测试和排查，最后恍然大悟，错误出现在：
{% highlight sh %}
proxy_set_header Host $host;
{% endhighlight %}
这条指令会把请求头部的Host修改成xxx.domain.com，因为xxx.domain.com和domain.com都指向同一个服务器，所以代理之后，因为Host仍然是xxx.domain.com，所以又会回到同一条配置，这就造成了死循环，导致连接数迅速耗尽。

以后碰到问题，要多多细致检查，多多学习~
