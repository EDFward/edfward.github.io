---
title: 啊，笨！趣题 Linked List Cycle
tags: c++, programming, algorithm, leetcode
---
谈谈刷题趣闻...最近做 LeetCode 上这两道看起来非常简单的题 [Linked List Cycle](http://oj.leetcode.com/problems/linked-list-cycle/) 和 [Linked List Cycle II](http://oj.leetcode.com/problems/linked-list-cycle-ii/) 让我大受打击，虽说本来对自己的智商就没什么信心，但这种脑袋怎么转也转不出答案的挫败感还是很影响心情的。看来只有大吃一顿以解心头之恨了。

第一个问题就是检查一个链表里有没有循环，第二个稍微变种了一下是找到在哪里循环的，要求不用额外的存储（就是说不要用 hash map）。我记得当时很晚了，看到这道题之后就上床开始和室友们侃大山，边扯边想边蹬脚，后来想不出实在憋得不行就用手机去论坛上看了讨论，发现了一个 fast/slow runner 的解法实在神妙莫测，顿时来劲儿就着手机写了代码然后提交。算法特简单：一个 slow runner 一次跑一步，另一个 fast runner 一次跑两步，如果相遇就说明有环。哇塞。还记得这个答案贴下面一堆 "awesome!" "genius!" "楼主我要娶你回家！" 的评论。

有了这次经验后我想第二题分分钟就该解决了。过几天找了家咖啡店，坐定之后斗志满满开始想办法。想了10分钟后，不甘心地拿出了纸和笔开始列方程；20分钟后开始冒冷汗；30分钟后有了掀桌的冲动；1个小时后颓然地放下笔，打算出家当和尚，龙泉寺是没指望了，去个山里的小寺庙还是会被收留的吧。

无奈又去论坛上看答案，发现跟上一题相比**居然只多了5行改了1行**。

<script src="https://gist.github.com/EDFward/8329765.js"></script>

难理解的部分在于，为什么 slow 和 fast 相遇后 slow 再回到开头两者以同样的速度跑就一定在成环的地方相遇，以及更重要的是，**如何想到这样的解法**。后一个问题我可能没有办法解决，试着理一下思路讲讲为什么吧。

两个 runner 从坐标0处开始跑，假设从坐标 `h` 处入环，`h+k` 处指向 `h`。有以下事实（s 代表 slow runner， f 代表 fast runner）：

1. s 刚入环时，f 坐标：`h+h%(k+1)`
2. 两者相遇要再经过 `k+1-h%(k+1)` 个回合
3. 此处距离到达 `h` 还有 `k+1-[k+1-h%(k+1)]=h%(k+1)` 个单位长度
4. 即若 f 降为一步一回合的速度则再经过 `h%(k+1)+N(k+1)` 回合 f 就会回到 `h` 处，此处 `N` 为自然数
5. `h = h%(k+1)+n(k+1)`，也就是说如果再过 `h` 回合 f 就会回到 `h` 处
6. s 从原点出发，与减速过的 f 相遇时一定在 `h` 处，在 `h` 处时一定相遇。`h` 处也就是我们想要的目标
7. 此处应有掌声

******

**UPDATE**

今天小伙伴跟我说了一个更简单的证明方式，记录如下：

假设入环前的长度为`h`，环的长度为`l`，相遇时在环内的 offset 为`o`。可以很方便的推出：`k+Nl+o = 2(k+o)` 其中`N`为正整数，化简得到`k+o = Nl`，意味着此处再经过`k`个单位必定回到环的起点。Q.E.D

####Reference

[Finding the Start of a Loop in a Circular Linked List](http://umairsaeed.com/2011/06/23/finding-the-start-of-a-loop-in-a-circular-linked-list/): 讲得很通俗易懂，推荐
