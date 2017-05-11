---
layout: post
title:  "Out-of-Memory Kill Tunables"
date:   2017-05-11 19:27:22 +0800
categories: oom
---

Out of Memory (OOM) refers to a computing state where all available memory, including swap space, has been allocated. By default, this situation causes the system to panic and stop functioning as expected.

However, setting the `/proc/sys/vm/panic_on_oom` parameter to `0` instructs the kernel to call the `oom_killer` function when OOM occurs. Usually, `oom_killer` can kill rogue processes and the system survives.

The following parameter can be set on a per-process basis, giving you increased control over which processes are killed by the `oom_killer` function. It is located under `/proc/pid/` in the proc file system, where pid is the process ID number.

{% highlight text %}
oom_adj
Defines a value from -16 to 15 that helps determine the oom_score of a process.
The higher the oom_score value, the more likely the process will be killed by
the oom_killer. Setting a oom_adj value of -17 disables the oom_killer for
that process.
{% endhighlight %}

{% highlight text %}
Important: Any processes spawned by an adjusted process will inherit that
process's oom_score. For example, if an sshd process is protected from the
oom_killer function, all processes initiated by that SSH session will also
be protected. This can affect the oom_killer function's ability to salvage
the system if OOM occurs.
{% endhighlight %}

上面说sshd的子进程会继承`oom_score`，可测试发现，并没有，而是大了一点，暂时不明白原因：
{% highlight sh %}
$ ps -o user,pid,ppid,cmd $(pidof sshd)
USER       PID  PPID CMD
root      1500     1 /usr/sbin/sshd
root     17535  1500 sshd: centos [priv]
centos   17537 17535 sshd: centos@pts/1

$ cat /proc/1500/oom_score
0
$ cat /proc/17535/oom_score
1
$ cat /proc/17537/oom_score
1
{% endhighlight %}

{% highlight sh %}
$ lsb_release -a
LSB Version:    :base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch
Distributor ID:    CentOS
Description:    CentOS release 6.7 (Final)
Release:    6.7
Codename:    Final
{% endhighlight %}

## 参考链接
* [Capacity Tuning](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/s-memory-captun.html){:target="_blank"}
