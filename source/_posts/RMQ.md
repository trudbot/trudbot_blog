---
title: RMQ
mathjax: true
tags:
  - 单调栈
  - 线段树
  - st表
  - 倍增
categories: 算法
abbrlink: 32085
date: 2023-08-14 14:15:44
---

$RMQ$全称是`Range Minimum/Maximum Query`, 即"区间最大最小值问题"， 一般来说需要处理多组查询， 查询的区间长度不一、可能重复。

<!--more-->

这里我们以$RMQ$模板举例:

[原题link]()

> **题目描述**
>
> 给定一个长度为$N$的数列，和 $M$次询问，求出每一次询问的区间内数字的最大值。
>
> **输入格式**
>
> 第一行包含两个整数 $N, M$，分别表示数列的长度和询问的个数。
>
> 第二行包含 $N$ 个整数（记为$a_i$），依次表示数列的第$i$ 项。
>
> 接下来 $M$ 行，每行包含两个整数 $l_i$,$r_i$，表示查询的区间为$[l_i, r_i]$。

## 线段树

线段树基于分治的思想， 是解决$RMQ$的经典数据结构。

此前已有总结, 具体见[线段树]([线段树 | trudbot](https://trudbot.cn/posts/48555/)).

## 单调栈

单调栈可以以离线的方式解决$RMQ$问题。

根据单调栈的原理我们知道， 当我们把$a_1$~$a_n$插入到单调栈后， 会得到一个索引递增的， 且值递增/递减的序列。

我们可以将所有查询读入, 并按照右端点排序。

将$a_1$到$a_n$依次插入到单调栈中， 在这个过程中， 如果插入的下标来到了某个查询的右端点， 此时我们在单调栈中二分到第一个下标$\geq l$的元素， 这就是$query(l, r)$的答案。

对于区间最大值问题， 我们需要维护一个递减的单调栈， 然后二分找到在[l, r]区间的第一个元素。

**时间复杂度：**$O(q\log q + q\log n + n)$

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 1e5 + 10;
int a[N], stk[N], top = -1, t = 0;
struct Q{int id, l, r;};

inline int read() {
	int x=0,f=1;char ch=getchar();
	while (ch<'0'||ch>'9'){if (ch=='-') f=-1;ch=getchar();}
	while (ch>='0'&&ch<='9'){x=x*10+ch-48;ch=getchar();}
	return x*f;
}

void push(int i) {
    while (top != -1 && a[stk[top]] <= a[i]) top --;
    stk[++ top] = i;
}

int query(int b, int e) {
    while (t < e) push(++ t);
    int l = 0, r = top;
    while (l < r) {
        int mid = (l + r) >> 1;
        if (stk[mid] >= b) r = mid;
        else l = mid + 1;
    }
    return a[stk[l]];
}

int main () {
    int n = read(), m = read();
    for (int i = 1; i <= n; i ++) a[i] = read();
    vector<Q> q;
    for (int i = 0; i < m; i ++) {
        q.push_back({i, read(), read()});
    }
    sort(q.begin(), q.end(), [](auto &a, auto &b) {
        return a.r < b.r;
    });
    vector<int> res(m);
    for (auto &x : q) {
        res[x.id] = query(x.l, x.r);
    }
    for (int &x : res) printf("%d\n", x);
    return 0;
}
```

## ST表

ST表(Sparse Table，**稀疏表**)， 是一种基于倍增思想， 用于解决可重复贡献问题的数据结构。

ST表一般用来解决区间性质查询问题， 并且要求这个区间性质是可重复贡献的、可结合(拆分)的。

* 可结合(拆分): 区间的性质能由子区间的性质组合而成。
* 可重复贡献: 某个子区间贡献多次， 并不会影响结果。

例如经典的区间最大值问题: 

1. 区间的最大值能由若干个能覆盖区间的子区间取最大值得到
2. 取的子区间有重合部分时， 并不会影响结果

接下来， 我们讲ST表的思路:

设$opt(a, b, c, d)$为具体的数据的性质， $opt[l, r]$为区间`[l, r]`的性质。

而$f(i, j)$表示$opt[i, i + 2^j - 1$]， 由倍增思想我们知道$f(i, j) = opt(f(i, j - 1), f(i + 2^{j - 1}, j-1))$

我们可以用$O(n\log n)$的时间复杂度预处理得到倍增数组。

在查询区间$[l, r]$的性质时， 我们知道只需要将其拆分为若干个区间， 分别求出性质， 再进行组合就可以了。

那么如何利用已经求出的倍增数组呢？

在普通的倍增中， 一般会选择将区间拆分为若干个2的幂次的长度的区间， 这些区间在倍增数组中都已记录， 但这样每次查询的时间复杂度为$O(\log n)$。

这时候可重复贡献的性质就很重要了， 为了降低时间复杂度 ，我们可以只将区间拆分为两个区间: $[l, l + t -1], [r - t + 1, r]$， 其中$t = 2^{\lfloor \log_2(r - l + 1)\rfloor}$。

长度为2的幂次， 所以倍增数组中已经求出对应区间的性质; 而$2*t$一定是大于等于$r - l + 1$的， 所以两个区间一定能覆盖`[l, r]`

**时间复杂度**

预处理为$O(n\log n)$， 每次查询为$O(1)$， 所以时间复杂度为$O(n\log n + m)$

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 1e5 + 10;
int f[N][21];

inline int read() {
	int x=0,f=1;char ch=getchar();
	while (ch<'0'||ch>'9'){if (ch=='-') f=-1;ch=getchar();}
	while (ch>='0'&&ch<='9'){x=x*10+ch-48;ch=getchar();}
	return x*f;
}

int main () {
    int n = read(), m = read();
    for (int i = 1; i <= n; i ++) f[i][0] = read();
    for (int j = 1; j < 21; j ++)
        for (int i = 1; i + (1 << j) - 1 <= n; i ++) 
            f[i][j] = max(f[i][j - 1], f[i + (1 << (j - 1))][j - 1]);
    while (m --) {
        int l = read(), r = read();
        int len = log2(r - l + 1);
        printf("%d\n", max(f[l][len], f[r - (1 << len) + 1][len]));
    }
    return 0;
}
```

## 参考

[ST 表 - OI Wiki (oi-wiki.org)](https://oi-wiki.org/ds/sparse-table/)

[浅谈ST表 - 自为风月马前卒 - 博客园 (cnblogs.com)](https://www.cnblogs.com/zwfymqz/p/8581995.html)

[算法学习笔记(12): ST表 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/105439034)