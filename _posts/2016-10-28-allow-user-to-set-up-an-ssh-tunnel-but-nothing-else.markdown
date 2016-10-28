---
layout: post
title:  "仅允许用户打开ssh隧道，禁止其它操作"
date:   2016-10-28 16:43:25 +0800
categories: ssh tunnel permitopen
---

这个故事是这样的，因为长城宽带无法连接我放在digitalocean上的代理服务器，所以我需要利用国内的某台服务器作为跳板来打通到代理服务器的连接。

我知道ssh隧道可以搞定这件事，最后，我的确搞定了。

当我搞定之后，发现身边还有其它用长城宽带的朋友，也希望用我的代理服务器，所以我就得把ssh隧道链接代理服务器的方法共享给他。

如果我把登录服务器的密钥给他，那他就能开隧道，同时，他也能登录我的服务器，虽然他不会瞎搞，但万一他把密钥泄露给别人呢？别人瞎搞怎么办。

最后我新建了一个用户forward，并重新生成了一个新的密钥对。我禁用了密码登录，所以需要配置ssh的免密登录。

* 将forward.pem.pub，也就是公钥的内容，放到~/.ssh/authorized_keys里面，配置过ssh免密登录的朋友应该都知道是啥意思。相关内容参考[ssh基础知识][ssh-url]
* 在密钥开始的ssh-rsa前面，添加如下内容，记得在`ssh-rsa`之前用空行隔开
{% highlight sh %}
no-pty,no-X11-forwarding,permitopen="host:port",command="/bin/echo do-not-send-commands"

# no-pty: 阻止ssh请求得到一个终端
# permitopen: 限定可以转发到哪个地址，host和port根据实际情况修改
# command: 指定在任何时候当前pubkey被用于验证时所执行的命令，用户提供的命令会被忽略
{% endhighlight %}

打开隧道的命令就变成了这样：
{% highlight sh %}
ssh -N -L 11111:host:port forward@remote #remote就是跳板，我新建了forward用户
# 本地只需要连接127.0.0.1:11111就可以了，相当于连接了host:port
{% endhighlight %}

也可以在本地的~/.ssh/config文件中做如下配置：
{% highlight sh %}
Host proxynode
  Hostname remote
  User forward
  IdentityFile ~/.ssh/forward.pem
  LocalForward 11111 host:port
  ExitOnForwardFailure yes
{% endhighlight %}
可以这样打开隧道：`ssh -N proxynode`

## 参考链接
* [Allow user to set up an SSH tunnel, but nothing else](http://stackoverflow.com/questions/8021/allow-user-to-set-up-an-ssh-tunnel-but-nothing-else)
* [How to create a restricted SSH user for port forwarding?](http://askubuntu.com/questions/48129/how-to-create-a-restricted-ssh-user-for-port-forwarding)

[ssh-url]: {% post_url 2016-04-15-ssh %}
