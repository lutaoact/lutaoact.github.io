---
layout: post
title:  "shadowsocks服务器支持计划"
date:   2016-03-31 11:23:40 +0800
categories: shadowsocks
---

## 下载软件

* windows [下载](/assets/)
* mac [下载](/assets/ShadowsocksX-2.6.3.dmg)

之前放在七牛云上供下载，现在因为七牛云的测试域名都实效了，所以没法用了，大家需要的时候直接联系我吧。

1. 下载之后安装，然后进行服务器信息设置，可以通过shadowsocks软件自带的扫描二维码功能直接录入服务器信息：（以mac版为例，windows版基本操作也差不多）

    ![扫描二维码][scan-qrcode-qn]

    二维码可以联系我来索取，因为服务器是个人花钱部署的，所以不方便完全公开，请大家谅解。

2. 理论上，录入服务器信息，然后浏览器就可以打开google.com了，如果不能，关闭shadowsocks，然后重新打开，如果还有问题，请单独联系我([i@lutao.me](mailto:i@lutao.me))

    ![关闭shadowsocks][close-shadowsocks-qn]

3. 这一步，可选。更新pac文件（即代理自动配置文件，用来对某些域名自动翻墙，而对其它域名不作处理）

    ![更新pac文件][update-pac-qn]

## 命令行使用
如果需要在linux命令行中使用代理，可以通过polipo将socks代理转为http代理，需要的，也私聊吧，我看看有没有必要把这部分也写完。

* `polipo`源码 [下载][download-polipo-linux]

[download-shadowsocks-windows]: http://7xsgzh.com1.z0.glb.clouddn.com/Shadowsocks.exe
[download-shadowsocks-windows-2-5-2]: http://7xsgzh.com1.z0.glb.clouddn.com/Shadowsocks-2.5.2.exe
[download-shadowsocks-mac]: http://7xsgzh.com1.z0.glb.clouddn.com/ShadowsocksX-2.6.3.dmg
[scan-qrcode-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img%2Fscan-qrcode.png
[update-pac-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img%2Fupdate-pac.jpg
[close-shadowsocks-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img/3.png
[download-polipo-linux]: http://7xsgzh.com1.z0.glb.clouddn.com/polipo-1.1.1.tar.gz
