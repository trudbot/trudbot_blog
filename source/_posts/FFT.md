---
title: FFT
mathjax: true
tags:
  - FFT
  - 多项式乘法
  - 高精度乘法
categories:
  - 数论
  - 多项式
abbrlink: 19154
date: 2023-07-14 14:50:03
---

**先来回忆一下高精度乘法的原理**

对于正整数相乘$A * B$， 将`A`视为$a_0 + a_1 * 10^1 + a_2 * 10^2 + ... + a_n * 10^n$, `B`同理为$b_0 + b_1 * 10^1 + b_2 * 10^2 + ... + b_n * 10^m$, 将`A * B`视作多项式相乘， 得到`C`的多项式形式为$c_0 + c_1 * 10^1 + c_2 * 10^2 + ... + c_{n + m} * 10^{n + m}$， 然后逐一进位， 即可得到`C`的值。

其中， $c_k = \sum\limits_{i=0}^na_i * b_{k - i}$

这种方法的时间复杂度为$O(n*m)$级别， 而FFT可以以$O(n\log n)$的复杂度计算得到多项式乘积。

<!--more-->

## 多项式的点值表示

设`n`次多项式$f(x) = a_0x^0 + ... + a_{n-1}x^(n - 1) + a_nx^n$， 

由线性代数知识可知， 若知道了n+1组不同的`[x, f(x)]`的关系， 即可得到一个`n+1 x n+1`的多元线性方程组， 且这个方程组有唯一解。

也就是说， 对于一个`n`次多项式$f(x)$， 我们可以用$\{(x_0, y_0), (x_1, y_1), (x_2, y_2), ..., (x_n, y_n)\}$来定义它, 其中$y_k = f(x_k)$。

设`n`次多项式$f(x)$和`m`次多项式$g(x)$, 由于$f(x) * g(x)$的结果最多是`n + m`次， 所以我们将两个多项式进行零填充到`n + m`次， 此时如果
$$
f(x) = \{(x_0, f(x_0)), (x_1, f(x_1)),..., (x_{n+m}, f(x_{n+m}))\} \\
g(x) = \{(x_0, g(x_0)), (x_1, g(x_1)), ..., (x_{n+m}, g(x_{n+m}))\}
$$
则
$$
f(x) * g(x) = \{(x_0, f(x_0) * g(x_0)), (x_1, f(x_1) * g(x_1)), ..., (x_{n+m}, f(x_{n+m}) * g(x_{n + m})\}
$$
可以看到， 在点值形式下， 计算$f(x) * g(x)$仅需$O(n + m)$, 如果我们能快速地将多项式转换为点值形式， 计算后， 再将结果快速地转换为系数形式， 就能以较低的时间复杂度完成多项式的计算。

## 离散傅里叶变换（DFT)

我们要将`n`次多项式$f(x)$转换为点值形式， 该怎么做呢？

可以任意取`n + 1`个x值， 带入进行计算， 但这样时间复杂度是$O(n^2)$！

数学家傅里叶取了一组特殊的点带入， 使得其可以进行优化。

### 单位根

若复数$\omega$满足$\omega^n = 1$， 则称$\omega$为n次单位根。

将单位圆`n`等分， 即可得到圆上的n个坐标点，而这n个坐标点表示的复数都是`n`次单位根。其中第k个n次单位根称为$\omega_n^k$， 特变的， $\omega_n^0 = \omega_n^n = 1$, 即(1, 0)为起点， 逆时针. 易得$\omega^k_n = \cos{\dfrac{2k\pi}{n}} + i sin{\dfrac{2k\pi}{n}}$

### 单位根的性质

在本文中需要用到单位根的如下性质(均可通过展开式推导得出)：

* $\omega^k_n * \omega_n^m= \omega^{k + m}_n$

* $\omega^{rk}_{rn} = \omega^k_n$
* $\omega_n^{k + \frac n2} = -\omega_n^k$

---

而离散傅里叶变换就是一组单位根作为x值， 但如果还是直接代入计算的话， 复杂度仍然没有变化。

## 快速傅里叶变换(FFT)

快速傅里叶变换是一种能在计算机中快速地计算离散傅里叶变换的算法。

FFT的基本思想是分治。 

设`n-1`阶多项式$f(x) = \sum\limits_{i=0}^{n-1}a_ix^i$，且$n$为2的整数幂（不够则零填充），上面我们知道要求$f(x)$的点值形式， 也就是对每一个k求出$f(\omega_n^k)$。

将$f(x)$按奇数次幂和偶数次幂分为两部分：
$$
\begin {eqnarray}
f(x) &=& a_0 + a_1x + ... + a_{n-1}x^{n-1}\\
		 &=& (a_0 + a_2x^2 + ... + a_{n-2}x^{n-2}) + (a_1x + a_3x^3 + ... + a_{n-1} x^{n-1})
\end {eqnarray}
$$
设
$$
\begin {eqnarray} 
g(x) &=& a_0 + a_2x^1 + ... + a_{n-2}x^{\frac n2 - 1}\\
h(x) &=& a_1 + a_3x + ... + a_{n-1} x^{\frac n2 - 1}\\
\end {eqnarray}
$$
则
$$
f(x) = g(x^2) + xh(x^2)
$$
代入$x = \omega_n^k$得
$$
\begin {eqnarray}
f(\omega^k_n) &=& g((\omega^k_n) ^2) + \omega^k_n * h((\omega^k_n) ^ 2)\\
							&=& g(\omega^{2k}_n) + \omega^{k}_nh(\omega^{2k}_n)\\
							&=& g(\omega^k_{\frac n2}) + \omega^k_{n}h(\omega^k_{\frac n2})
\end {eqnarray}
$$
且
$$
\begin {eqnarray}
f(\omega^{k + \frac n2}_n) =  f(-\omega^{k}_n)&=& g((\omega^k_n) ^2) - \omega^k_n * h((\omega^k_n) ^ 2)\\
							&=& g(\omega^k_{\frac n2}) - \omega^k_{n}h(\omega^k_{\frac n2})
\end {eqnarray}
$$
故求出$f(\omega^k_n)$和$f(\omega^{k + \frac n2}_n)$只需要先求出$g(\omega^k_{\frac n2})$和$h(\omega^k_{\frac n2})$.

假设我们已经求出了`g`和`h`在$\{\omega_{\frac n2}^0, \omega_{\frac n2}^1, ..., \omega_{\frac n2}^{\frac n2 -1}\}$的值, 就可以求出所有的`f`的点值表示。

`g`和`h`的问题规模都是`f`的一半, 所以时间复杂度为$O(n\log_2 n)$

## 离散傅里叶逆变换(IDFT)

用矩阵乘法表示DFT的过程为
$$
\begin {bmatrix}
1 & 1 & 1 &\cdots & 1 \\
1 & \omega_n^1 & (\omega_n^1)^2 & \cdots & (\omega_n^{1})^{n-1}\\
1 & \omega_n^2 & (\omega_n^2)^2 & \cdots & (\omega_n^2)^{n-1}\\
\vdots & \vdots &\ddots & \vdots \\
1 & \omega_n^{n-1} & (\omega_n^{n-1})^2&\cdots & (\omega_n^{n-1})^{n-1}
\end {bmatrix}
\cdot 
\begin {bmatrix}
a_0 \\ a_1 \\ a_2 \\ \vdots \\ a_{n-1}
\end {bmatrix}
=
\begin {bmatrix}
y_0 \\ y_1 \\ y_2 \\ \vdots \\ y_{n-1}
\end {bmatrix}
$$
FFT结束后我们得到了最右边的结果， 所以要得到系数矩阵只需要让结果乘以中间大矩阵的逆矩阵即可。

怎么求这个矩阵的逆矩阵呢？这里的结论是**每一项取倒数，再除以多项式的长度n**, 至于证明可以参见[快速傅里叶变换（FFT）超详解 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/347091298)

## 快速傅里叶逆变换(IFFT)

结果矩阵乘以逆矩阵这个过程显然和FFT的过程很相似，考虑怎么转化。

观察$f(x) = g(x^2) + xh(x^2)$， 要求$f(x)$的IFFT， 首先求出$g(x^2)$和$h(x^2)$的IFFT， 且将x取反， 最后加和后再除以n， 即可完成。

所以IFFT和FFT可以公用一套代码， 只需要用一个标志位来控制关键位置的取反。

## 代码实现

```c++
//
// Created by trudbot on 2023/7/14.
//
#include "complex"

//sign为1时是FFT， -1是IFFT
//n必须为2的整数次幂
const double pi = acos(-1);
void FFT(std::complex<double> *a, int n, int sign) {
    if (n == 1) return;
    std::complex<double> g[n / 2], h[n / 2];
    for (int i = 0, j = 0; i < n; i += 2, j ++) {
        g[j] = a[i], h[j] = a[i + 1];
    }
    FFT(g, n / 2, sign), FFT(h, n / 2, sign);
    std::complex<double> w(1, 0), u(cos(2 * pi) / n, sign * sin(2 * pi / n));
    for (int i = 0; i < n / 2; i ++, w *= u) {
        a[i] = g[i] + w * h[i];
        a[i + n / 2] = g[i] - w * h[i];
    }
}

void DFT(std::complex<double> *a, int n) {
    FFT(a, n, 1);
}

void IDFT(std::complex<double> *a, int n) {
    FFT(a, n, -1);
    for (int i = 0; i < n; i ++) {
        a[i] /= n;
    }
}
```



## 参考

[超详细易懂FFT（快速傅里叶变换）及代码实现_Trilarflagz的博客-CSDN博客](https://blog.csdn.net/Flag_z/article/details/99163939)

[快速傅里叶变换（FFT）超详解 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/347091298)

[傅里叶变换与大数乘法 - Free_Open - 博客园 (cnblogs.com)](https://www.cnblogs.com/freeopen/p/5482950.html)

[如何通俗易懂地解释卷积？ - 知乎 (zhihu.com)](https://www.zhihu.com/question/22298352)

[如何通俗地解释什么是离散傅里叶变换？ - 知乎 (zhihu.com)](https://www.zhihu.com/question/21314374)

[快速傅里叶变换 - OI Wiki (oi-wiki.org)](https://oi-wiki.org/math/poly/fft/#快速傅里叶逆变换)

[欧拉公式_百度百科 (baidu.com)](https://baike.baidu.com/item/欧拉公式)

[如何用latex编写矩阵（包括各类复杂、大型矩阵）？ - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/266267223)

