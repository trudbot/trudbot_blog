---
title: vue组件和插槽之间的通信
mathjax: true
tags:
  - element-plus
  - vue
categories:
  - 前端
  - vue
abbrlink: 26800
date: 2023-10-04 14:38:04
---

vue高度封装的语法也会有很多弊端， 父组件与插槽之间的通信就是其中之一。

<!--more-->

## 应用场景？

对组件进行封装时， 我们往往希望父组件和子组件有所关联。

如一个选择器组件`select`

```vue
<my-select v-model="selectedData">
	<my-option :value="data1"/>
	<my-option :value="data2"/>
  <my-option :value="data3"/>
</my-select>
```

且不考虑UI如何实现， 看数据流。

在select组件中， 希望其插槽中可以放若干个`option`组件， option组件可以绑定数据， 选择option后`select`能获得对应数据。

仔细一想会发现， vue目前的插槽机制做不到这一点。

* 组件和插槽内容的直接通信: vue中插槽内容完全是由外界定义的， 而常见通信方法如`props`、`emit`都需要在已知结构的情况下绑定。换句话说， `option`没有直接途径， 告诉`select`自己被选中了。
* vue中插槽是一对一的(导致结构样式编写上的不便)。由插槽内容定义者在插槽中写入的option数量来决定插槽的数量， 原组件可以访问到每个插槽内容并自行渲染结构（类似jsx)， 听起来很美， 但做不到。

> vue中组件和插槽唯一的直接通信机制是**作用域插槽**， 但这并不是组件和插槽内容的通信， 而是组件和插槽定义者之间的通信， 使定义者可以获取插槽所在的组件的一些数据， 进而手动将数据传递给插槽内容。

## 万能通信方法

那些UI框架是如何实现这一点的呢？

答案比较暴力， 使用`provide/inject` api来传递一个公共对象。

比如在select中， `provide`一个包含了`selectedData`ref的对象

```js
const selectedData = ref(null);
provide('my-select', {
  selected: selectedData
})
```

在子组件中接收使用

```js
const mySelectContext = inject('my-select');
function click() {
	mySelectContext.selected.value = props.value;
}
```

这样就实现了插槽组件数据对父组件数据的绑定。

这种通信方式非常灵活， 你可以通过传递方法、被包装的对象给子组件等等， 实现任何方向的通信。

## 实际应用

在`element-plus`中， 有一个工具hook： `getOrderedChildren`， 见名知意， 作用是返回组件的插槽子组件数组， 并保持其在html结构上的顺序。

以下仍以`select`和`option`的父子关系举例如何实现。

---

1. 获取所有的子组件数据

在select中定义一个ref数组， 并通过provide提供给子组件

```typescript
// select.vue
const orderedChildren = shallowRef<OptionContext[]>([]);
provide('SelectContext', {
  orderedChildren
})
```

在`option`中注入， 并在组件mounted的时候将自己的数据添加至其中

```typescript
// option.vue
const selectContext = inject('SelectContext');

onMounted(() => {
  selectContext.orderedChildren.push({
    data: props.value
  })
})
```

这样最基本的功能就实现了。

但考虑到插槽内的`option`可能是动态的， 因此需要添加删除功能。

在`option`中， 将组件的唯一标识`uid`添加到数据中

```typescript
// option.vue
onMounted(() => {
  selectContext.orderedChildren.push({
    uid: getCurrentInstance().uid,
    data: props.value
  })
})
```

父组件即可以根据uid来执行删除操作

```typescript
//select.vue

const removeChild = (uid: number) => {
  delete children[uid]
  orderedChildren.value = orderedChildren.value.filter(
    (children) => children.uid !== uid
  )
}
```

将方法传递给子组件， 子组件在unmount时调用， 便实现了子组件对数据的生命周期的自动管理。

```typescript
// select.vue
provide('SelectContext', {
  orderedChildren,
  removeChild
})

// option.vue
onUnmounted(() => {
   selectContext?.removeChild(instance.uid)
})
```

---

2. 保持子组件在html结构上的顺序

vue中并没有提供直接的api访问组件的dom树， 所以需要自己去拿到组件的实例， 遍历其虚拟dom树。

通过`getCurrentInstance()`方法， 我们能拿到组件的实例， 结构如下。

```typescript
export interface ComponentInternalInstance {
    uid: number;
    type: ConcreteComponent;
    parent: ComponentInternalInstance | null;
    root: ComponentInternalInstance;
    appContext: AppContext;
    /**
     * Vnode representing this component in its parent's vdom tree
     */
    vnode: VNode;
    /* removed internal: next */
    /**
     * Root vnode of this component's own vdom tree
     */
    subTree: VNode;
    /**
     * Render effect instance
     */
    effect: ReactiveEffect;
    /**
     * Bound effect runner to be passed to schedulers
     */
    update: SchedulerJob;
    proxy: ComponentPublicInstance | null;
    exposed: Record<string, any> | null;
    exposeProxy: Record<string, any> | null;
    /* removed internal: withProxy */
    /* removed internal: ctx */
    data: Data;
    props: Data;
    attrs: Data;
    slots: InternalSlots;
    refs: Data;
    emit: EmitFn;
    attrsProxy: Data | null;
    slotsProxy: Slots | null;
    isMounted: boolean;
    isUnmounted: boolean;
    isDeactivated: boolean;
}
```

主要看`subTree`这个属性， 它存放的便是从当前组件开始的虚拟dom树。

`VNode`便是vue的虚拟dom树的结点， 结构如下。

```typescript
export interface VNode<HostNode = RendererNode, HostElement = RendererElement, ExtraProps = {
    [key: string]: any;
}> {
    /* removed internal: __v_isVNode */
    
    type: VNodeTypes;
    props: (VNodeProps & ExtraProps) | null;
    key: string | number | symbol | null;
    ref: VNodeNormalizedRef | null;
    /**
     * SFC only. This is assigned on vnode creation using currentScopeId
     * which is set alongside currentRenderingInstance.
     */
    scopeId: string | null;
    /* removed internal: slotScopeIds */
    children: VNodeNormalizedChildren;
    component: ComponentInternalInstance | null;
    dirs: DirectiveBinding[] | null;
    transition: TransitionHooks<HostElement> | null;
    el: HostNode | null;
    anchor: HostNode | null;
    target: HostElement | null;
    targetAnchor: HostNode | null;
    /* removed internal: staticCount */
    suspense: SuspenseBoundary | null;
    /* removed internal: ssContent */
    /* removed internal: ssFallback */
    shapeFlag: number;
    patchFlag: number;
    /* removed internal: dynamicProps */
    /* removed internal: dynamicChildren */
    appContext: AppContext | null;
    /* removed internal: ctx */
    /* removed internal: memo */
    /* removed internal: isCompatRoot */
    /* removed internal: ce */
}
```

其中`children`便是结点的所有子元素数组， 且在顺序上与真实dom结构是一致的。

因此我们可以遍历dom树， 找出所有的`option`元素， 这样就得到了顺序。

为了给`option`组件一个唯一的标识， 以支持我们的查找， 可以为`option`定义一个name

```typescript
// option.vue
defineOptions({
  name: 'trudbot-option'
})
```

在`element-plus`中， 是以扁平化虚拟dom树， 然后过滤来实现查找的。

```typescript
const nodes = flattedChildren(vm.subTree).filter(
  (n): n is VNode =>
  isVNode(n) &&
      (n.type as any)?.name === childComponentName &&
      !!n.component
)
```

改变添加组件的策略， 添加数据时， 先以uid为键保存子组件数据， 然后遍历dom树得到顺序，在根据顺序得到数组。

```typescript
const children: Record<number, T> = {}
const orderedChildren = shallowRef<T[]>([])

const addChild = (child: T) => {
  children[child.uid] = child
  const nodes = flattedChildren(vm.subTree).filter(
    (n): n is VNode =>
    isVNode(n) &&
        (n.type as any)?.name === childComponentName &&
        !!n.component
  )
  const uids = nodes.map((n) => n.component!.uid)
  orderedChildren.value =  uids.map((uid) => children[uid]).filter((p) => !!p)
}
```

同样， 删除组件时， 也把组件的uid记录删除

```typescript
const removeChild = (uid: number) => {
  delete children[uid]
  orderedChildren.value = orderedChildren.value.filter(
    (children) => children.uid !== uid
  )
}
```

provide增加和删除组件的方法， 而不直接传递数组

```typescript
provide('SelectContext', {
  addChild,
  removeChild,
})
```

至此， 父组件在任何情况下都能通过orderedChildren访问到插槽内`option`的数据， 因为数据会随`option`的生命周期自动管理。

---

有什么用？

这是一个通用的hooks， 能够帮助组件轻松的访问到插槽内指定组件提供的数据， 而且组件数据的顺序是稳定的。

此hook在`element-plus`的`carousel`、`tabs`等组件中均有应用。

普通的插槽通信， 也许直接provide就够用了；而通信较复杂时， 可以使用此hook， 清晰、稳定。



## 参考

[element-plus/packages/hooks/use-ordered-children (github.com)](https://github.com/element-plus/element-plus/blob/dev/packages/hooks/use-ordered-children/index.ts)

[依赖注入 | Vue.js (vuejs.org)](https://cn.vuejs.org/guide/components/provide-inject.html#prop-drilling)