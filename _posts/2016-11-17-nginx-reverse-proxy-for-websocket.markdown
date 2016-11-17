---
layout: post
title:  "配置nginx反向代理支持websocket"
date:   2016-11-17 19:44:46 +0800
categories: nginx reverse proxy websocket
---

## 基本原理
WebSocket协议主要分为两个部分：握手和数据传输。

### 握手
通过HTTP协议完成握手。客户端在建立连接时，通过HTTP发起请求报文，具体内容不废话了，可以阅读文后附录的参考链接。

这里面的关键部分在于HTTP的请求中多了如下头部：
{% highlight text %}
Upgrade: websocket
Connection: Upgrade
{% endhighlight %}
这两个字段表示请求服务器升级协议为WebSocket。

服务器处理完请求后，响应如下报文，注：状态码为101
{% highlight text %}
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
{% endhighlight %}
告诉客户端已成功切换协议，升级为Websocket协议，自此握手成功。

### 数据传输
握手成功之后，服务器端和客户端便角色对等，就像普通的socket一样，能够双向通信。不再进行HTTP的交互，而是开始WebSocket的数据帧协议实现数据交换。

## nginx相关配置
{% highlight sh %}
# 在nginx的http上下文中，增加如下配置，确保nginx也能处理正常http请求
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

# 以下配置是在server上下文中添加，location指用于websocket连接的path
location /ws {
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $connection_upgrade;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_pass http://127.0.0.1:1111;
}
{% endhighlight %}
最重要的就是在反向代理的配置中增加了如下两行，其它的部分和普通的http反向代理没有任何差别。
{% highlight sh %}
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
{% endhighlight %}

## 参考链接
* [WebSocket 是什么原理？为什么可以实现持久连接？](https://www.zhihu.com/question/20215561)
* [NGINX as a WebSocket Proxy](https://www.nginx.com/blog/websocket-nginx/)
