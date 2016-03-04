---
layout: post
title:  "nodejs moment模块使用"
date:   2016-03-04 14:45:54 +0800
categories: nodejs moment
---
* 最常用的时间格式化：
{% highlight js %}
moment().format('YYYY-MM-DDTHH:mm:ssZ');//(Z表示时区)
//2016-03-04T07:00:00+08:00
moment().format('YYYY-MM-DD HH:mm:ss');
//2016-03-04 07:00:00
{% endhighlight %}

* 经常用到的两种不同的时间字符串装换方式，分别表示0时区和当前所在的时区
{% highlight js %}
moment().toISOString();//2016-03-04T07:00:00Z
moment().format();     //2016-03-04T07:00:00+08:00
{% endhighlight %}

查阅[moment docs][moment-docs]获取详细帮助。

[moment-docs]: http://momentjs.com/docs/
