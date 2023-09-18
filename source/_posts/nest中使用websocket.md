---
title: nest中使用websocket
mathjax: true
tags:
  - websocket
  - nest
categories:
  - 后端
  - nest
abbrlink: 52255
date: 2023-09-07 20:20:21
---

本文主要总结nest中如何使用socket.io等WebSocket库， socket.io的使用可见[socket.io](https://socket.io/zh-CN/)

<!--more-->

## 网关注解

要在nest中写websocket相关的代码， 需要创建一个被`@WebSocketGateway()`装饰的类， 里面封装了websocket服务基本的API。

```typescript
@WebSocketGateway({})
export class ChatGetWay {}
```

在类中有三个固定名称的钩子函数， 控制着websocket的生命周期: 

1. afterInit(), 参数为服务器实例
2. handleConnection()， 参数为客户端实例
3. handleDisconnect()， 参数为客户端实例

作用顾名思义。

## Socket.io配置

在使用socket.io创建服务器时， 往往需要进行相关配置如跨域等

```typescript
// server-side
const io = new Server(httpServer, {
  cors: {
    origin: "https://example.com",
    allowedHeaders: ["my-custom-header"],
    credentials: true
  }
});
```

在nest中， 只需要将配置对象传入注解即可。

```typescript
@WebSocketGateway({
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    },
    namespace: 'chat'
})
```

在网关的第一个参数可以设置websocket的端口

```typescript
@WebSocketGateway(80, { namespace: 'events' })
```

当然， 如果你不传入此参数， websocket服务器会自动挂载到nest启动的http服务器上， 监听相同的端口。

## Socket.io业务

socket.io中最重要的就是发送和接收事件消息了。 在nest中， 需要使用`@SubscribeMessage()`注解来装饰一个函数， 使其成为事件处理函数。

```typescript
@SubscribeMessage('message') // 订阅`message`事件
handleMessage(
  @ConnectedSocket() client, // 发送消息的客户端引用
  @MessageBody() data // 事件携带的信息
) {
  // do something
}
```

上面使用了两个注解来修饰事件处理函数的参数， 这是因为websocket网关是跨平台的， 平台不同， 客户端实例和消息格式也都可能不同。

### socket.io服务器实例

要在nest中使用socket.io发送消息， 需要直接访问到服务器实例。

使用`@WebSocketServer()`注解修饰成员变量， 即可获得服务器实例。

```typescript
@WebSocketServer()
server: Server;
```

更多的与平台API相关的操作都可以通过服务器实例来完成。

```typescript
this.server.to(group).emit('message', msg);
```

## 使用WebSocket服务

WebSocket网关类是特殊的Provider，也就是类似于被`@Injectable()` 的类， 使用上是类似的。可以通过构造函数注入其它Service、被模块管理， 也可以被注入。

## websocket和http同端口时的跨域问题

如果你的后端中http和websocket是使用的同一端口， 即时你nest实例和websocket网关都配置了跨域， 你在使用客户端的时候还是会发生跨域。

这是以为socket.io客户端进行连接时， 首先会尝试建立HTTP长轮询连接， 连接成功后才会尝试建立WebSocket连接。

而同一端口已经存在了处理HTTP的服务器, 因此客户端尝试建立HTTP长轮询时， 就会发生错误。

解决办法是， 在客户端创建连接时配置， 只允许建立WebSocket连接。

```typescript
const connection = io(url, {transports: ['websocket'] });
```

或者， 给socket.io服务器一个单独的端口。

## 参考

[WEBSOCKETS (nestjs.cn)](https://docs.nestjs.cn/10/websockets)

[介绍 | Socket.IO](https://socket.io/zh-CN/docs/v4/)

[客户端配置 | Socket.IO](https://socket.io/zh-CN/docs/v4/client-options/#transports)