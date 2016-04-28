---
layout: post
title:  "制作ubuntu安装启动U盘"
date:   2016-04-28 11:02:30 +0800
categories: ubuntu install
---

以下记录是我在mac上的操作流程：

{% highlight sh %}
# 将iso格式转化为img格式，mac会自动增加dmg扩展名，输出的文件是ubuntu.img.dmg
hdiutil convert ./ubuntu.iso -format UDRW -o ./ubuntu.img

# 假设已经插入U盘，查看该U盘所属的设备节点号
diskutil list #一般是/dev/disk2

diskutil unmountDisk /dev/diskN #卸载，并不是弹出eject，N为节点号，如上为2

sudo dd if=./ubuntu.img.dmg of=/dev/disk2 bs=1M status=progress
# bs参数，GNU版本用1M，如果报错，可能是因为dd版本是BSD的，可以改为1m
# status参数，是GNU Coreutils 8.24+ (Ubuntu 16.04 and newer)里面新增的参数
# 如果命令执行完成之后弹出选择窗口，不要选择任何操作，继续执行下面的命令

diskutil eject /dev/diskN #弹出，制作完成
{% endhighlight %}

最新的ubuntu 16.04提供了img文件下载，所以可以省略掉将iso文件转化为img文件的步骤，直接执行后续操作。

注：U盘大小需要超过2G。

[参考链接](http://www.ubuntu.com/download/desktop)
