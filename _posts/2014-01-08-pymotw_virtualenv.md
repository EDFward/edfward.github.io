---
title: Python Module of the Week - virtualenv
tags: python, development, pymotw
---
继之前部署 python 环境后发现自己误入了传说中的 *dependency hell*，总是会遇到些奇怪的问题，要纠结用哪个 python 啊，`PYTHONPATH` 和 `PYTHONHOME` 的设置啊等等问题。这个时候就要果断用上神器 **virtualenv** （包括一个易用的扩展 **virtualenvwrapper**）啦。先看一下为什么它要解决的问题（来自[官方的 documentation](http://www.virtualenv.org/en/latest/virtualenv.html)）：

> The basic problem being addressed is one of dependencies and versions, and indirectly permissions. Imagine you have an application that needs version 1 of LibFoo, but another application requires version 2. How can you use both these applications? If you install everything into /usr/lib/python2.7/site-packages (or whatever your platform’s standard location is), it’s easy to end up in a situation where you **unintentionally upgrade an application that shouldn’t be upgraded**.

> Or more generally, what if you want to install an application and leave it be? If an application works, **any change in its libraries or the versions of those libraries can break the application**.

> Also, **what if you can’t install packages into the global site-packages directory**? For instance, on a shared host.

virtualenv 提供的解决办法就是建立虚拟的环境，有自己独立的 dependency，这样不同的应用可以跑在不同的环境中互不干扰。这篇文就记录一下基于它们的常用 work flow。

******

### virtualenv

```bash
# create the virtual environment in current directory
$ virtualenv MYENV
# or inherit system packages
$ virtualenv --system-site-packages MYENV

# get into that environment: basically it only changes your PATH
$ source MYENV/bin/activate
# get out
$ deactivate 

# specify which python to use
$ export VIRTUALENV_PYTHON=$HOME/.local/bin/python
$ virtualenv MYENV
# or
$ virtualenv --python=/opt/python-3.3/bin/python MYENV
```

******

### virtualenvwrapper

virtualenvwrapper 只是将 virtualenv 包装了一下，使得整个过程更加简单。

```bash
# add those to .bashrc or .zshrc, 
# path of `virtualenvwrapper.sh` may vary
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
# then it's good to go!

# basic work flow
$ mkvirtualenv MYENV
$ workon MYENV
$ deactivate

# if need customization, add those in .*shrc before sourcing the
# virtualenvwrapper.sh file
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv # unnecessary
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'

$ mktmpenv  # temp env, deleted after deactivating
$ rmvirtualenv MYENV # remove
$ lsvirtualenv  # list, `workon` alone is similar
$ allvirtualenv pip install -U pip # universal action
$ lssitepackages # packages in current env
$ mkproject MYPROJ # an application dir along with virtual env
```
    
除此之外，还可以在 `$WORKON_HOME` 中对应的 env 里编辑一些 hooks 做自己的事情。比如在 `postactivate` 里添加 `cd /path/to/proj`， 这样启动一个环境后会直接进入工作目录（其实和 `mkproject` 类似了）。各种 hooks 可以戳[这里看官网说明](http://virtualenvwrapper.readthedocs.org/en/latest/scripts.html)。

另外还有些高端的玩法比如改变 cd 的语义这样进入某些目录会自动激活对应的 virtual env，有兴趣的话去官网看看 Tips and Tricks 吧。
