---
title: （再次）手动安装 numpy/scipy 
tags: ubuntu, python, numpy, scipy
---
由于在实验室的 Ubuntu 服务器上没有 sudo 权限，不得不陷入手动 build numpy/scipy 的窘境。这篇还是用来备忘吧。

当然前提还是要有 fortran 的 compiler 比如 gfortran。
 
下载最新的 setuptools-xxx.tar.gz 和 pip-xxx.tar.gz，解压，然后分别安装在用户目录下

{% highlight bash %}
python setup install --prefix=$HOME/.local
{% endhighlight %}
	 
以后用 pip/easy_install 安装时用

{% highlight bash %}
pip install --user virtualenv
# or
easy_install --prefix=$HOME/.local ipython
{% endhighlight %}
	
但是安装 numpy 会提示 `Fatal error: Python.h: No such file or Directory`，检查一下系统安装的跟 python 有关的 package 里有没有 python-dev:

{% highlight bash %}
dpkg -l | grep python-dev
{% endhighlight %}
	
没有就对了...接下来要么跟管理员说帮我安一下，要么自己动手 build。我们选 hard 难度。下载和系统 python 版本一致的 python source，解压配置安装：

{% highlight bash %}
./configure  --enable-unicode=ucs4 --prefix=$HOME/.local
make
make install
{% endhighlight %}
	
编辑 `.bashrc` 或者 `.zshrc`

{% highlight bash %}
export C_INCLUDE_PATH=$HOME/.local/include/python2.7
export CPLUS_INCLUDE_PATH=$HOME/.local/include/python2.7
{% endhighlight %}

这样就能用 pip/easy_install 安装了，不过由于我担心性能所以还是下载 numpy 的 source 自己 build。解压后

{% highlight bash %}
python setup.py install --prefix=$HOME/.local
{% endhighlight %}
	
直接安装就行，但是这样依然没有用优化的 BLAS(Basic Linear Algebra Subprograms) 和 LAPACK (Linear Algebra PACKage)，性能很差。继续 DIY。

首先尝试了 [ATLAS](http://math-atlas.sourceforge.net/) (之前提到那两个东西的开源实现)，结果发现安装过程需要关掉 CPU throttling，得 sudo，放弃。换 [OpenBLAS](https://github.com/xianyi/OpenBLAS)，安装

{% highlight bash %}
git clone git://github.com/xianyi/OpenBLAS
cd OpenBLAS && make FC=gfortran
make PREFIX=$HOME/.local install
{% endhighlight %}

然后在 numpy 解压目录下

{% highlight bash %}
mv site.cfg.example site.cfg
{% endhighlight %}
	
这是为了在 setup.py 的时候能够从这个 cfg 文件里读到相关的配置地址。打开它然后编辑（友情提示：安装的地址请按自己需要更改）：

	[openblas]
	libraries = openblas
	library_dirs = /home/yourname/.local/lib
	include_dirs = /home/yourname/.local/include
	
之后检查一下

{% highlight bash %}
python setup.py config
{% endhighlight %}
	
应该会出现 Found openblas 之类的提示。接下来安装

{% highlight bash %}
python setup.py install prefix=$HOME/.local
{% endhighlight %}

这样安装就算成功了。但如果之后 import 时出现错误说 libopenblas.so.0 cannot be found 的话还要再去改一下 `.bashrc` 或者 `.zshrc`

{% highlight bash %}
export LD_LIBRARY_PATH=$HOME/.local/lib
{% endhighlight %}

接下去用[这里的 script](https://gist.github.com/osdf/3842524#file_test_numpy.py) 去测一下速度

{% highlight bash %}
# if successfully installed
$ python test_numpy.py
FAST BLAS
version: 1.8.0
maxint: 9223372036854775807

dot: 0.0733390331268 sec

# otherwise poor performance
slow blas 
version: 1.8.0
maxint: 9223372036854775807

dot: 1.81880660057 sec
{% endhighlight %}

当然最后再用 pip 安装 scipy 和 scikit-learn 就好。
	
###Reference

- [Numpy/Scipy with OpenBLAS for Ubuntu 12.04](http://osdf.github.io/blog/numpyscipy-with-openblas-for-ubuntu-1204.html)
- [Compiling numpy with OpenBLAS integration - StackOverflow](http://stackoverflow.com/questions/11443302/compiling-numpy-with-openblas-integration)
- [scipy.linalg cannot find OpenBLAS](http://scipy-user.10969.n7.nabble.com/scipy-linalg-cannot-find-OpenBLAS-td87.html)
