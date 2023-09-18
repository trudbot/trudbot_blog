---
title: 'react bug记录: useEffect中使用响应式变量'
mathjax: true
tags:
  - react
  - hooks
categories:
  - 前端
  - react
abbrlink: 50865
date: 2023-09-18 19:02:15
---

在使用useEffect API时出现了一些错误， 折腾好一会， 只能感慨还是看文档不认真。

<!--more-->

代码重现: 

```react
1. 创建state
const [groups, setGroups] = useState([]);
2. 通过useEffect创建连接                                      
useEffect(() => {
  const connection = createUnreadMessageConnection({useinfo });
  connection.on('remind', (groupId: number) => {
  	3. 监听事件
    // 使用groups 值do something 
  } 
  return () => {
    connection.disconnect();
  }
 }, [useInfo.state]);  
4. 异步请求数据
 getUserGroup({ ... }).then(res => {
   setGroups(res)
 })                                      
})
```

以上是相关代码的执行流程。

代码中的bug最终反映在前端界面上， 经过排查， 发现是`3`处， groups始终是空数组也就是初始值。

这个bug原因也很简单， 在[将事件从 Effect 中分开 – React 中文文档 (docschina.org)](https://react.docschina.org/learn/separating-events-from-effects)中提到

>  [Effect 读取的每一个响应式值都必须在其依赖项中声明](https://react.docschina.org/learn/lifecycle-of-reactive-effects#react-verifies-that-you-specified-every-reactive-value-as-a-dependency)

也就是说在useEffect中读取的每一个响应式值都必须作为其依赖。

注意响应式值并不一定是state， 也可以是组件内部使用state计算得到的变量、函数等。

---

要解决这个bug， 似乎将`groups`放入依赖列表就可以了， 就这么简单吗？

为什么要在useEffect建立连接呢， 因为如果放到组件函数体内， 组件每一次渲染，就会发起一次连接， 同时上一次连接会断开。

但从逻辑上， 只有当登录的用户信息变化时， 才需要重新建立连接， 所以useEffect非常适合这一个场景。

如果把groups放入依赖中， 每次groups变化， 都会重新连接， 这便又破坏了我们的连接逻辑。

来看useEffect中的代码。

```typescript
const connection = createUnreadMessageConnection({useinfo });
  connection.on('remind', (groupId: number) => {
  	3. 监听事件
    // 使用groups 值do something 
  } 
```

每次useinfo变化， 我们希望连接重新进行。 effect中的代码是响应式的， 但我们此刻希望， 即能通过依赖， 让一些逻辑保持响应式； 又可以在不依赖某些响应式值的状态下， 访问到它们的最新值(非响应式代码获取最新值)。

> 你需要一个将这个非响应式逻辑和周围响应式 Effect 隔离开来的方法。

## 解决方法: 包装

### useEffectEvent

[将事件从 Effect 中分开 – React 中文文档 (docschina.org)](https://react.docschina.org/learn/separating-events-from-effects#declaring-an-effect-event)中， 提供了useEffectEvent API的用法。

简单说就是， 将非响应式代码包装到useEffectEvent 中， 然后在useEffect中调用， 就可以不影响Effect响应式逻辑的情况下， 去获取state的最新值。

从名字也可以看出来， 这是用在`useEffect`中的事件处理函数， 完美符合我们的需求。

> 你可以将 Effect Event 看成和事件处理函数相似的东西。主要区别是事件处理函数只在响应用户交互的时候运行，而 Effect Event 是你在 Effect 中触发的。Effect Event 让你在 Effect 响应性和不应是响应式的代码间“打破链条”。

```typescript
const onRemind = useEffectEvent((groupId) => {
  // 使用groups做些什么
});

...
connection.on('remind', (groupId: number) => {
  onRemind(groupId);
} 
```

但此API仍处于实验性， 还没有进入正式版本。

### Reducer

使用Reducer在某些情况下也可以实现对state的包装， reducer被创建后， 本身一般是不会被改变的， 它接收用户的操作， 在内部对state进行更改。 因此我们在useEffect内部， 可以通过Reducer这一中间层， 间接的对state进行修改。

```typescript
const groupDataReducer = (state, action) => {
	switch(action) {
	case "remind":
		// do something
	}
}

...
const [state, dispatch] = useReducer(groupDataReducer, {
	groups: [],
});

connection.on('remind', (groupId: number) => {
  dispatch({
    type: 'remind',
    value: groupId
  })
} 
```

---

我真幸运， 第一次写react就遇到了react的小缺陷(maybe)。