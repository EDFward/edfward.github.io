---
title: Python Module of the Week - lxml
tags: python, xml, pymotw
---
想要系统地整理学习一下 Python 各种各样的 Module，于是开这么一个系列。打算 Gist 为主，文字说明为辅，可能的话再加上一些小故事和小感触（鸡汤注意）。

******

以前处理 XML 都是 linux 神器三板斧，结果最近遇到了稍微复杂的情况得写 XPath，第一反应是求助宇宙第一字符串处理神器 Perl，结果惨不忍睹（点名批评 XML::Parser…）。好吧其实 Perl 上也有好用的 XML parser 只是我没找到而已。结果就邂逅了 [lxml](http://lxml.de/)，一个基于 C 库 libxml2 和 libxslt 的 Python module，按照 ElementTree API 进行封装：

> “But I have found that sitting under the ElementTree, one can feel the Zen of XML.”  
> — Essien Ita Essien

注：lxml 与 原生的 ElementTree 还是有一定差别的，这里主要介绍 lxml 的一些特性

<script src="https://gist.github.com/EDFward/6549375.js"></script>

- line 4: 有趣的参数包括
	- `ns_clean` - try to clean up redundant namespace declarations
	- `recover` - try hard to parse through broken XML
	- `remove_comments` - discard comments
	- `encoding` - override the document encoding
- line 31, 32: 有筛选的遍历，参数为空则是遍历所有 tag
- line 39: 关于 attributes  

> Note that attrib is a dict-like object backed by the Element itself. This means that any changes to the Element are reflected in attrib and vice versa. It also means that the XML tree stays alive in memory as long as the attrib of one of its Elements is in use. To get an independent snapshot of the attributes that does not depend on the XML tree, copy it into a dict (by deepcopy)

- line 52: *event* 分别代表刚接触一个 tag，刚关掉一个 tag，开始一个新的 namespace，结束一个 namespace
- line 58: 类似于 XPath，参数就是一个 query
- line 64: 去掉 namepspace，否则 XPath 的 query 要指定相应的 namespace
- line 68: 来自 [FAQ](http://lxml.de/FAQ.html)，比较有趣就摘录了

一个实际的例子就是以前为了提取 [FrameNet](https://framenet.icsi.berkeley.edu/fndrupal/) 里的数据写的脚本：

<script src="https://gist.github.com/EDFward/6549406.js"></script>

实际上就是基础的 lxml 应用加上一点 XPath，作用是提取特定 Frame 里特定 Role 的相应内容。(FrameNet 的数据可以看这个[例子](http://adapt.seiee.sjtu.edu.cn/~ed/fndata/fulltext/NTI__BWTutorial_chapter1.xml)，记得用浏览器看 Frame Source 才能看到真正的 XML)

当然 lxml 还有很多厉害的功能（比如 `lxml.objectify` 把 XML 变成 Python 的 datatype），这些就等以后用到了再在这里更新吧。

最后，还是那句老生常谈：要想用的妙，多看 Documentation（甚至是源码）。

PS. 关于 namespace 的问题 (SO): [lxml etree xmlparser namespace problem](http://stackoverflow.com/questions/4255277/lxml-etree-xmlparser-namespace-problem)

******

update @ 9/14/2013

又是一个[好问答](http://stackoverflow.com/questions/2352840/parsing-broken-xml-with-lxml-etree-iterparse)。  

> The code above is what you need for 90% of your XML parsing cases. Here I'll restate it:

{% highlight python %}
magical_parser = XMLParser(encoding='utf-8', recover=True)
tree = etree.parse(StringIO(your_xml_string), magical_parser) #or pass in an open file object
{% endhighlight %}
