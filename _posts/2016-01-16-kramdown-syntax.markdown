---
layout: post
title:  "kramdown syntax"
date:   2016-01-16 14:21:41 +0800
categories: markdown kramdown
---
对于一些block元素, 需要前面有空行(这和传统markdown不同), 例如header(## header), list, fenced code block, math code.

##### Header5 {#ID5}

#### Header4 {#ID4}

### Header3 {#ID3}

## Header2 {#ID2}

Header2
---

# Header1

Header1
===

[GoH5](#ID5) [GoH4](#ID4)

This is some text[^1]. Other text[^footnote].


[blog](http://blog.lutaoact.com "涛哥的blog")

a [blog][lutaoact blog]

## 若要启用数学公式支持，需要引入MathJax.js
{% highlight html %}
<script src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
{% endhighlight %}
我在`_layouts/default.html`的body结束标签之前添加

$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$



This is inline $$\sum_{i=1}^n x_ie_i$$

[^1]: Some *crazy* footnote definition.
[^footnote]:
    > Blockquotes can be in a footnote.
        as well as code blocks
    or, naturally, simple paragraphs

[lutaoact blog]: http://blog.lutaoact.com
