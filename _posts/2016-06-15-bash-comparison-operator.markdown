---
layout: post
title:  "bash中的比较操作符"
date:   2016-06-15 10:55:03 +0800
categories: linux bash operator
---

bash中的变量并不是强类型的，整数比较和字符串比较之间存在一些模糊的地方，所以bash中使用不同的操作符来比较整数和字符串。

## 整数比较

* 使用test命令检查结果，`if [ ... ]`
{% highlight sh %}
-eq #相等
-ne #不相等
-gt #大于
-ge #大于等于
-lt #小于
-le #小于等于
{% endhighlight %}

* 使用双括号检查结果，`if (( ... ))`，只在bash 2.04以及之后的版本中可用
{% highlight sh %}
== #相等
!= #不相等
>  #大于
>= #大于等于
<  #小于
<= #小于等于
{% endhighlight %}

## 字符串比较
{% highlight sh %}
{% endhighlight %}
