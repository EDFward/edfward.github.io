---
title: 基于 Sphinx/Coreseek 的全文检索引擎
tags: python, php, wechat, sphinx, dailyzhihu
---
知乎日报的文章向来质量很高，遗憾的是不像知乎本身可以进行内容的搜索。恰好在和另一个朋友捣鼓微信公众账号，自然就想到利用后台的全文检索来实现这个功能。

用 PHP 和 [Coreseek](http://www.coreseek.com) (一款基于Sphinx并支持中文的开源检索引擎) 实现最后的效果如图：

>对不起静态图都挂了哇哈哈

下面来说一下实现步骤顺便也备忘一下。

### Step 1: DATA
第一步当然是利用知乎日报提供的 api 提取数据并放入数据库中。 

<script src="https://gist.github.com/EDFward/6432502.js"></script>

- 通过一些观察就能知道 api 的用法，这里就不赘述了。
- schema 包括文章标题，问题标题，作者，图片链接等。这里用的是一个轻量级的 ORM: [peewee](https://github.com/coleifer/peewee)，相比起厚重的 Django 来说这个库安装使用起来非常轻巧。由于数据库用的是 MySQL 所以需要 MySQLdb，不要忘了 `sudo apt-get install python-mysqldb`
- 由于 api 提供的内容格式还是 HTML，所以用 [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/) 来提取特定的 tag 内容。（还得考虑到很多知乎日报的文章是由多个问题/答案串在一起构成的）
- 一个重要的细节就是为了支持之后的中文 indexing, MySQL 的编码一定要是 UTF-8。可以通过[修改 MySQL 默认字符集](http://database.51cto.com/art/201010/229167.htm)或者[在 MySQL 里修改表、字段、库的字符集](http://fatkun.com/2011/05/mysql-alter-charset.html)的方法实现。

跑完这个脚本之后就算是拿到了原始数据，以后每天再做增量更新就行。

### Step 2: INDEXING
全文检索最重要的部分当然就是检索引擎了。Lucene 的大名很早就听说过，但是最终还是选择了比较适合 PHP 的 Sphinx/Coreseek 来做中文索引。Stackoverflow 有篇[很赞的比较文章](http://stackoverflow.com/questions/737275/comparison-of-full-text-search-engine-lucene-sphinx-postgresql-mysql)，以及来自[这篇 blog](http://www.cnblogs.com/gaoxu387/archive/2012/11/30/2794822.html) 的一副图:

![sphinx](http://www.oschina.net/uploads/img/200904/08140241_YWNE.png)

初次进行配置还是比较麻烦…其实也没什么好说的，多看看文档和一些快速教程基本就能摸清流程了。首先要了解 indexing 的工作流程 (如果数据源是 SQL 的话)

> With all the SQL drivers, indexing generally works as follows. 
> 
> - connection to the database is established;
> - pre-query is executed to perform any necessary initial setup, such as setting per-connection encoding with MySQL;
> - main query  is executed and the rows it returns are indexed;
> - post-query  is executed to perform any necessary cleanup;
> - connection to the database is closed;
> - indexer does the sorting phase (to be pedantic, index-type specific post-processing);
> - connection to the database is established again;
> - post-index query is executed to perform any necessary final cleanup;
> - connection to the database is closed again.


然后记录一下配置过程方便以后进行类似的配置：

- Coreseek 官网的[安装指南](http://www.coreseek.cn/products-install/install_on_bsd_linux/)，我安装的是4.1版本
- 测试跑好之后最重要的是修改 sphinx.conf （实际上是 csft.conf），其中需要注意[关于中文分词的核心设置](http://www.coreseek.cn/products-install/coreseek_mmseg/)来支持中文索引。而关于配置文件中的各种参数最好还是通过文档的 [Chapter 11 - sphinx.conf options reference](http://www.coreseek.cn/docs/sphinx_2.0.1-beta.html#conf-reference) 来做了解，值得注意的有如下几点
	- `sql_host`: 如果使用 MySQL 的话，'localhost' 是利用 UNIX socket 来连接而'127.0.0.1'则是利用 TCP/IP，推荐前者;
	- `sql_query_pre`: 基本上是调整输出字符集或者关闭 query cache 用;
	- `sql_attr_***`: attribute 是个很重要的概念。指定某个 column 是 attribute 后从数据库拿到该 column 时不参加全文索引，但是可以进行 filter 或者 groupby 操作。更重要的是，一般来说 api 调用 sphinx 引擎查找后并不返回实际的内容（比如 document title/content）而只是在表中的 id，如果嫌再去数据库中拿数据麻烦可以指定某想要的项为 attribute，这样直接调用 sphinx 后返回的结果里就有该 column 的内容了;
	- `sql_field_string`: 与 attribute 唯一的不同在于该项会参与全文索引。挺有用

老实说其他就没怎么设置了…有空看看文档发现有用的再来补充 ;-)

配置好后通过 `indexer` 来建立索引, `searchd` 来开启 daemon 供 api 使用。关于这几个命令行工具（还包括 `search`, 但一般用 api 就行了不常用它）的参数除了文档还可以看[这篇文章](http://www.cnblogs.com/gaoxu387/archive/2012/11/30/2794822.html)有比较详细的介绍。最常用的几个命令就是

- `/usr/local/coreseek/bin/indexer -c etc/csft.conf --all`: 重建全部索引
- `/usr/local/coreseek/bin/searchd -c etc/csft.conf`: 启动 daemon, 添加 `--stop` 来停止

### Step 3: API
之后就是调用 api 了。重要的东西都在文档里的 [Chapter 8 - API reference](http://www.coreseek.cn/docs/sphinx_2.0.1-beta.html#api-reference) 里，在我们的应用里是[这样调用的](https://github.com/EDFward/wechat-sjtu/blob/master/func_lib/get_zhihudaily.php#L66):

- `SetLimits(0, 5)`: 搜索最多显示5个结果。待议（另外 `$query_res['total']` 和 `$query_res['total_found']` 与这个 limit 没关系，他们俩是在服务器上处理的结果，而 limit 规定的是拿几个 item 出来）
- `SetMatchMode(SPH_MATCH_ALL)`: 所有关键词用 AND 连接。本来有个 EXTENDED2 模式可以支持更复杂的 query, 但试验了下似乎用中文始终有问题…?
- 关于 RankingMode、SortMode 就以后再详细了解吧

最后的事情当然就是设定一个凌晨的 crontab 把前一天的文章数据插入数据库然后重新索引一遍（现在重新索引大概只需要1秒左右所以增量索引应该还用不上）。

大致上这个功能的雏形就有了 ;-)

### 后记
其实这次捣鼓来捣鼓去还是个工程问题，能添加上这个功能固然是好，但是究其底细我对 information retrieval 这个领域基本上还是个小白，希望下次能写写这些开源引擎里的 ranking, sorting 用了什么算法，具体又是怎样实现的，我想帮助会更大。
