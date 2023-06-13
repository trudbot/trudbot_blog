---
title: 第十四届蓝桥杯C/C++B组国赛
mathjax: true
tags:
  - 蓝桥杯
  - 算法
abbrlink: 25862
date: 2023-06-10 20:54:13
categories:
---

# 2023蓝桥C/C++B组国赛

## 试题A: 子2023

### 题目描述

小蓝在黑板上连续写下从1 到2023 之间所有的整数，得到了一个数字序列：
$S = 12345678910111213...20222023$。
小蓝想知道$S$ 中有多少种子序列恰好等于$2023$？
提示，以下是3 种满足条件的子序列（用中括号标识出的数字是子序列包含的数字）：
$1[2]34567891[0]111[2]1[3]14151617181920212223...$
$1[2]34567891[0]111[2]131415161718192021222[3]...$
$1[2]34567891[0]111213141516171819[2]021222[3]...$
注意以下是不满足条件的子序列，虽然包含了2、0、2、3 四个数字，但是顺序不对：
$1[2]345678910111[2]131415161718192[0]21222[3]...$

<!--more-->

### 预处理

定义$cnt_{23}[i]$为$S$从下标`i`开始的部分中子序列$23$的个数， 这可以由简单的后缀和递推得到。

枚举$2023$中的`2`和`0`的位置， 每次加入`0`后面的$cnt_{23}$即可。

时间复杂度:$O(n^2)$

### 参考代码

参考答案：5484660609

```c++
//
// Created by trudbot on 2023/6/10.
//
#include <bits/stdc++.h>
using namespace std;

int main () {
    string s;
    for (int i = 1; i <= 2023; i ++) {
        s += to_string(i);
    }
    int cnt_3 = 0;
    vector<int> cnt_23(s.size() + 1, 0);
    for (int i = s.size() - 1; i >= 0; i --) {
        cnt_23[i] += cnt_23[i + 1];
        if (s[i] == '2') cnt_23[i] += cnt_3;
        else if (s[i] == '3') cnt_3 ++;
    }
    long long res = 0;
    for (int i = 0; i < s.size(); i ++) {
        if (s[i] != '2') continue;
        for (int j = i + 1; j < s.size(); j ++) {
            if (s[j] != '0') continue;
            res += cnt_23[j + 1];
        }
    }
    cout << res << endl;
    return 0;
}
```

## 试题B: 双子数

### 题目描述

若一个正整数x 可以被表示为$p^2q^2$，其中p、q 为质数且$p \neq q$，则x 是一个“双子数”。请计算区间$[2333,23333333333333]$ 内有多少个“双子数”？

### 线性筛

$2333 \leq (pq)^2 \leq 23333333333333$即$\sqrt{2333} < pq \leq \sqrt{23333333333333}$(开根向下取整)

因此可以考虑枚举在$[1, \sqrt{23333333333333}]$范围中有多少对质数满足上述条件。

### 参考代码

参考答案：947293

```c++
//
// Created by trudbot on 2023/6/10.
//
#include <bits/stdc++.h>
using namespace std;
using ll = long long;
const ll MN = sqrt(2333),
MX = sqrt(23333333333333), N = 1e7;
ll p[N], idx;
bool st[N];

void init() {
    for (int i = 2; i < N; i ++) {
        if (!st[i]) p[idx ++] = i;
        for (int j = 0; p[j] * i < N; j ++) {
            st[p[j] * i] = true;
            if (i % p[j] == 0) break;
        }
    }
}

int main () {
    init();
    int res = 0;
    for (int i = 0; i < idx; i ++) {
        for (int j = i + 1; j < idx && p[i] * p[j] <= MX;  j++) {
            if (p[j] * p[i] > MN) res ++;
        }
    }
    cout << res << endl;
    return 0;
}
```

## 试题C: 班级活动

### 题意描述

小明的老师准备组织一次班级活动。班上一共有n 名（n 为偶数）同学，老师想把所有的同学进行分组，每两名同学一组。为了公平，老师给每名同学随机分配了一个n 以内的正整数作为$id$，第i 名同学的id 为$a_i$。
老师希望通过更改若干名同学的id 使得对于任意一名同学`i`，有且仅有另一名同学`j` 的id 与其相同（$a_i = a_j$）。请问老师最少需要更改多少名同学的id？

### 分类讨论

更改id使其满足题意后， 可知id的种类一定为$\frac n2$, 因此可以将问题分为三种情况。

1. 原数组中id种类恰好为$\frac n2$

比如`[1, 2, 2, 2, 2, 3]`， 已经存在了$\frac n2$种id, 因此只需要把数量多于2的id分配到数量为1的id上即可。

答案即为数量为1的id的个数。

2. 原数组中id种类大于$\frac n2$

比如`[1, 2, 2, 2, 3, 4]`。

定义$cnt$为id种类数， $cnt_1$为数量为1的id种类数。

首先， 我们把一部分数量为1的id变成其它的数量为1的id， 使id种类减少至$\frac n2$， 这个过程需要$cnt - \frac n2$次变换。

然后这个问题就等同于(1)情况了， 变换后数量为1的id种类数减少了$2 * (cnt - \frac n2)$个， 因此还需要$cnt_1 - 2 *(cnt - \frac n2)$次变换。

所以总的变换次数为$cnt_1 + \frac n2 - cnt$次。

3. 原数组中id种类数小于$\frac n2$

比如`[1, 2, 2, 2, 2, 2]`。

类似的， 我们可以先拿数量大于2的id变成一个新的id， 使id种类数量增加到$\frac n2$， 需要$\frac n2 - cnt$次, $cnt_1$增加了$\frac n2 - cnt$。

所以总的次数为$cnt + n - 2 * cnt$

### 参考代码

```c++
//
// Created by trudbot on 2023/6/10.
//
#include "bits/stdc++.h"
using namespace std;

int main () {
    int n; cin >> n;
    map<int, int> cnt;
    for (int i = 0; i < n; i ++) {
        int x; cin >> x;
        cnt[x] ++;
    }
    int cnt_1 = 0, m = n / 2;
    for (auto &p : cnt) if (p.second == 1) cnt_1 ++;

    if (cnt.size() == m) cout << cnt_1;
    else if (cnt.size() > m) cout << cnt_1 + m - cnt.size();
    else cout << cnt_1 + 2 * (m - cnt.size());

    return 0;
}

```

## 试题D: 合并数列

### 题意描述

小明发现有很多方案可以把一个很大的正整数拆成若干正整数的和。他采取了其中两种方案，分别将他们列为两个数组$\{a_1, a_2...a_n\}$ 和$\{b_1, b_2...b_m\}$。两个数组的和相同。
定义一次合并操作可以将某数组内相邻的两个数合并为一个新数，新数的值是原来两个数的和。小明想通过若干次合并操作将两个数组变成一模一样，即n = m 且对于任意下标i 满足$a_i = b_i$。请计算至少需要多少次合并操作可以完成小明的目标。

### 双指针

比较a[i]与b[j]， 若相同不需要合并；若不相同则较小的一个往后加， 重复直至相同为止。

### 参考代码

```c++
//
// Created by trudbot on 2023/6/10.
//
#include "bits/stdc++.h"
using namespace std;
using ll = long long;
const int N = 1e5 + 10;
ll a[N], b[N];

int main () {
    int n, m; cin >> n >> m;
    for (int i = 0; i < n; i ++) cin >> a[i];
    for (int i = 0; i < m; i ++) cin >> b[i];
    int res = 0;
    for (int i = 0, j = 0; i < n; i ++, j ++) {
        ll x = a[i], y = b[j];
        while (x != y) {
            if (x < y) x += a[++ i];
            else y += b[++ j];
            res ++;
        }
    }
    cout << res << endl;
    return 0;
}

```

## 试题E: 数三角

### 题目描述

小明在二维坐标系中放置了n 个点，他想在其中选出一个包含三个点的子集，这三个点能组成三角形。然而这样的方案太多了，他决定只选择那些可以组成等腰三角形的方案。请帮他计算出一共有多少种选法可以组成等腰三角形？

### 哈希表、斜率

首先需要知道的是， 三个点都是整点的三角形不可能是等边三角形， 一些证明参见[[日常摸鱼\]整点正多边形，HDU6055，Pick公式，证明 - yoshinow2001 - 博客园 (cnblogs.com)](https://www.cnblogs.com/yoshinow2001/p/14599700.html)。

我们考虑每一个点作为顶点u(两腰相交之点)的情况，此时我们可以进行一次遍历算出其它的每个点到u的距离。

两个点a, b需要满足到u的距离相等， 且三点不共线， 这样才能构成等腰三角形。而共线可以抽象为a与u和b与u连线的斜率相等。

假设有n个点到u的距离都为d， 且与u的斜率互不相等， 那么这n个点和u可以构成$C_n^2$个以u为顶点的等于三角形。

可以用哈希表`map<int, set<slope>>`记录， 对于u， 每种距离有多少个斜率不相同的点。

### 参考代码

```cpp
//
// Created by trudbot on 2023/6/11.
//
#include "bits/stdc++.h"
#define x first
#define y second
using namespace std;
using ll = long long;

pair<ll, ll> getSlope(ll dx, ll dy) {
    if (dx == 0) return {1, 0};
    if (dy == 0) return {0, 1};
    ll gcd = __gcd(dx, dy);
    return {dy / gcd, dx /gcd};
}

int main () {
    int n; cin >> n;
    vector<pair<ll, ll>> ps(n);
    for (auto &p : ps) cin >> p.x >> p.y;
    ll res = 0;
    for (auto &a : ps) {
        unordered_map<ll, map<pair<ll, ll>, ll>> h;
        for (auto &b : ps) {
            ll dx = a.x  - b.x, dy = a.y - b.y;
            if (dx == 0 && dy == 0) continue;
            h[dx * dx + dy * dy][getSlope(dx, dy)] ++;
        }
        for (auto &p : h) {
            ll cnt = 0;
            for (auto &pp : p.y) {
                cnt += pp.y;
                res -= (pp.y - 1) * pp.y / 2;
            }
            res += (cnt - 1) * cnt / 2;
        }
    }
    cout << res << endl;
    return 0;
}
/*
5
1 4
1 0
2 1
1 2
0 1
 */
```

