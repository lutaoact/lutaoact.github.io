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
-ne #不等
-gt #大于
-ge #大于等于
-lt #小于
-le #小于等于
{% endhighlight %}

* 使用双括号检查结果，`if (( ... ))`，只在bash 2.04以及之后的版本中可用
{% highlight sh %}
== #相等
!= #不等
>  #大于
>= #大于等于
<  #小于
<= #小于等于
{% endhighlight %}

## 字符串比较
{% highlight sh %}
== = #相等，在字符串比较中是相同的，

# 相等比较运算符在使用双方括号[[ ... ]]进行检查，和使用[ ... ]时会有所不同
[[ "$a" == z* ]]   # True if $a starts with an "z" (pattern matching).
[[ "$a" == "z*" ]] # True if $a is equal to z* (literal matching).

[ "$a" == z* ]     # File globbing and word splitting take place.
[ "$a" == "z*" ]   # True if $a is equal to z* (literal matching).

!= #不等，类似于==，在双方括号中会启动模式匹配(pattern matching)

# 以下比较都是基于ASCII字符顺序，并且操作符需要转义，双方括号具有转义作用
# 即使用[[ "$a" > "$b" ]]或[ "$a" \> "$b" ]
>  #大于
<  #小于

# 注意，字符串比较中，并没有'>='和'<='这两个操作符，至少在我所用的bash 4.3中还没有
{% endhighlight %}
