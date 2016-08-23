---
layout: post
title:  "在windows中使用putty免密登录"
date:   2016-08-23 11:30:11 +0800
categories: windows putty
---

在linux中，这个实现比较容易，按下不表，这里给出windows系统中的配置过程：

## putty
[下载地址](https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe)

{% highlight text %}
Session中：
* 设置Host Name(or IP address)，Port(默认为22)

Connection -> SSH -> Auth中：
* 加载私钥文件，即Private key file for authentication项中载入.ppk私钥文件
{% endhighlight %}

如果需要开启ssh隧道，可以增加如下配置：
{% highlight sh %}
Connection -> SSH -> Tunnels中：
* 设置隧道类型和端口：Source port和Destination，选择Local、Remote、Dynamic分别对应
  不同的forward方式，点击Add，添加完成。这里的配置需要一定的ssh隧道的相关经验。
{% endhighlight %}

## plink
[下载地址](https://the.earth.li/~sgtatham/putty/latest/x86/plink.exe)

plink就是putty的命令行版本，跟ssh命令比较类似，参数上略有不同，具体根据使用情况查阅。

如果你要在windows的命令行中使用plink，记得将plink的路径加入到环境变量PATH中去。
{% highlight text %}
# 登录
plink user@host
plink -i .\key.ppk user@host #使用密钥

# 也可以开隧道，参数和ssh基本相同
plink -N -L 54320:127.0.0.1:5432 user@host #LocalForward
plink -N -L 54320:127.0.0.1:5432 -i .\key.ppk user@host #LocalForward，使用密钥授权
{% endhighlight %}

## 注意事项：

* putty使用专用的私钥文件格式，可以通过[puttygen][puttygen-download]来生成密钥对。
{% highlight sh %}
1. Action: Generate a public/private key pair
生成的时候需要鼠标在空白区域随机移动，需要利用这个随机信息来生成密钥对。
2. Action: Save the generated key
{% endhighlight %}
* 如果已有ssh-keygen程序生成的私钥文件，可以使用puttygen转换其格式，生成新的.ppk文件。
{% highlight sh %}
1. Action: Load an existing private key file
2. Action: Save the generated key
{% endhighlight %}

[puttygen-download]: https://the.earth.li/~sgtatham/putty/latest/x86/puttygen.exe
