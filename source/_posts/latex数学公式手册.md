---
title: latex数学公式手册
mathjax: true
tags:
  - latex
  - markdown
categories:
  - 数学
abbrlink: 48306
date: 2023-02-26 20:58:29
---
由于markdown语法的局限性， 在写markdown文本时经常需要用到扩展的语法来满足更多的需求。而内嵌式latex是最广泛的markdown编写数学公式的解决方案。

![image-20230303215814126](https://raw.githubusercontent.com/trudbot/trudbot_images/main/md_img/image-20230303215814126.png)

本文将以表格的形式分类介绍$L^AT_EX$的各种公式及语法， 其中只包含我用过的或觉得很重要的， 内容会随时间不断更新。

<!--more-->

## 保留字

保留字是latex语法中有特殊含义的字符， 要使其以正常文本显示需要特定的语法。

| 序号 | latex显示 | latex源码 | 解释 |
| :-:| :-: | :-: | :-: |
| 1 | $\%$ | `\%` | %在latex中用于注释 |
| 2 | $\{$ | `\{` | `{`和`}`在latex中是作用域的界定符号 |
| 3 | $\}$ | `\}` | `{`和`}`在latex中是作用域的界定符号 |
| 4 | $\backslash$ |`\backlash`|`\`是latex中用于转义的符号|

## 希腊字母

一下均为小写, 大写只需要首字母大写即可.

| 序号 |   latex显示   |     latex源码     |
| :--: | :-----------: | :---------------: |
|  1   |   $\alpha$    |     `\alpha`      |
|  2   |    $\beta$    |      `\beta`      |
|  3   |   $\delta$    |     `\delta`      |
|  4   |   $\Delta$    |     `\Delta`      |
|  5   |   $\theta$    |     `\theta`      |
|  6   |     $\pi$     |       `\pi`       |
|  7   |    $\chi$     |      `\chi`       |
|  8   |   $\omega$    | `\omega / \Omega` |
|  9   |   $\lambda$   |     `\lambda`     |
|  10  |   $\sigma$    |      `sigma`      |
|  11  |     $\mu$     |       `\mu`       |
|  12  | $\varepsilon$ |   `\varepsilon`   |

## 运算符

| 序号 | latex显示 |    中文名    | latex源码 |
| :--: | :-------: | :----------: | :-------: |
|  1   |    $+$    |      加      |    `+`    |
|  2   |    $-$    |      减      |    `-`    |
|  3   | $\times$  |     叉乘     | `\times`  |
|  4   |  $\cdot$  |     点乘     |  `\cdot`  |
|  5   |  $\div$   |     除号     |  `\div`   |
|  6   |    $/$    |     除号     |    `/`    |
|  7   | $\oplus$  |     异或     | `\oplus`  |
|  8   |   $\pm$   | 加或减(正负) |   `\pm`   |

## 关系符

| 序号 | latex显示 |  中文名  |    latex源码    |
| :--: | :-------: | :------: | :-------------: |
|  1   |    $=$    |   等于   |       `=`       |
|  2   |  $\neq$   |  不等于  |     `\neq`      |
|  3   | $\equiv$  |  恒等于  |    `\equiv`     |
|  4   |    $<$    |   小于   |       `<`       |
|  5   |   $\le$   | 小于等于 | `\le` or `\leq` |
|  6   |    $>$    |   大于   |       `>`       |
|  7   |   $\ge$   | 大于等于 | `\ge` or `\geq` |
## 集合关系

|   latex显示    |  解释  |   latex源码    |
| :------------: | :----: | :------------: |
| $\varnothing$  |  空集  | `\varnothing`  |
|   $A\cap B$    |  交集  |   `A\cap B`    |
|   $A \cup B$   |  并集  |   `A \cup B`   |
| $\overline{A}$ |  补集  | `\overline{A}` |
|   $x \in A$    |  属于  |   `x \in A`    |
|  $x \notin A$  | 不属于 |  `x \notin A`  |
| $A \subset B$  | 包含于 | `A \subset B`  |
|   $\forall$    |  任意  |   `\forall`    |
|    $\exist$    |  存在  |    `\exist`    |

## 上下标

|    类型    |               latex显示               |               latex源码               |
| :--------: | :-----------------------------------: | :-----------------------------------: |
|    上标    |           $2^a, 2^{a + b}$            |           `2^a, 2^{a + b}`            |
|    下标    |     $CO_2, log_2100, log_{ab}cd$      |     `CO_2, log_2100, log_{ab}cd`      |
| 符号上下标 | $\sum^n_{i=1}, \ \sum\limits^n_{i=1}$ | `\sum^n_{i=1}, \ \sum\limits^n_{i=1}` |

## 箭头符号

| 序号 |   latex显示   |   latex源码   |
| :--: | :-----------: | :-----------: |
|  1   | $\Rightarrow$ | `\Rightarrow` |
|  2   | $\Leftarrow$  | `\Leftarrow`  |
|  3   |    $\iff$     |    `\iff`     |

## 分数

|   类型   |                    latex显示                     |                    latex源码                     |
| :------: | :----------------------------------------------: | :----------------------------------------------: |
| 普通分数 |           $\frac{1}{2} \frac{abc}{2}$            |           `\frac{1}{2} \frac{abc}{2}`            |
| 大型分数 | $\dfrac{2}{c + \dfrac{2}{d + \dfrac{2}{4}}} = a$ | `\dfrac{2}{c + \dfrac{2}{d + \dfrac{2}{4}}} = a` |

## 数学函数

|   类型   |                    latex显示                     |                    latex源码                     |
| :------: | :----------------------------------------------: | :----------------------------------------------: |
| 对数函数 |       $\ln c, \lg d = \log e, \log_{10} f$       |       `\ln c, \lg d = \log e, \log_{10} f`       |
| 三角函数 | $\sin a, \cos b, \tan c, \cot d, \sec e, \csc f$ | `\sin a, \cos b, \tan c, \cot d, \sec e, \csc f` |

## 根式

|  类型  |    latex显示    |    latex源码    |
| :----: | :-------------: | :-------------: |
| 平方根 |  $\sqrt{abc}$   |  `\sqrt{abc}`   |
| n次根  | $\sqrt[n]{abc}$ | `\sqrt[n]{abc}` |
## 模运算

|          latex显示          |          latex源码          |
| :-------------------------: | :-------------------------: |
| $a^{n-1} \equiv 1 \pmod{n}$ | `a^{n-1} \equiv 1 \pmod{n}` |
|         $a \bmod b$         |         `a \bmod b`         |

## 大型运算符

| 类型 |        latex显示         |        latex源码         |
| :--: | :----------------------: | :----------------------: |
| 求和 |  $\sum\limits_{i=1}^n$   |  ` \sum\limits_{i=1}^n`  |
| 交集 | $\bigcap\limits_{i=1}^n$ | `\bigcap\limits_{i=1}^n` |
| 并集 | $\bigcup\limits_{i=1}^n$ | `\bigcup\limits_{i=1}^n` |

## 二项式系数

| 类型 |            latex显示            |            latex源码            |
| :--: | :-----------------------------: | :-----------------------------: |
| 普通 |         $\binom{n}{k}$          |         `\binom{n}{k}`          |
| 小型 |         $\tbinom{n}{k}$         |         `\tbinom{n}{k}`         |
| 大型 | $\dbinom{\frac{a + b}{2}}{x^2}$ | `\dbinom{\frac{a + b}{2}}{x^2}` |

## 积分

|   类型   |      latex显示      |      latex源码      |
| :------: | :-----------------: | :-----------------: |
| 一重积分 | $\int_{0}^1 e^x dx$ | `\int_{0}^1 e^x dx` |
| 多重积分 |   $\iint, \iiint$   |   `\iint, \iiint`   |

## 空格

|   类型   |     latex显示     |     latex源码     |
| :------: | :---------------: | :---------------: |
|  单空格  | $a \quad b \ c d$ | `a \quad b \ c d` |
|  双空格  |   $a \qquad b$    |   `a \qquad b`    |
| 转义空格 |      $a \ b$      |      `a \ b`      |

## 文本颜色

使用`{\color{colorName}text}`即可使对应文本使用指定的颜色

|                        latex显示                         |                        latex源码                         |
| :------------------------------------------------------: | :------------------------------------------------------: |
| ${\color{orange}x^2} + {\color{cyan}x} + {\color{red}1}$ | `{\color{orange}x^2} + {\color{cyan}x} + {\color{red}1}` |

## 参考

[Hank 博客](http://www.uinio.com/Math/LaTex/)

[LaTeX - A document preparation system (latex-project.org)](https://www.latex-project.org/)