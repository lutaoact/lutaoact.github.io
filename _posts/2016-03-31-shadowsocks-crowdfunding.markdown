---
layout: post
title:  "shadowsocks代理-众筹计划"
date:   2016-03-31 11:23:40 +0800
categories: shadowsocks
---

## 下载软件
* windows
[下载][download-shadowsocks-windows]
* mac
[下载][download-shadowsocks-mac]

1. 下载之后安装，然后进行服务器信息设置，可以通过shadowsocks软件自带的扫描二维码功能直接录入服务器信息：（以mac版为例，windows版基本操作也差不多）

    ![扫描二维码][scan-qrcode-qn]

    二维码可以联系我来索取，因为服务器是个人花钱部署的，所以不方便完全公开，请大家谅解。

2. 理论上，录入服务器信息，然后浏览器就可以打开google.com了，如果不能，关闭shadowsocks，然后重新打开，如果还有问题，请单独联系我([i@lutaoact.com](mailto:i@lutaoact.com))

    ![关闭shadowsocks][close-shadowsocks-qn]

3. 这一步，可选。更新pac文件（即代理自动配置文件，用来对某些域名自动翻墙，而对其它域名不作处理）

    ![更新pac文件][update-pac-qn]

## 命令行使用
如果需要在linux命令行中使用代理，可以通过polipo将socks代理转为http代理，需要的，也私聊吧，我看看有没有必要把这部分也写完。

* `polipo`源码 [下载][download-polipo-linux]

## 捐赠列表
服务器是aws在日本的服务器，每个月大约20刀的费用（人民币100多块），很稳定，速度也不慢，虽然有人说貌似也有比较便宜的，但懒得换了，翻墙这事，我还是觉得稳定压倒一切，现在已经须臾离不开google了，国内某搜索真心没法用，啥都找不到，别说技术相关了，我媳妇是文科生，都嫌搜到的资料质量低。下面是一些用服务的朋友给的支持，我承诺会将每一笔捐赠都公开，并将所得全部用于维护服务器，希望能一直稳定高速地运行下去。

* 释呆: 99 2016-03-31
* tfier: 99 2016-03-10
* 十二: 50  2016-02-05

[download-shadowsocks-windows]: http://7xsgzh.com1.z0.glb.clouddn.com/Shadowsocks.exe
[download-shadowsocks-mac]: http://7xsgzh.com1.z0.glb.clouddn.com/ShadowsocksX-2.6.3.dmg
[scan-qrcode-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img%2Fscan-qrcode.png
[update-pac-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img%2Fupdate-pac.jpg
[close-shadowsocks-qn]: http://7xsgzh.com1.z0.glb.clouddn.com/img/3.png
[download-polipo-linux]: http://www.pps.univ-paris-diderot.fr/~jch/software/files/polipo/polipo-1.1.1.tar.gz
