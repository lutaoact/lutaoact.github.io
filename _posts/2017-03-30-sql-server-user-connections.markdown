---
layout: post
title:  "SQL server连接时好时坏的奇怪问题"
date:   2017-03-30 17:50:41 +0800
categories: sql-server sp_configure
---

如果无法定位问题所在，当我们向别人求助时，我们甚至不知道该如何提问。

因为合作商的关系，我们有一台服务器是Windows系统的，运行SQL server，而团队的所有成员都并不熟悉这套东西。重启了服务器，然后注意到一个问题，数据库连接总是时好时坏。我用的是nodejs的[mssql][mssql-doc]模块，非常可恨，程序没有连接成功，也没有报任何错，反正就是什么都没有。

搞这些不熟悉的东西，真是一件很费心的事情。

服务器上：


## 参考链接
* [How to use SP_CONFIGURE in SQL Server](https://straightpathsql.com/archives/2009/10/how-to-use-sp_configure-in-sql-server/){:target="_blank"}

[mssql-doc]: https://github.com/patriksimek/node-mssql/blob/1893969195045a250f0fdeeb2de7f30dcf6689ad/README.md
