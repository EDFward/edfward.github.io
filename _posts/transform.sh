#!/bin/bash

for post in $(find . -name '*.md'); do 
    sed -i .bak -e 's/^{% highlight \([^ ]*\) %}$/```\1/' -e 's/^{% endhighlight %}.*$/```/' $post
done
