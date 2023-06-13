---
title: 第十四届蓝桥杯C/C++B组省赛
mathjax: true
tags:
  - 蓝桥杯
categories: 题解
abbrlink: 6078
date: 2023-04-12 14:02:05
---

# 2023蓝桥C/C++B组省赛

## 试题A: 日期统计

### 题目描述

【问题描述】
小蓝现在有一个长度为100 的数组，数组中的每个元素的值都在0 到9 的范围之内。数组中的元素从左至右如下所示：


```
5 6 8 6 9 1 6 1 2 4 9 1 9 8 2 3 6 4 7 7 5 9 5 0 3 8 7 5 8 1 5 8 6 1 8 3 0 3 7 9 2 7 0 5 8 8 5 7 0 9 9 1 9 4 4 6 8 6 3 3 8 5 1 6 3 4 6 7 0 7 8 2 7 6 8 9 5 6 5 6 1 4 0 1 0 0 9 4 8 0 9 1 2 8 5 0 2 5 3 3
```

现在他想要从这个数组中寻找一些满足以下条件的子序列：

<!--more-->

1. 子序列的长度为8；

2. 这个子序列可以按照下标顺序组成一个yyyymmdd 格式的日期，并且
   要求这个日期是2023 年中的某一天的日期，例如20230902，20231223。yyyy 表示年份，mm 表示月份，dd 表示天数，当月份或者天数的长度只有一位时需要一个前导零补充。

请你帮小蓝计算下按上述条件一共能找到多少个不同的2023 年的日期。
对于相同的日期你只需要统计一次即可。

### 枚举

用八重循环直接枚举每一位数字， 题目中的日期序列有很多限制， 如前四位必须是2023， 又比如月份只能以0或1开头等等。利用这些限制能大大降低运行时间， 实测只要限制了前四位， 基本是瞬间跑出结果。

注意需要用哈希表去重。

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
int days[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
set<int> res;

void check(int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > days[m]) return;
    res.insert(m * 100 + d);
}

int main () {
    int ns[100];
    for (int & n : ns) cin >> n;
    for (int a = 0; a < 100; a ++) {
        if (ns[a] != 2) continue;
        for (int b = a + 1; b < 100; b ++) {
            if (ns[b] != 0) continue;
            for (int c = b + 1; c < 100; c ++) {
                if (ns[c] != 2) continue;
                for (int d = c + 1; d < 100; d ++) {
                    if (ns[d] != 3) continue;

                    for (int i = d + 1; i < 100; i ++)
                        for (int j = i + 1; j < 100; j ++)
                            for (int k = j + 1; k < 100; k ++)
                                for (int l = k + 1; l < 100; l ++)
                                    check(ns[i] * 10 + ns[j], ns[k] * 10 + ns[l]);
                }
            }
        }
    }
    cout << res.size() << endl;
    return 0;
}
//in: 5 6 8 6 9 1 6 1 2 4 9 1 9 8 2 3 6 4 7 7 5 9 5 0 3 8 7 5 8 1 5 8 6 1 8 3 0 3 7 9 2
//7 0 5 8 8 5 7 0 9 9 1 9 4 4 6 8 6 3 3 8 5 1 6 3 4 6 7 0 7 8 2 7 6 8 9 5 6 5 6 1 4 0 1
//0 0 9 4 8 0 9 1 2 8 5 0 2 5 3 3
//out: 235
```

## 试题B: 01 串的熵

### 题目描述

对于一个长度为n 的01 串$S = x_1x_2x_3...x_n$，香农信息熵的定义为$H(S ) =
−\sum^n_1p(x_i) \log_2(p(x_i))$，其中$p(0),p(1)$ 表示在这个01 串中0 和1 出现的占比。

比如，对于S = `100` 来说，信息熵$H(S ) = −\frac13 \log_2( \frac13 ) − \frac23 \log_2( \frac23 ) − \frac23 \log_2( \frac23 )=1.3083$。对于一个长度为`23333333` 的01 串，如果其信息熵为`11625907.5798`，且0 出现次数比1 少，那么这个01 串中0 出现了多少次？

### 枚举|模拟

设01字符串`S`长度为`n`,  0的个数为`x`。

则$p(0) = \frac xn, p(1) = \frac{n-x}{n}$.

$H(S ) =−\sum^n_1p(x_i) \log_2(p(x_i)) = -(xp(0)\log_2(p(0)) + (n-x)p(1)\log_2(p(1)))$

在已知n, x时， 计算H是$O(1)$的， 所以只需要枚举x即可。

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
using ll = long long;
const ll H = 116259075798;
const ll N = 23333333;

bool check(ll x) {
    double p0 = x * 1.0 / N, p1 = 1 - p0;
    ll h = 10000ll * (x * p0 * log2(p0) + (N - x) * p1 * log2(p1));
    return h + H == 0;
}

int main () {
    for (int x = 1; x <= N / 2; x ++) {
        if (check(x)) cout << x << endl;
    }
    return 0;
}
//out: 11027421
```

## 试题C: 冶炼金属

### 题意描述

小蓝有一个神奇的炉子用于将普通金属O 冶炼成为一种特殊金属X。这个炉子有一个称作转换率的属性V，V 是一个正整数，这意味着消耗V 个普通金属O 恰好可以冶炼出一个特殊金属X，当普通金属O 的数目不足V 时，无法继续冶炼。

现在给出了N 条冶炼记录，每条记录中包含两个整数A 和B，这表示本次投入了A 个普通金属O，最终冶炼出了B 个特殊金属X。每条记录都是独立的，这意味着上一次没消耗完的普通金属O 不会累加到下一次的冶炼当中。
根据这N 条冶炼记录，请你推测出转换率V 的最小值和最大值分别可能是多少，题目保证评测数据不存在无解的情况。

### 取交集

对于每一条记录， 都可以求出转换率V的一个取值范围。 V必须满足所有记录求出的取值范围， 所以只需要对N个区间求交集即可, 也就是右边界取所有右边界的最小值， 左边界取所有左边界的最大值。。

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;

int main () {
    int n; cin >> n;
    int mn = -1, mx = 1e9;
    while (n --) {
        int a, b; cin >> a >> b;
        int l = a / (b + 1) + 1, r = a / b;
        mn = max(mn, l), mx = min(mx, r);
    }
    cout << mn << " " << mx << endl;
    return 0;
}
```

## 试题D: 飞机降落

### 题意描述

N 架飞机准备降落到某个只有一条跑道的机场。其中第`i` 架飞机在$T_i$ 时刻到达机场上空，到达时它的剩余油料还可以继续盘旋$D_i$ 个单位时间，即它最早可以于$T_i$ 时刻开始降落，最晚可以于$T_i + D_i$ 时刻开始降落。降落过程需要$L_i$
个单位时间。

一架飞机降落完毕时，另一架飞机可以立即在同一时刻开始降落，但是不能在前一架飞机完成降落前开始降落。

请你判断N 架飞机是否可以全部安全降落。

### DFS+剪枝， 懒得写

## 试题E: 接龙数列

### 题意描述

对于一个长度为K 的整数数列：$A_1,A_2..A_K$，我们称之为接龙数列当且仅当$A_i$ 的首位数字恰好等于$A_{i−1}$ 的末位数字(2 ≤ i ≤ K)。

例如$12,23,35,56,61,11$ 是接龙数列；$12,23,34,56$ 不是接龙数列，因为56的首位数字不等于34 的末位数字。所有长度为1 的整数数列都是接龙数列。

现在给定一个长度为N 的数列$A_1,A_2... A_N$，请你计算最少从中删除多少个数，可以使剩下的序列是接龙序列？

### DP

要求使得数列变成接龙数列的最少删除个数， 相当于求该数列的最长接龙子数列的长度， 用总长度减去最长接龙长度即为最少删除个数。

定义$dp[i][j]$为前`i`个数中， 以数字`j`结尾的最长接龙数列的长度。

设第`i`个数的首位数字是a， 末位数字是b。 则$dp[i]$中相对于$dp[i-1]$可能发生变化的只有$dp[i][b]$, 因为第i个数可能加到一个以a结尾的接龙数列中， 使得这个接龙数列长度加1并且结尾数字变成`b`.

所以状态转移方程为`dp[i][b] = max(dp[i - 1][b], dp[i - 1][a] + 1)`

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
int dp[10];

int main () {
    int n, mx = 0; cin >> n;
    for (int i = 0; i < n; i ++) {
        string s; cin >> s;
        int a = s[0] - '0', b = s.back() - '0';
        dp[b] = max(dp[b], dp[a] + 1), mx = max(mx, dp[b]);
    }
    cout << n - mx << endl;
    return 0;
}
```

## 试题F: 岛屿个数

### 题意描述

小蓝得到了一副大小为M × N 的格子地图，可以将其视作一个只包含字符‘0’（代表海水）和‘1’（代表陆地）的二维数组，地图之外可以视作全部是海水，每个岛屿由在上/下/左/右四个方向上相邻的‘1’ 相连接而形成。

在岛屿A 所占据的格子中，如果可以从中选出k 个不同的格子，使得他们的坐标能够组成一个这样的排列：($x_0, y_0$),($x_1,y_1$)... ($x_{k−1}, y_{k−1}$)，其中($x_{(i+1)}\%k,y_{(i+1)}\%k$) 是由($x_i, y_i$) 通过上/下/左/右移动一次得来的(0 ≤ i ≤ k − 1)，此时这k 个格子就构成了一个“环”。如果另一个岛屿B 所占据的格子全部位于这个“环” 内部，此时我们将岛屿B 视作是岛屿A 的子岛屿。若B 是A 的子岛屿，C 又是B 的子岛屿，那C 也是A 的子岛屿。

请问这个地图上共有多少个岛屿？在进行统计时不需要统计子岛屿的数目。

### dfs | 连通块

本题有两种类型的顶点, 一种是'海水', 如果A海顶点在B海顶点的周围8个格子内, 那两个海顶点就算连通的.

另一个是'陆地', 只有A在B的上下左右四个方格内, 两个陆地才是连通的.

地图外的方格我们全部视为海， 与地图外的海连通的海都视为外海， 可以发现， 接触到了外海的岛屿， 就一定不是其它岛屿的子岛。

所以在地图周围一圈， 我们增加一圈0作为外海， dfs遍历外海每一个方格， 若与外海方格相邻的岛屿未被遍历过，那么这就是一个新的岛屿， 再用一个dfs去遍历这个岛。

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
const int N = 60;
int g[N][N], n, m, res = 0;
bool st[N][N];
int dx[] = {0, 0, 1, -1},
    dy[] = {1, -1, 0, 0};

void dfs_1(int r, int c) {
    st[r][c] = true;
  	//四向连通
    for (int i = 0; i < 4; i ++) {
        int x = dx[i] + r, y = dy[i] + c;
        if (st[x][y] || g[x][y] == 0) continue;
        dfs_1(x, y);
    }
}

void dfs_0(int r, int c) {
    st[r][c] = true;
    //八向连通
    for (int i = -1; i <= 1; i ++)
        for (int j = -1; j <= 1; j ++) {
            int x = r + i, y = c + j;
            if (x < 0 || x > n + 1 || y < 0 || y > m + 1 || st[x][y]) continue;
            if (g[x][y] == 0) dfs_0(x, y);
            else dfs_1(x, y), res ++;
        }
}

int main () {
    int T; cin >> T;
    while (T --) {
        memset(g, 0, sizeof g);
        memset(st, false, sizeof st);
        cin >> n >> m; res = 0;
        for (int i = 1; i <= n; i ++)
            for (int j = 1; j <= m; j ++) {
                char c; cin >> c;
                g[i][j] = c - '0';
            }
        dfs_0(0, 0);//从一个外海方格开始dfs
        cout << res << endl;
    }
    return 0;
}
```



## 试题G: 子串简写

### 题意描述

程序猿圈子里正在流行一种很新的简写方法：对于一个字符串，只保留首尾字符，将首尾字符之间的所有字符用这部分的长度代替。例如**internationalization**简写成**i18n**，**Kubernetes** （注意连字符不是字符串的一部分）简
写成**K8s**, **Lanqiao** 简写成**L5o** 等。在本题中，我们规定长度大于等于K 的字符串都可以采用这种简写方法（长度小于K 的字符串不配使用这种简写）。

给定一个字符串`S` 和两个字符$c_1$ 和$c_2$，请你计算S 有多少个以$c_1$ 开头$c_2$ 结尾的子串可以采用这种简写？

### 前缀和

设`p[i]`为前i个字符中$c_1$字符的个数, 则对于下标为`j`的$c_2$字符, 以其结尾且可以简写的子串数量即为`p[j - k + 1]`

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
using ll = long long;
const int N = 5e5 + 10;
ll p[N], res;

int main () {
    int k; cin >> k;
    string s; char a, b; cin >> s >> a >> b;
    for (int i = 1; i <= s.size(); i ++) p[i] = p[i - 1] + (s[i - 1] == a);
    for (int i = k; i <= s.size(); i ++)
        if (s[i - 1] == b) res += p[i - k + 1];
    cout << res << endl;
    return 0;
}
```

## 试题H: 整数删除

### 题意描述

给定一个长度为N 的整数数列：$A_1,A_2...A_N$。

你要重复以下操作K 次：每次选择数列中最小的整数（如果最小值不止一个，选择最靠前的），将其删除。并把与它相邻的整数加上被删除的数值。

输出K 次操作后的序列。

### 双向链表 | 最小堆

由于要进行大量的删除操作, 不难想到可以使用链表.

而本题需要动态的求最小值, 显然可以使用堆.

每次从堆中取出最小值的下标, 然后在链表中删除它.

但本题特殊点在于`将其删除。并把与它相邻的整数加上被删除的数值`, 所以会导致还在堆中的元素的权的变化.

我们可以注意到, 每次删除操作只会让一些元素变大, 而不会让元素变小. 也就是, 可能会让原本的最小值变成不是最小值.

因此我们取出堆中的最小值时, 需要将此元素的排序权和实际的值进行对比, 如果实际的值变大了, 则当前元素并不一定是最小值, 需要重新放回堆中.

### 参考代码

每次删除操作最多会让两个元素的值变化, 因此从堆中取出的次数是k的线性, 时间复杂度为$O(n + k) \log n$

```cpp
//
// Created by trudbot on 2023/4/9.
//

#include <bits/stdc++.h>
using namespace std;
using ll = long long;
const int N = 5e5 + 10;
ll v[N], l[N], r[N];

void del(int x) {
    r[l[x]] = r[x], l[r[x]] = l[x];
    v[l[x]] += v[x], v[r[x]] += v[x];
}

int main () {
    int n, k; cin >> n >> k;
    r[0] = 1, l[n + 1] = n;
    priority_queue<pair<ll, int>, vector<pair<ll, int>>, greater<pair<ll, int>>> h;
    for (int i = 1; i <= n; i ++)
        cin >> v[i], l[i] = i - 1, r[i] = i + 1, h.push({v[i], i});
    while (k --) {
        auto p = h.top(); h.pop();
        if (p.first != v[p.second]) h.push({v[p.second], p.second}), k ++;
        else del(p.second);
    }
    int head = r[0];
    while (head != n + 1) {
        cout << v[head]<< " ";
        head = r[head];
    }
    return 0;
}
```

## 试题I: 景区导游

### 题意描述

某景区一共有N 个景点，编号1 到N。景点之间共有N − 1 条双向的摆渡车线路相连，形成一棵树状结构。在景点之间往返只能通过这些摆渡车进行，需要花费一定的时间。

小明是这个景区的资深导游，他每天都要按固定顺序带客人游览其中K 个景点：A1; A2; : : : ; AK。今天由于时间原因，小明决定跳过其中一个景点，只带游客按顺序游览其中K − 1 个景点。具体来说，如果小明选择跳过Ai，那么他会按顺序带游客游览$A_1，A_2... A_{i−1},A_{i+1},A_K$ (1 ≤ i ≤ K)。请你对任意一个Ai，计算如果跳过这个景点，小明需要花费多少时间在景点之间的摆渡车上？

### 带权LCA

要确定的一点是， 由于题中的图是一棵树， 所以对于任意两个顶点， 它们的最短路径就是它们的简单路径。

求树中两个结点的最短路径， 可以想到LCA。

设$dist[u]$为u顶点到根结点的距离， 那么u和v的距离即为$dist[u] + dist[v] - 2 * dist[lca(u, v)]$.

因此本题就是一道LCA的模板题， 使用倍增或者tarjan都是可以的, 具体的算法知识请自行去学习。

距离可能会爆int， 因此建议是所有整型都用long long， 避免麻烦。

### 参考代码

```cpp
//
// Created by trudbot on 2023/4/10.
//
#include <bits/stdc++.h>
using namespace std;
const int N = 1e5 + 10;
using ll = long long;
vector<pair<int, int>> g[N];
ll dep[N], f[N][30], dist[N];

void dfs(int u, int fa, ll d) {
    dep[u] = dep[fa] + 1, dist[u] = d, f[u][0] = fa;
    for (int i = 1; (1 << i) <= dep[u]; i ++) f[u][i] = f[f[u][i - 1]][i - 1];
    for (auto &p : g[u]) {
        if (p.first == fa) continue;
        dfs(p.first, u, d + p.second);
    }
}

int lca(int a, int b) {
    if (dep[a] < dep[b]) swap(a, b);
    for (int i = 20; i >= 0; i --) {
        if (dep[f[a][i]] >= dep[b]) a = f[a][i];
        if (a == b) return a;
    }
    for (int i = 20; i >= 0; i --) {
        if (f[a][i] != f[b][i]) a = f[a][i], b = f[b][i];
    }
    return f[a][0];
}

ll get(int a, int b) {
    return dist[a] + dist[b] - 2 * dist[lca(a, b)];
}

int main () {
    int n, k; cin >> n >> k;
    for (int i = 1; i < n; i ++) {
        int u, v, t; cin >> u >> v >> t;
        g[u].push_back({v, t}), g[v].push_back({u, t});
    }
    vector<int> a(k);
    for (auto &x : a) cin >> x;
    dfs(1, 0, 0);
    ll sum = 0;
    for (int i = 1; i < k; i ++) sum += get(a[i - 1], a[i]);
    for (int i = 0; i < k; i ++) {
        ll ans = sum;
        if (i != 0) ans -= get(a[i], a[i - 1]);
        if (i != k - 1) ans -= get(a[i], a[i + 1]);
        if (i != 0 && i != k - 1) ans += get(a[i - 1], a[i + 1]);
        cout << ans << " ";
    }
    return 0;
}
```

## 试题J: 砍树

### 题意描述

给定一棵由n 个结点组成的树以及m 个不重复的无序数对$(a_1,b_1), (a_2,b_2),...,(a_m,b_m)$，其中$a_i$ 互不相同，$b_i$ 互不相同，$a_i \neq b_j$(1 ≤ i, j ≤ m)。
小明想知道是否能够选择一条树上的边砍断，使得对于每个$(a_i,b_i)$ 满足$a_i$和$b_i$ 不连通，如果可以则输出应该断掉的边的编号（编号按输入顺序从1 开始），否则输出-1。

### 树上差分

同上题我们知道， 树中两个结点的简单路径是唯一的。

因此如果我们能找到一条边， 每组数对的两个结点的简单路径都要经过这条边， 那么就可以满足题意。

这时我们可以很简单的想到思路， 对于数对$(a, b)$， 我们遍历a到b路径上的每一条边， 让其权值加一。

最后若存在权值为m的边， 那么就满足题意。

但这样做时间复杂度显然最坏是$O(nm)$， 不达标。

这时候我们可以用到树上差分优化这一过程， 同理这里不会赘述它是什么， 请自行去学习[相关知识](https://www.cnblogs.com/TEoS/p/11376676.html)。

### 参考代码

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 1e5 + 10, M = 18;
vector<pair<int, int>> g[N];
int dep[N], f[N][20], cnt[N], w[N];

void init(int u, int fa) {
  dep[u] = dep[fa] + 1, f[u][0] = fa;
  for (int i = 1; (1 << i) <= dep[u]; i ++) f[u][i] = f[f[u][i - 1]][i - 1];
  for (auto &e : g[u]) {
    if (e.first != fa) init(e.first, u), w[e.first] = e.second;
  }
}

int lca(int a, int b) {
  if (dep[a] < dep[b]) swap(a, b);
  for (int i = M; i >= 0; i --) {
    if (dep[f[a][i]] >= dep[b]) a = f[a][i];
    if (a == b) return a;
  }
  for (int i = M; i >= 0; i --) {
    if (f[a][i] != f[b][i]) a = f[a][i], b = f[b][i];
  }
  return f[a][0];
}

void add(int a, int b) {
  int LCA = lca(a, b);
  cnt[a] ++, cnt[b] ++, cnt[LCA] -= 2;
}

void dfs(int u, int fa) {
  for (auto &e : g[u]) {
    if (e.first != fa) 
      dfs(e.first, u), cnt[u] += cnt[e.first];
  }
}

int main () {
  int n, m; cin >> n >> m;
  for (int i = 1; i < n; i ++) {
    int a, b; cin >> a >> b;
    g[a].push_back({b, i}), g[b].push_back({a, i});
  }
  init(1, 0);
  for (int i = 0; i < m; i ++) {
    int a, b; cin >> a >> b;
    add(a, b);
  }
  dfs(1, 0);
  int res = -1;
  for (int i = 1; i <= n; i ++) 
    if (cnt[i] == m && (w[i] > res)) res = w[i];
  cout << res << endl;
  return 0;
}
```

