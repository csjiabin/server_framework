package server_framework

import net.http.HttpStatusCode
import server_framework.server.{Router, Engine, HandlerFunc, BaseHttpContext}
import server_framework.model.User

func GroupMiddlewareFunc1(next: HandlerFunc): HandlerFunc {
    return {
        ctx =>
        println("pre GroupMiddlewareFunc1")
        next(ctx)
        println("post GroupMiddlewareFunc1")
    }
}

func GroupMiddlewareFunc2(next: HandlerFunc): HandlerFunc {
    return {
        ctx =>
        println("pre GroupMiddlewareFunc2")
        next(ctx)
        println("post GroupMiddlewareFunc2")
    }
}

func RouterMiddlewareFunc1(next: HandlerFunc): HandlerFunc {
    return {
        ctx =>
        println("pre RouterMiddlewareFunc1")
        next(ctx)
        println("post RouterMiddlewareFunc1")
    }
}

func RouterMiddlewareFunc2(next: HandlerFunc): HandlerFunc {
    return {
        ctx =>
        println("pre RouterMiddlewareFunc2")
        next(ctx)
        println("post RouterMiddlewareFunc2")
    }
}

func userList(ctx: BaseHttpContext): Unit {
    println("user list")
    ctx.status(HttpStatusCode.STATUS_OK).html("<h1>user list；用户列表</h1>")
}

func userGet(ctx: BaseHttpContext): Unit {
    println("user get")

    let user = User()
    user.age = 28
    user.name = "仓颉"
    user.email = "cangjie@gmail.com"
    user.phone = "18666666666"
    ctx.json(user)
}

func userInfo(ctx: BaseHttpContext): Unit {
    println("user info")
    let id = ctx.query.get("id")
    let name = ctx.query.get("name").getOrDefault({=> "仓颉"})
    let phone = ctx.query.get("phone").getOrDefault({=> "18134567898"})
    let email = ctx.query.getAll("email")
    println("id = ${id}, name=${name}, phone=${phone}, email = ${email}")

    let user = User()
    user.age = 28
    user.name = name
    user.email = email.get(0).getOrDefault({=> "cangjie@gmail.com"})
    user.phone = phone
    ctx.json(user)
}

func userAdd(ctx: BaseHttpContext): Unit {
    println("user add")
    let phone = ctx.form.get("phone").getOrDefault({=> ""})
    let password = ctx.form.get("password").getOrDefault({=> ""})
    let email = ctx.form.getAll("email")
    let name = ctx.form.get("name").getOrDefault({=> ""})
    println("name=${name}, password = ${password} phone=${phone}, email = ${email};${ctx.query.get("a")}")

    ctx.text("user add")
}

main() {
    // 1. 构建 Server 实例
    // let server = ServerBuilder().addr("127.0.0.1").port(8070)
    //     // .distributor(NaiveDistributor())
    //     .build()
    // // 2. 注册 HttpRequestHandler
    // let str = "Hello 仓颉!"
    // server.distributor.register("/", {httpContext => httpContext.responseBuilder.body(str)})
    // println("server started! http://127.0.0.1:8070")
    // // 3. 启动服务
    // server.serve()

    let engine = Engine(8070)
    let user = engine.addRouterGroup("user")
    user.use(GroupMiddlewareFunc1, GroupMiddlewareFunc2)
    user.get("/list", userList, RouterMiddlewareFunc1, RouterMiddlewareFunc2)
    user.post("/add", userAdd)
    user.get("/get", userGet)
    user.get("/info", userInfo)

    engine.run()
}
