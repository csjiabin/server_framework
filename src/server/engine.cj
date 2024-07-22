package server_framework.server

import net.http.{Server, ServerBuilder, HttpContext, FuncHandler, HttpStatusCode}

public type HandlerFunc = (BaseHttpContext) -> Unit

public class Engine {
    let port: Int64
    let addr: String
    let router: Router
    let server: Server

    public Engine(port: Int64, addr!: String = "0.0.0.0") {
        this.port = port
        this.addr = addr
        println("server options: ${this.addr}:${this.port}")
        this.router = Router()
        this.server = ServerBuilder().addr(this.addr).port(UInt16(this.port)).distributor(BaseDistrubutor()).build()
    }

    // 添加路由
    public func addRouterGroup(name: String) {
        return this.router.addRouterGroup(name)
    }

    // 启动服务
    public func run() {
        // for (routerGroup in this.router.getRouterGroups()) {
        //     let prefixPath = routerGroup.getName()
        //     for ((routerPath, handle) in routerGroup.getRoutes()) {
        //         var realPath = prefixPath + routerPath
        //         realPath = realPath.replace("//", "/")
        //         println("register path: " + realPath)
        //         this.server.distributor.register(realPath, handle)
        //     }
        // }
        this.server.distributor.register("/", handler)

        println("server running! http://${this.addr}:${this.port}")
        if (this.addr == "0.0.0.0") {
            println("server running! http://127.0.0.1:${this.port}")
        }
        this.server.serve()
    }

    func handler(ctx: HttpContext) {
        let requestMethod = ctx.request.method
        let requestPath = ctx.request.url.path
        println("[${requestMethod}]: ${requestPath}")
        // 校验对应路由的请求方法
        for (routerGroup in this.router.getRouterGroups()) {
            let prefixPath = routerGroup.getName()
            if (!requestPath.startsWith(prefixPath)) {
                continue
            }
            // routerGroup 的 router 变量
            let routerPath = requestPath[prefixPath.size..]
            let result = routerGroup.treeNode.get(routerPath)

            let routes = routerGroup.getRoutes()
            match (result) {
                case Some(treeNode) =>
                    // 匹配一下请求方式
                    if (routes[treeNode.fullPath].contains(requestMethod)) {
                    // 请求方式匹配
                    let handler = routes[treeNode.fullPath][requestMethod]
                    // return routerGroup.invokeHandler(treeNode.fullPath, requestMethod, handler, BaseHttpContext(ctx))
                    //  return handler.handle(ctx)
                    return FuncHandler(
                        {
                            httpContext =>
                            let baseHttpContext = BaseHttpContext(httpContext)
                            routerGroup.invokeHandler(treeNode.fullPath, requestMethod, handler, baseHttpContext)
                        }
                    ).handle(ctx)
                } else {
                    // 请求方式不匹配
                    return FuncHandler(
                        {
                            httpContext =>
                            let baseHttpContext = BaseHttpContext(httpContext)
                            baseHttpContext.header("content-type", "text/*; charset=utf-8").status(
                                HttpStatusCode.STATUS_METHOD_NOT_ALLOWED).text("请求方式不支持")
                        }
                    ).handle(ctx)
                }

                case None => println("[${requestMethod}]: ${requestPath} not found")
            }
        }
        return FuncHandler(
            {
                httpContext =>
                let baseHttpContext = BaseHttpContext(httpContext)

                baseHttpContext.header("content-type", "text/*; charset=utf-8").status(HttpStatusCode.STATUS_NOT_FOUND).
                    text("请求方法不存在")
            }
        ).handle(ctx)
    }
}
