---
layout: post
title:  "【译】golang net/http timeout 完整指南"
date:   2018-03-17 16:38:16 +0800
categories: golang http timeout
---

在Go中编写HTTP服务器或客户端时，超时是最容易，也最细微的出错点之一：有很多可供选择的选项，并且一个错误在很长一段时间内不会有任何后果，直到网络出现故障并且进程挂起。

HTTP是一个复杂的多阶段协议，所以没有适合所有超时的解决方案。考虑以下不同情况，比如流式传输端点、JSON API或者Comet端点，默认设置通常不是你想要的。

在这篇文章中，我将分解您可能需要应用超时的各个阶段，并在服务器和客户端上查看执行此操作的不同方法。

## SetDeadline
首先，您需要了解Go对外暴露的实现超时的网络原语(network primitive)：`Deadline`

它通过`net.Conn`的`Set[Read/Write]Deadline(time.Time)`方法来对外暴露，Deadline是一个绝对时间，到达之后就会使所有的I/O操作都因超时错误而失败。

**Deadline不是timeout**。一旦设置，无论此时连接是否被使用以及如何使用，它都将永远保持生效（或者直到下次调用`SetDeadline`）。因此，要使用`SetDeadline`构建超时，您必须在每次读/写操作之前调用它。

你应该并不想自己调用`SetDeadline`，而是希望让`net/http`使用更高级的timeout来为你调用。但是请记住，所有超时都是按照Deadline来实现的，所以**每次发送或接收数据时并不会重置**。

## 服务器端超时
博文 [[So you want to expose Go on the Internet][ref-post]] 介绍了更多关于服务器端timeout的信息，尤其是HTTP/2和Go 1.7的bug。

![Timeouts-001.png](/assets/Timeouts-001.png)

对于暴露给Internet的HTTP服务器来说，强制进行客户端连接超时设置非常重要。否则，非常慢或消失的客户端可能会泄漏文件描述符，并最终导致产生以下内容：
{% highlight sh %}
http: Accept error: accept tcp [::]:80: accept4: too many open files; retrying in 5ms
{% endhighlight %}

`http.Server`暴露了两个timeout，`ReadTimeout`和`WriteTimeout`。你可以显式地使用`Server`来设置它们：
{% highlight sh %}
srv := &http.Server{
    ReadTimeout: 5 * time.Second,
    WriteTimeout: 10 * time.Second,
}
log.Println(srv.ListenAndServe())
{% endhighlight %}
`ReadTimeout`覆盖了从连接被接受到请求body被完全读取的时间（如果你确实读取了正文，否则就是到header结束）。它的实现是在`net/http`中，通过在`Accept`后立即调用`SetReadDeadline`来实现的。[[参考](https://github.com/golang/go/blob/3ba31558d1bca8ae6d2f03209b4cae55381175b3/src/net/http/server.go#L750)]

`WriteTimeout`通过在`readRequest`结束时调用`SetWriteDeadline`来设置，通常覆盖从请求header读取结束到响应写入结束（也就是`ServeHTTP`的生存期）的时间。[[参考](https://github.com/golang/go/blob/3ba31558d1bca8ae6d2f03209b4cae55381175b3/src/net/http/server.go#L753-L755)]

但是，当连接是`HTTPS`时，`SetWriteDeadline`在`Accept`之后立即被调用，以便它也覆盖作为TLS握手的一部分而写入的数据包。令人烦恼的是，这意味着（只在这种情况下）`WriteTimeout`最终包括读取头部和等待第一个字节的时间。[[参考](https://github.com/golang/go/blob/3ba31558d1bca8ae6d2f03209b4cae55381175b3/src/net/http/server.go#L1477-L1483)]

在处理不受信任的客户端和/或网络时，应该将这两个超时都设置上，以便客户端无法通过慢读写来长时间持有连接。

最后是`http.TimeoutHandler`。它不是服务器参数，而是一个限制`ServeHTTP`调用最大duration的`Handler`包装器。它的工作方式是缓冲响应，并在超过最后期限时发送`504 Gateway Timeout`。注意，它在1.6中被破坏并在1.6.2中得到修复。[[参考](https://github.com/golang/go/issues/15327)]

## http.ListenAndServe做错了
顺便说一句，这意味着像`http.ListenAndServe`，`http.ListenAndServeTLS`和`http.Serve`这样绕过`http.Server`的包级别的便利函数不适用于公共Internet服务器。

这些函数将timeout的设置默认留为off，并且无法启用它们，因此，如果使用它们，你很快就会泄漏连接，并耗尽文件描述符。这样的错误，我至少犯过半打了。

正确的做法是，使用`ReadTimeout`和`WriteTimeout`创建一个`http.Server`实例并使用其相应的方法，就像上面几段中的示例一样。

## 关于streaming
非常恼人的是，没有办法从`ServeHTTP`访问底层`net.Conn`，因此希望能够流式传输响应的服务器必须取消`WriteTimeout`（这也可能是默认情况下为0的原因）。这是因为没有办法访问`net.Conn`，就没有办法在每次写入操作之前调用`SetWriteDeadline`来实现适当的空闲（而非绝对）timeout。

此外，无法取消一个阻塞的`ResponseWriter.Write`，因为`ResponseWriter.Close`（你可以通过接口升级访问）不是记录为用来unblock并发Write的。因此，也无法使用Timer手动建立超时。

很可悲，这意味着流式响应服务器无法真正防止慢读的客户端。

我提交了一个包含提案的issue，欢迎反馈。[[参考](https://github.com/golang/go/issues/16100)]

## 客户端超时
![Timeouts-002.png](/assets/Timeouts-002.png)

客户端超时可以更简单或复杂得多，这取决于你使用哪些，但同样重要的是防止泄露资源或卡住。最容易使用的是`http.Client`的`Timeout`字段。它涵盖了从拨号（如果连接不被重用）到读取body的整个交换过程。
{% highlight sh %}
c := &http.Client{
    Timeout: 15 * time.Second,
}
resp, err := c.Get("https://blog.filippo.io/")
{% endhighlight %}
与上面的服务器端案例一样，`http.Get`等包级别函数使用[[没有超时的客户端](https://golang.org/pkg/net/http/#DefaultClient)]，因此在开放的Internet上使用时很危险。

要进行更精细的控制，也可以设置其它更具体的timeout：
* `net.Dialer.Timeout`限制建立TCP连接所花费的时间（如果需要新的连接）
* `http.Transport.TLSHandshakeTimeout`限制执行TLS握手所花费的时间
* `http.Transport.ResponseHeaderTimeout`限制读取响应header的时间
* `http.Transport.ExpectContinueTimeout`限制客户端在发送包含`Expect: 100-continue`的请求header和接收发送主体的请求header之间等待的时间。请注意，在1.6中设置它将禁用`HTTP/2`（`DefaultTransport`是从1.6.2开始的[特殊情况](https://github.com/golang/go/commit/406752b640fcc56a9287b8454564cffe2f0021c1#diff-6951e7593bfb1e773c9121df44df1c36R179)）。[[参考](https://github.com/golang/go/issues/14391)]

{% highlight sh %}
c := &http.Client{
    Transport: &http.Transport{
        Dial: (&net.Dialer{
                Timeout:   30 * time.Second,
                KeepAlive: 30 * time.Second,
        }).Dial,
        TLSHandshakeTimeout:   10 * time.Second,
        ResponseHeaderTimeout: 10 * time.Second,
        ExpectContinueTimeout: 1 * time.Second,
    }
}
{% endhighlight %}

据我所知，无法专门限制发送请求的时间。花在阅读请求体上的时间可以用一个`time.Timer`手动控制，因为它发生在`Client`方法返回后（见下面有关如何取消请求）。

最后，在1.7中新增了`http.Transport.IdleConnTimeout`。它不是控制客户端请求的阻塞阶段，而是控制空闲连接保留在连接池中的时间。

请注意，客户端默认会跟随重定向。`http.Client.Timeout`包括重定向后的所有时间，而细粒度超时是每个请求特有的，因为`http.Transport`是一个没有重定向概念的低级系统。

## Cancel and Context
`net/http`提供了两种取消客户端请求的方式：`Request.Cancel`和1.7中新增的`Context`。

`Request.Cancel`是一个可选channel，当设置了之后，如果关闭它就会导致请求中止，就好像`Request.Timeout`到了一样（它们实际上是通过相同的机制实现的，而且在写这篇文章的时候，我发现了1.7版的一个[[bug](https://github.com/golang/go/issues/16094)]，所有的取消都会作为超时错误返回）。

我们可以使用`Request.Cancel`和`time.Timer`来构建一个更细化的超时，允许流式传输，每当我们成功读取Body中的一些数据时，就推迟deadline：
{% highlight golang %}
package main

import (
    "io"
    "io/ioutil"
    "log"
    "net/http"
    "time"
)

func main() {
    c := make(chan struct{})
    timer := time.AfterFunc(5*time.Second, func() {
        close(c)
    })

        // Serve 256 bytes every second.
    req, err := http.NewRequest("GET", "http://httpbin.org/range/2048?duration=8&chunk_size=256", nil)
    if err != nil {
        log.Fatal(err)
    }
    req.Cancel = c

    log.Println("Sending request...")
    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        log.Fatal(err)
    }
    defer resp.Body.Close()

    log.Println("Reading body...")
    for {
        timer.Reset(2 * time.Second)
                // Try instead: timer.Reset(50 * time.Millisecond)
        _, err = io.CopyN(ioutil.Discard, resp.Body, 256)
        if err == io.EOF {
            break
        } else if err != nil {
            log.Fatal(err)
        }
    }
}
{% endhighlight %}

在上面的例子中，我们在请求的Do阶段放置了5秒的超时，但是随后我们花费了至少8秒钟的时间在8轮中读取正文，每次超时时间为2秒。我们可以像这样永远不断地流式传输，而不会有被卡住的风险。如果我们超过2秒没有收到body数据，那么`io.CopyN`会返回`net/http: request canceled`。

在1.7中，`context`包已经上升到标准库。有许多关于上下文的知识，但关于我们的目的，只需要知道他们会替换并弃用`Request.Cancel`。

要使用Context来取消请求，我们只需使用`context.WithCancel`获得新的`Context`和它的`cancel()`函数，并使用`Request.WithContext`创建一个绑定到它的请求。当我们要取消请求时，我们通过调用`cancel()`来取消`Context`（而不是关闭Cancel channel）：

{% highlight sh %}
ctx, cancel := context.WithCancel(context.TODO())
timer := time.AfterFunc(5*time.Second, func() {
    cancel()
})

req, err := http.NewRequest("GET", "http://httpbin.org/range/2048?duration=8&chunk_size=256", nil)
if err != nil {
    log.Fatal(err)
}
req = req.WithContext(ctx)
{% endhighlight %}

Context的优点是，如果父context（我们传递给`context.WithCancel`的那个context）被取消，我们也将被取消，会沿着整个pipeline传播命令。

## 相关链接
* [The complete guide to Go net/http timeouts](https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/){:target="_blank"}

[ref-post]: https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/
