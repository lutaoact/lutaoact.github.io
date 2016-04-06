---
layout: post
title:  "linux笔记整理"
date:   2016-03-17 09:58:27 +0800
categories: linux bash
---

* bash中检查变量是否为空，`-n`检查非空为真，`-z`检查空为真
{% highlight sh %}
if [ -n "$VAR" ]; then
  echo "VAR is not empty"
fi

if [ -z "$VAR" ]; then
  echo "VAR is empty"
fi
{% endhighlight %}

* openssl生成文件或字符串的校验和
{% highlight sh %}
openssl sha1/md5 filename #生成指定文件的校验和
echo -n 'xxx' | openssl md5 #生成字符串的校验和
{% endhighlight %}

* watch命令以指定时间间隔自动地运行指定的命令，默认的时间间隔为2秒
{% highlight sh %}
watch sar -P ALL 1 1 #查看所有cpu的使用情况
watch ls -l #查看文件大小的变化
{% endhighlight %}

* rsync同步两个目录
{% highlight sh %}
rsync -rv --exclude=.git \
          --exclude=.gitignore \
          --exclude-from=node-server/.gitignore \
          ~/node-server/ ~/Service/trunk/node-server/
# --exclude      #排除的目录或文件
# --exclude-from #从指定文件中读出排除的目录或文件
# 源路径如果以/结尾，表示同步目录中的内容，如果没有/，则表示同步目录本身
{% endhighlight %}

* 命令行中读入变量CMD的两种方法
{% highlight sh %}
read -r -d '' CMD <<'EOF'
echo "In"
whoami
EOF
{% endhighlight %}
{% highlight sh %}
CMD=$(cat << 'EOF'
echo "In"
echo $PATH
whoami
EOF
)
{% endhighlight %}
{% highlight sh %}
echo "$CMD" #必须要有双引号，可以保留换行
su --login centos -c "$CMD" #以centos用户来执行命令
{% endhighlight %}

* 通过源码安装新版的`gcc`
{% highlight sh %}
#镜像地址 http://www.gnu.org/prep/ftp.html，找一个比较快的
wget http://mirrors.ustc.edu.cn/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2
tar xvfj gcc-5.3.0.tar.gz
cd gcc-5.3.0

#下载依赖mpfr gmp mpc isl，这个比自己手动下载要方便很多
./contrib/download_prerequisites

./configure --disable-multilib #--prefix=/usr，默认为/usr/local
#如果提示没有makeinfo，则yum -y install texinfo

make #-j8 8核 可以加-j参数，用来指定cpu核数
#make需要依赖g++，yum install gcc-c++
#make这个过程要进行很久的，半个小时左右，gcc编译安装之后目录从100多M变成了5G

make install

#如果默认安装路径/usr/local，需要转到/usr目录下
sudo update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 40
{% endhighlight %}

* centos下`g++`安装包名字叫做：`gcc-c++`
{% highlight sh %}
sudo yum -y install gcc-c++
{% endhighlight %}
