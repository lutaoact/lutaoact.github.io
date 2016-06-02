---
layout: post
title:  "linux: 通过源代码安装gcc（centos为例）"
date:   2016-06-02 16:07:05 +0800
categories: gcc
---

## 前提条件
gcc的安装过程需要依赖g++，确认系统中已经有g++
{% highlight sh %}
g++ -v #查看版本
sudo yum -y install gcc-c++ #安装g++
{% endhighlight %}

## 安装过程
更新gcc属于系统大工程，普通用户谨慎操作。

以下操作针对root用户整理，若为普通用户，需要以sudo权限执行make install

{% highlight sh %}
#镜像地址 http://www.gnu.org/prep/ftp.html，找一个比较快的
wget http://mirrors.ustc.edu.cn/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
tar xvfj gcc-5.3.0.tar.bz2
cd gcc-5.3.0

#下载依赖mpfr gmp mpc isl，这个比自己手动下载要方便很多
#如果下载过程太慢，可用其它更快的镜像源替换脚本中的下载地址。也可以给wget加上-c参数，断线续传
./contrib/download_prerequisites

./configure --disable-multilib #--prefix=/usr，默认为/usr/local
#如果提示没有makeinfo，则yum -y install texinfo

make #-j8 8核 可以加-j参数，用来指定cpu核数
#获取CPU核数：cat /proc/cpuinfo | grep -c processor
#make需要依赖g++，yum install gcc-c++
#make这个过程要进行很久的，半个小时左右，gcc编译安装之后目录从100多M变成了5G

make install #若为普通用户，这里执行sudo make install

#如果默认安装路径/usr/local，需要转到/usr目录下
sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 40
{% endhighlight %}
