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

* 时差`utcOffset`
{% highlight js %}
moment().utcOffset();//480 获取时差，以分钟为单位

//设置时差，以下三种方式等价
moment().utcOffset("+08:00");
moment().utcOffset(8);  //以小时为单位
moment().utcOffset(480);//以分钟为单位
{% endhighlight %}

* 本地化`locale`
{% highlight js %}
//设置周一为每周的第一天，默认周日为每周的第一天
moment.locale('en', {week: {
  dow: 1,// Monday is the first day of the week.
}})

moment.locale();//获取当前的locale
{% endhighlight %}

* 日期运算
日期运算的省略形式
{% highlight js %}
years => y
quarters => Q
months => M
weeks => w
days => d
hours => h
minutes => m
seconds => s
milliseconds => ms
{% endhighlight %}

{% highlight js %}
moment().subtract('1', 'w').startOf('week');
moment().add('1', 'w').endOf('week');
{% endhighlight %}

查阅[moment docs][moment-docs]获取详细帮助。

[moment-docs]: http://momentjs.com/docs/
