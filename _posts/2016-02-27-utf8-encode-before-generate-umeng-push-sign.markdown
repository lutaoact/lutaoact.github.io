---
layout: post
title:  "nodejs调用友盟push API: 签名错误问题"
date:   2016-02-27 01:16:27 +0800
categories: nodejs utf8 encode umeng
---
推送内容中若包含中文，则会报签名错误问题，错误码`"2027 签名不正确"`。

这是因为中文编码的问题，在计算md5签名之前，需要先对字符串进行`utf8.encode`.

{% highlight js %}
utf8.encode(method + url + post_body + app_master_secret)
{% endhighlight %}

`utf8`并不是系统自带模块，需要自行安装：
{% highlight sh %}
npm install utf8
{% endhighlight %}

查阅[utf8][utf8-gh]获取相关帮助。

附：`nodejs`中计算`md5`值的方法：
{% highlight js %}
const crypto = require('crypto');
let md5sum = crypto.createHash('md5').update(str).digest('hex');//md5值
{% endhighlight %}

[utf8-gh]: https://github.com/mathiasbynens/utf8.js
