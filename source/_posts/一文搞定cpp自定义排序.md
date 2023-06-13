---
title: 一文搞定c++自定义排序
author: trudbot
tags: 
- c++
- stl
categories: 一文搞定系列
abbrlink: 45215
date: 2022-08-23 22:05:14
---

# 前言

c++拥有强大的STL， 在对复杂的数据结构排序时只需要自定义去比较函数， 然后放到容器内调用api即可。

本该是很简单的东西， 但我之前一直无法记住升序以及降序两种方向该分别怎么写，总是会搞混，  每次都得现场Google。终于下定决心要在今天把它彻底搞定。

# 自定义排序的三种比较器形式



## 比较函数

STL中的`sort`函数已经为我们提供了排序算法的框架，我们唯一要做的决定就是对于两个元素`a`和`b`， 谁在前、谁在后？

<!--more-->



> sort函数的一个原型

```c++
void sort(_RandomAccessIterator __first, _RandomAccessIterator __last);//无比较器， 升序排序， 会调用<进行元素比较, 小的会放前面
void sort(_RandomAccessIterator __first, _RandomAccessIterator __last, _Compare __comp);//传入比较器， 前后顺序由比较强返回值决定
```

在`sort`函数中这即为第三个参数：比较器

**比较函数的基本形式**:

```
bool comp(const type& a, const type& b);
```

一般而言形参的形式为`const`、引用类型（当然不写也可以， 只是这样更安全、效率更高）。

而返回值于a、b的前后关系是**返回true时， a在前面; 返回false时, b在前面.**

如

```c++
bool comp(const int &a, const int &b) {
    return a < b;
}
```

返回值为`true`时， a在前面， 且`a<b`， 所以会是升序排序。

所以更透彻的讲， 比较函数的内容其实是**a要想排在b前面所要满足的条件**

**简单小例子**

若用pair<string, int> 存储着若干个学生的`name`和`score`信息， 要对这些学生进行排序， 

要求：

* 按分数从高到低
* 分数相等时按名字字典序排列

很容易的可以得到比较函数为

```c++
bool cmp(const pair<string, int> &a, const pair<string, int> &b) {
	if(a.second != b.second) {
		return a.second > b.second;
	}
	return a.first < b.first;
}
```

**lambda表达式**

比较函数在大多场景下可能仅需使用一次， 因此我们可以用lambda表示式来简写

如

```c++
sort(data.begin(), data.end(), [](const type& a, const type& b) -> bool {
        //judge something
    });
```



## 重载<运算符

有时候我们会用结构体或类来定义较为复杂的数据结构， 要对它进行自定义排序除了使用比较函数外， 还可以用重载运算符的方式。

以上面的学生例子举例

```c++
struct stu {
    string name;
    int score;

    bool operator < (const stu& b) const {
        if(score != b.score) {
            return score > b.score;
        }
        return name < b.name;
    }
};
```

上述代码重载了stu类的`<`运算符，和比较函数不同的时只有一个参数， 但其实只不过是a参数变成了当前的结构体 。

由于`sort`函数默认为升序, 会把用`<`比较的两个函数中小的放前面， 所以函数体编写思想和比较函数完全一致：写入要把a放到前面满足的条件。



## 函数对象比较器——重载()

其实就是定义一个结构体或类作为比较器， 重载`()`, 这样类名+`()`就成为了比较函数。

```c++
struct stu {
    string name;
    int score;

};

struct cmp {
    bool operator() (const stu& a, const stu& b) {
        if(a.score != b.score) {
            return a.score > b.score;
        }
        return a.name < b.name;
    }
};

int main() {
    vector<stu> a{{"abc", 100}, {"acb", 100}};
    sort(a.begin(), a.end(), cmp());
    for(const auto& i : a) {
        cout << i.name << " " << i.score << endl;
    }
}
```

# 容器应用

STL用两种比较对象来指代排序的两种方向， 分别是`less`和`greater`分别使用`<`和`>`， 对应升序和降序。在众容器中都默认使用less， 所以结构体要使用默认排序需要重载小于运算符。

也可以显示指出方向， 如以下代码对数组进行了降序排序。

```c++
int main() {
    vector<int> a{3, 8, 3, 2, 4};
    sort(a.begin(), a.end(), greater<>());//重载了< / >运算符， 即可使用less<> / greater<>
}
```

要注意的是在set， priority_queue这样的容器不能用比较函数的方式， 只能够使用重载的方式实现。

---

以及比较反人类的是当`priority_queue`使用`less`时其实是大根堆， 使用`greater<>`才是小根堆。

```c++
struct stu {
    string name;
    int score;

    bool operator < (const stu & b) const {
        if(score != b.score) {
            return score > b.score;
        }
        return name < b.name;
    }
};

int main() {
    priority_queue<stu, vector<stu>> heap;
    heap.push({"a", 100});
    heap.push({"b", 100});
    heap.push({"c", 110});
    while(!heap.empty()) {
        cout << heap.top().name << " " << heap.top().score << endl;
        heap.pop();
    }
}

//输出结果
/*
b 100
a 100
c 110

*/
```
