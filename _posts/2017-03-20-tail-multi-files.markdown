---
layout: post
title:  "tail -f 查看多个日志文件（功能增强）"
date:   2017-03-20 23:57:58 +0800
categories: linux tail
---

首先，感谢伟大的stackoverflow的兄弟stackexchange。

`tail -f`用的最多的地方应该就是查看日志文件，可以传递多个参数来实现对多个文件的监控。
{% highlight sh %}
tail -f file1 file2
{% endhighlight %}
当监控文件发生变化的时候，会自动输出，并在输出之前，先打印一行如下标识。但这个表示只出现在文件改变后输出的第一行，并不会每行都有。
{% highlight text %}
==> file1 <==
==> file2 <==
{% endhighlight %}

如果我们希望日志的每一行都能出现文件名，这样就能清晰地知道日志是属于哪个文件的，有什么办法呢？

以下方案是我在google上搜索了好久找到的，亲测可行，不得不感叹一下人类的智慧真是无比璀璨啊。

## 方案1
{% highlight sh %}
tail -f file1 file2 |
    awk '/^==> / {a=substr($0, 5, length-8); next}
                 {print a":"$0}'
{% endhighlight %}
将对所有输出都通过管道传给awk，awk会匹配输出行，如果行首出现`==>`，则通过substr函数调用给变量a赋值，得到的a就是文件名。

我解释一下，$0表示当前行的内容，5表示从第5个字符开始，这里注意一下，awk中字符的下标是从1开始，不是从0开始。length表示当前行的长度，length-8就是去掉两头`==>`和`<==`以及两个空格。

重点是`next`，它表示立即停止处理当前行，并开始对下一行的处理。`print a":"$0`就是将文件名添加到所有后续行的前面。这真是一个非常巧妙的解决方案。

## 方案2
{% highlight sh %}
parallel --tagstring '{}:' --line-buffer tail -f {} ::: file1 file2
{% endhighlight %}
利用GNU的parallel命令，相关解释，看参考链接吧。

## 参考链接
* [Show filename at begining of each line when tailing multiple files at once?](http://unix.stackexchange.com/questions/195922/show-filename-at-begining-of-each-line-when-tailing-multiple-files-at-once){:target="_blank"}
