---
title: git commit message 规范
mathjax: true
tags:
  - git
  - 规范
categories:
  - git
abbrlink: 18402
date: 2023-09-18 22:24:55
---
commit message的规范格式很有必要， 让别人和未来的自己都能更快速的浏览commits。在此记录相关规则供自查。

## 规范
```
<type>(<scope>): <subject>
// 空一行
<body>
```

### type

本次commit的归类。

* `Feat`– feature | 新功能
* `Fix`– bug fixes | 修补bug
* `Docs`– changes to the documentation like README | 文档
* `Style`– style or formatting change | 格式（不影响代码运行的变动）
* `Perf` – improves code performance | 优化相关，比如提升性能、体验。
* `Test`– test a feature | 增加测试

* `ReFactor`- A code that neither fix bug nor adds a feature. | 重构（即不是新增功能，也不是修改bug的代码变动）
* `Chore`: Changes that do not affect the external user  | 构建过程或辅助工具的变动。

* `Revert`：回滚
* `Merge`：代码合并。

### scope

The “scope” field should be a noun that represents the part of the codebase affected by the commit.

For example, if the commit changes the login page, the scope could be “login”. If the commit affects multiple areas of the codebase, “global” or “all” could be used as the scope.

### subject

`subject`是 commit 目的的简短描述，不超过50个字符。

### Body

Body 部分是对本次 commit 的详细描述，可以分成多行。

