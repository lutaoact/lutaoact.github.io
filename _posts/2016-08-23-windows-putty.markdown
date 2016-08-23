---
layout: post
title:  "在windows中使用putty免密登录"
date:   2016-08-23 11:30:11 +0800
categories: windows putty
---

在linux中，这个实现比较容易，按下不表，这里给出windows系统中的配置过程：

putty [下载地址](https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe)

{% highlight text %}
Session中：
* 设置Host Name(or IP address)，Port(默认为22)

Connection -> SSH -> Auth中：
* 加载私钥文件，即Private key file for authentication项中载入.ppk私钥文件
{% endhighlight %}

## 注意事项：

* putty使用专用的私钥文件格式，可以通过[puttygen][puttygen-download]来生成密钥对。
{% highlight sh %}
1. Action: Generate a public/private key pair
生成的时候需要鼠标在空白区域随机动，需要利用这个随机信息来生成密钥对。
2. Action: Save the generated key
{% endhighlight %}
* 如果已有ssh-keygen程序生成的私钥文件，可以使用puttygen转换其格式，生成新的.ppk文件。
{% highlight sh %}
1. Action: Load an existing private key file
2. Action: Save the generated key
{% endhighlight %}

[puttygen-download]: https://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe
