---
layout: post
title:  "监控文件变动，自动重启服务的方案"
date:   2017-10-01 22:05:53 +0800
categories: fswatch inotify
---

暂时想法还不完善，只是一个粗糙的实现，先总结在这里，以后继续改进。

我使用vim编辑器，我希望修改代码之后，服务可以自动重启。

在linux系统中有`inotify-tools`包，包含`inotifywait`和`inotifywatch`这两条命令，可以很好地实现文件变动监控。在MAC中，我找到了一个类似的替代工具`fswatch`，可以直接用brew安装。

## 第一部分：监控文件变动并传给相关命令进行处理
命令如下，监控当前目录中除excludedir目录以外的所有子目录及文件，若有变动，则通过管道调用findServiceThenKill命令。
{% highlight sh %}
fswatch --exclude 'excludedir' -or . | xargs -n1 ~/bin/findServiceThenKill &
{% endhighlight %}

## 第二部分：findServiceThenKill
命令如下，查找服务进程pid，然后kill
{% highlight sh %}
ps axo 'user,pid,command' | grep 'service' | grep -v 'grep' | awk '{print $2}' | xargs kill
{% endhighlight %}

## 第二部分：自动重启服务
命令如下，将服务放在无限循环中，退出之后自动重启。
{% highlight sh %}
while true; do restartServer; done
{% endhighlight %}

## 总结
可以写一个函数，把两条命令整在一起，这样使用比较方便
{% highlight sh %}
function watchandrestart() {
  fswatch --exclude 'make' -or . | xargs -n1 ~/bin/findMakeThenKill &
  while true; do make run_local_hms; done
}
{% endhighlight %}

## 参考链接
* [Is there a command like “watch” or “inotifywait” on the Mac?](https://stackoverflow.com/questions/1515730/is-there-a-command-like-watch-or-inotifywait-on-the-mac){:target="_blank"}
