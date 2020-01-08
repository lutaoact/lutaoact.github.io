FROM ubuntu:18.04

RUN echo 'deb http://mirrors.163.com/ubuntu/ bionic main restricted universe multiverse\n\
deb http://mirrors.163.com/ubuntu/ bionic-security main restricted universe multiverse\n\
deb http://mirrors.163.com/ubuntu/ bionic-updates main restricted universe multiverse\n\
deb http://mirrors.163.com/ubuntu/ bionic-proposed main restricted universe multiverse\n\
deb http://mirrors.163.com/ubuntu/ bionic-backports main restricted universe multiverse\n\
deb-src http://mirrors.163.com/ubuntu/ bionic main restricted universe multiverse\n\
deb-src http://mirrors.163.com/ubuntu/ bionic-security main restricted universe multiverse\n\
deb-src http://mirrors.163.com/ubuntu/ bionic-updates main restricted universe multiverse\n\
deb-src http://mirrors.163.com/ubuntu/ bionic-proposed main restricted universe multiverse\n\
deb-src http://mirrors.163.com/ubuntu/ bionic-backports main restricted universe multiverse' > /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssl vim curl netcat ca-certificates locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 支持UTF-8字符编码 https://github.com/jekyll/jekyll/issues/4268
RUN locale-gen zh_CN.UTF-8 && /usr/sbin/update-locale LANG=zh_CN.UTF-8

ENV LANG zh_CN.UTF-8

RUN apt-get update && apt-get install -y ruby-full build-essential zlib1g-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /code

RUN gem install bundler --no-ri --no-rdoc && bundle config mirror.https://rubygems.org https://gems.ruby-china.com
