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

* `moment`构建对象时，如果传入的是时间戳参数，则默认使用毫秒时间戳，若使用秒时间戳，则应传入格式化字符`'X'`
{% highlight js %}
moment(1410715640579); //毫秒时间戳
moment(1410715640, 'X'); //秒时间戳
{% endhighlight %}

查阅[moment docs][moment-docs]获取详细帮助。

[moment-docs]: http://momentjs.com/docs/
