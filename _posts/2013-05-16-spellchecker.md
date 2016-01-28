---
title: Peter Norvig 的拼写检查器
tags: python, statistics, bayes, programming
---
今天看了 Peter Norvig 的一篇关于拼写检查器的文章（[翻译](http://blog.youxu.info/spell-correct.html)，[原文](http://norvig.com/spell-correct.html)），不仅写的好而且刚好跟不久前实现的一个 Naive-Bayes 名词短语分类器相关，感觉收益良多。简单总结一下文章提到的东西。

21行 python 代码实现，功能完备，1 秒处理 10 多个单词，准确率 80%~90%。

##### 语言层面上的 notes:

- `collections.defaultdict` 简洁优雅。构造的时候声明一个 `default_factory` 函数可以让其在找不到对应的 key 时调用该函数、加入 dict、返回该值。（需要注意的是这个过程只会在 `__getitem__()` 时被触发，`get()` 就仍然只会返回 `None`）
- python 的短路表达式可以非常自然的实现‘优先级’这个概念。（在热心人的 [Scheme 实现](http://practical-scheme.net/wiliki/wiliki.cgi?Gauche%3aSpellingCorrection&l=en)中需要额外的库或者 OR-like Macro）    
- 注意 `NWORDS[target] += bias` 的 bug，在 `defaultdict` 中会把 target 加入到词典去，不注意的话可能会造成意想不到的后果

##### 关于 spell corrector 的统计模型用的是很简单的 Bayes' Rule: `P(c|w) = P(c) * P(w|c) / P(w)`:

- P(c) 是正确拼写一个词的概率。由语言模型决定，该实现中用的是最基本的平滑方式即未出现的单词频数赋为 1
- P(w\|c) 为误差模型，决定怎样的错拼方式更容易出现。可以利用一些规则，例如元音之间更易打错等。在这个简化版本里是默认 edit distance 小的比大的优先级更高
- `NWORDS` 储存了语料里各个单词的出现频率，所以最终选择正确单词的方法就是在优先度高的候选词里选择对应频率最高的那一个
- 尽管有文献号称 edit distance 为 1 的词覆盖了大多数错拼，但是作者在实验中发现并非如此

##### 误差和可能的改进:

- 未知词汇。可以通过增大语料库、提高语言模型（即增加正确拼写的词语频数）来解决。作者这里用了一个很有趣的 bias 来模拟语言模型的提高，结果发现可以很显著的提高训练集和测试集的准确度。另外一个方法就是增加基于规则的前后缀判断
- 过于简陋的‘优先级’。最好的解决办法是找到一个关于拼写错误的语料，统计各种插入删除交换变换的错拼概率。作者说为了保证质量， 100 亿个字母的训练集可能差不多（所以 google 的强大就在于他们的数据啊，每天大家在搜索栏输错的东西都是他们的 training data…）
- 忽视了更大 edit distance 的词语。可以基于规则来限制候选词数量（比如只允许在元音旁边插入一个元音），这样能引入更多的可能答案
- 优化训练集和测试集——其实就是排除训练时候的错误
- 程序优化。比如用编译语言，用表而不是 dict，用缓存等等。**重要的是弄清楚程序的时间到底花在了什么地方。**
    
******

update @ 1/6/2014  
附上原文中的代码。

```python
import re, collections

  def words(text): return re.findall('[a-z]+', text.lower()) 

  def train(features):
      model = collections.defaultdict(lambda: 1)
      for f in features:
          model[f] += 1
      return model

  NWORDS = train(words(file('big.txt').read()))

  alphabet = 'abcdefghijklmnopqrstuvwxyz'

  def edits1(word):
     splits     = [(word[:i], word[i:]) for i in range(len(word) + 1)]
     deletes    = [a + b[1:] for a, b in splits if b]
     transposes = [a + b[1] + b[0] + b[2:] for a, b in splits if len(b)>1]
     replaces   = [a + c + b[1:] for a, b in splits for c in alphabet if b]
     inserts    = [a + c + b     for a, b in splits for c in alphabet]
     return set(deletes + transposes + replaces + inserts)

  def known_edits2(word):
      return set(e2 for e1 in edits1(word) for e2 in edits1(e1) if e2 in NWORDS)

  def known(words): return set(w for w in words if w in NWORDS)

  def correct(word):
      candidates = known([word]) or known(edits1(word)) or known_edits2(word) or [word]
      return max(candidates, key=NWORDS.get)
```

使用：

    >>> correct('speling')
    'spelling'
    >>> correct('korrecter')
    'corrector'
