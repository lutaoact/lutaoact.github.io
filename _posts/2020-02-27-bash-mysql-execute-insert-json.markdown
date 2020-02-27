---
layout: post
title:  "bash中使用mysql -e插入json字段到数据库"
date:   2020-02-27 14:03:09 +0800
categories: bash mysql json
---

test.json是一个多行的json，需要插入表a的value字段中，表a的建表语句如下：
{% highlight sh %}
create table a(
  id int AUTO_INCREMENT,
  value text,
  PRIMARY KEY (`id`)
);
{% endhighlight %}

# 操作流程
{% highlight sh %}
str=$(cat test.json)
str2=$(perl -pe 's/"|\047|\134/\134$&/g' <<< "$str")
mysql -uuser -p -hhost -Pport -Ddb -e 'insert into a(value) values("'"$str2"'");'
{% endhighlight %}
解释：

str2是利用perl将文本进行转义，转义三个字符单引号(`'`)、双引号(`"`)、反斜杠(`\\`)，`\047`表示单引号，`\134`表示反斜杠，因为最外层用了单引号，所以这两个字符直接使用8进制数表示，否则无法转义。

`mysql -e`执行插入命令，注意`"'"$str2"'"`，第一个`"`为sql语句中字符串值的开始引号，接着的`'`表示闭合shell的字符串，对应的开始引号在`insert`前面。紧接着`"$str2"`表示用shell解释变量str2，并保留变量中的所有格式和空白，下一个`'`表示shell字符串开始，然后`"`表示sql语句中字符串值的闭合引号。

str2变量也可以直接采用如下方式得到：
{% highlight sh %}
str2=$(perl -pe 's/"|\047|\134/\134$&/g' <(cat test.json))
{% endhighlight %}
解释：利用进程代换([Process Substitution](https://www.tldp.org/LDP/abs/html/process-sub.html))的原理。
