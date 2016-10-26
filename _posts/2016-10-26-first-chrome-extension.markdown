---
layout: post
title:  "chrome插件-139邮箱助手"
date:   2016-10-26 18:23:04 +0800
categories: chrome extension
---

先吹个牛逼吧，哥也算是发布过chrome插件的人了。

当然，吹完牛逼，还得老老实实说话，其实事情是这样的。

以前一直用的插件“139邮箱助手”，后来突然没人不维护了。正好赶上了139邮箱升级，于是这个插件就各种显示错乱，基本属于不可用状态。

最后，自己动手，丰衣足食，经过两天的折腾，居然神奇地搞定了。

注：上面所做到的一切，都是基于我可以访问谷歌，如果你现在还不能，但是有这方面的需求，可以参考这一篇，并联系我。[shadowsocks打赏计划][shadowsocks-donation]

## 修改跳转，指向升级后的邮箱地址
chrome插件安装之后的本地源代码存放路径：
{% highlight sh %}
"~/Library/Application Support/Google/Chrome/Default/Extensions/"
{% endhighlight %}
在命令行操作时，记得给这个路径加上双引号，因为路径中有空格，当然也可以对空格进行转义。

右键查看插件的详细内容，会打开插件的详情页面，类似下面这样的地址：
{% highlight sh %}
https://chrome.google.com/webstore/detail/139邮箱助手/pefpambgoemhbfhilmhanahikdinkfpc
{% endhighlight %}
地址的最后一段路径，就是插件本地安装源代码的目录名称，也就是在这个目录中，我找到了插件的源代码。
{% highlight sh %}
"~/Library/Application Support/Google/Chrome/Default/Extensions/pefpambgoemhbfhilmhanahikdinkfpc"
{% endhighlight %}

[shadowsocks-donation]: http://blog.lutaoact.com/shadowsocks/2016/03/31/shadowsocks-donation.html
