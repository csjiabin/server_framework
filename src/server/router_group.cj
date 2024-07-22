package server_framework.server

import net.http.{HttpRequestHandler, HttpContext}
import std.collection.{HashMap, ArrayList}

public enum Method {
    GET
    | POST
    | PUT
    | DELETE
    | PATCH
    | HEAD
    | OPTIONS
}

type MiddlewaresFunc = (HandlerFunc) -> HandlerFunc

type RequestFunc = (name: String, handler: HttpRequestHandler, middlewares: ArrayList<MiddlewaresFunc>) -> Unit

public class RouterGroup {
    private let name: String

    // key路由请求路径，value路由请求处理函数
    // private let routes: HashMap<String, HttpRequestHandler>
    //                           路由请求路径     请求方式； 请求处理函数
    private let routes: HashMap<String, HashMap<String, HandlerFunc>>

    let treeNode: TreeNode

    // 针对路由分组
    let middlewares: ArrayList<MiddlewaresFunc>

    // 针对某个路由的                       routerPath      request method       
    let handlerMethodMiddlewares: HashMap<String, HashMap<String, ArrayList<MiddlewaresFunc>>>

    public RouterGroup(name: String) {
        var path = name;
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        this.name = path
        this.routes = HashMap<String, HashMap<String, HandlerFunc>>()
        this.treeNode = TreeNode("/", "")
        this.middlewares = ArrayList<MiddlewaresFunc>()
        this.handlerMethodMiddlewares = HashMap<String, HashMap<String, ArrayList<MiddlewaresFunc>>>()
    }

    public func use(middlewares: Array<MiddlewaresFunc>) {
        this.middlewares.appendAll(middlewares)
    }

    public func get(name: String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRoute(name, "GET", handler, middlewares)
    }

    public func post(name: String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRoute(name, "POST", handler, middlewares)
    }

    public func delete(name: String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRoute(name, "DELETE", handler, middlewares)
    }

    public func put(name: String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        addRoute(name, "PUT", handler, middlewares)
    }

    private func addRoute(name: String, method: String, handler: HandlerFunc, middlewares: Array<MiddlewaresFunc>) {
        var path = name;
        if (!name.startsWith("/")) {
            path = "/" + path
        }
        if (!this.routes.contains(path)) {
            this.routes[path] = HashMap<String, HandlerFunc>()
            this.handlerMethodMiddlewares[path] = HashMap<String, ArrayList<MiddlewaresFunc>>()
        }
        if (!this.routes[path].contains(method)) {
            println("路由${this.name}${path} method = ${method} 已经注册过了")
        }

        this.routes[path].put(method, handler)

        if (!this.handlerMethodMiddlewares[path].contains(method)) {
            this.handlerMethodMiddlewares[path].put(method, ArrayList<MiddlewaresFunc>())
        }

        // 给TreeNode添加数据
        this.treeNode.put(path)
        this.handlerMethodMiddlewares[path][method].appendAll(middlewares)
    }

    public func invokeHandler(routerPath: String, method: String, handler: HandlerFunc, ctx: BaseHttpContext) {
        var newHandler = handler
        for (middleware in this.middlewares) {
            newHandler = middleware(newHandler)
        }
        if (this.handlerMethodMiddlewares.contains(routerPath) && this.handlerMethodMiddlewares[routerPath].contains(
            method)) {
            let handlerMiddlewares = this.handlerMethodMiddlewares[routerPath][method]
            for (middleware in handlerMiddlewares) {
                newHandler = middleware(newHandler)
            }
        }
        newHandler(ctx)
    }

    public func getName() {
        return this.name
    }

    // 获取所有路由
    func getRoutes() {
        return this.routes
    }
}
