package server_framework.server

import net.http.HttpRequestHandler
import std.collection.{HashMap, ArrayList}

public class Router {
    private let routerGroups: ArrayList<RouterGroup>

    public Router() {
        this.routerGroups = ArrayList<RouterGroup>()
    }

    // 添加路由
    public func addRouterGroup(name: String) {
        let routerGroup = RouterGroup(name);
        this.routerGroups.append(routerGroup)
        return routerGroup
    }

    // 获取所有路由
    func getRouterGroups() {
        return this.routerGroups
    }
}
