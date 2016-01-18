---
title: Mailman 部署记
tags: linux, server
---
最近为自己的服务器买了域名顺便续了下费。恰逢某任选课需要一个类似于 google group 的东西方便交流，自然就想到部署一个 mailing list 来试手。

所以就列下一些值得注意的教训和经验 ;-)

- 防火墙！折腾了几个小时才反应过来SMTP的25端口没有打开！血一般的教训！
    - 在 server 和 client 上都能用 `nmap` 来扫端口。发现问题出自于防火墙是因为 server 上的25端口是开启的但是 client 上看不到（直接用 telnet 连25端口当然也失败了）
    - server 端 `nc -l 25` 和 client 端 `echo hello | nc IP 25`也能检测这个端口是不是有问题
    - 之后修改防火墙规则再 `iptables-restore` 就行了
- postfix 和 mailman 安装后最好都 `sudo dpkg-reconfigure xxx` 一下，之后按着[教程](http://free-electrons.com/blog/mailman-howto-ubuntu-10-04/)来问题都不大
- 关于 [How to host multiple subdomains](http://library.linode.com/hosting-website#sph_configuring-name-based-virtual-hosts)）
- mailman 最开始新建的 mailman 邮件列表千万不要删掉，否则据说会出现灵异现象。（可以通过调节 Privacy 来隐藏它）
- 调试好 postfix 后可以通过下载 bsd-mailx 发邮件来测试成功与否
- `tail -f /var/log/mail.log` 紧跟日志
- 耐心，细心和 Google 永远是最值得信赖的帮手
