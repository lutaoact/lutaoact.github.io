---
layout: post
title:  "腾讯企业邮exmail跳转到\"mail.域名\"的变通方法"
date:   2016-10-08 16:54:22 +0800
categories: markdown kramdown
---

我的域名是lutaoact.com

如果你走到这里时，我假设你已经懂了怎么添加MX记录和SPF记录，我就不具体介绍了，我只写一下相关的配置值：
{% highlight text %}
记录类型  主机记录     记录值                            优先级        TTL
MX        @        mxbiz1.qq.com                         5           900
MX        @        mxbiz2.qq.com                         10          900
TXT       @        v=spf1 include:spf.mail.qq.com ~all   10          900
{% endhighlight %}

以前的腾讯企业邮是可以通过直接配置CNAME记录来实现"mail.域名"跳转到自己的域名邮箱的。
{% highlight text %}
记录类型  主机记录     记录值      优先级      TTL
CNAME     mail     exmail.qq.com   10        3600
{% endhighlight %}

可现在这个服务不再面向免费用户提供了，但这个东西又很好用，所以想了很多办法，跟大家分享一下我的一些探索历程吧。

最原始的方式就是直接使用`exmail.qq.com`，然后输入完整的邮箱和密码来登录，如下图：
![最原始的方式][origin-way]

当我发现西部数码(west.cn)提供域名URL转发的时候，我突然产生了一种邪恶的想法，设置一个隐性URL转发似乎可以实现我想要的。

将`mail.lutaoact.com`转发到`https://exmail.qq.com/login`，就可以直接跳转到登录页了，如下图：
![中间过渡方式][middle-way]

后来偶然在网上搜索企业邮箱配置的时候，看到了另一个转发方案，将转发地址设置为：
{% highlight text %}
https://exmail.qq.com/cgi-bin/loginpage?t=logindomain&s=logout&f=biz&param=@lutaoact.com
{% endhighlight %}
注意，**最后一部分改成自己的域名**，结果如下：
![完美解决方案][perfect-way]

只要输入邮箱名就可以了，不用输入完整的邮箱地址了，至此，基本可以实现原来CNAME的同等效果了。

## 附注
* 西部数码的URL转发有免费版和付费版，付费版每年28，挺便宜的，暂时感觉下来，似乎挺稳定的，暂时就这么用吧。
* 我的域名都是在西部数码注册的，我注册lutaoact.com的时候，腾讯还是支持免费CNAME的，后来给我媳妇注册域名的时候就不能用了，所以以上的配置过程，其实是给我媳妇弄的。毕竟，我家媳妇是记不住exmail这种东西的，能让她少记点东西还是不错的。

[origin-way]: http://7xsgzh.com1.z0.glb.clouddn.com/domain-email-origin-way.jpg
[middle-way]: http://7xsgzh.com1.z0.glb.clouddn.com/domain-email-middle-way.jpg
[perfect-way]: http://7xsgzh.com1.z0.glb.clouddn.com/domain-email-perfect-way.jpg
