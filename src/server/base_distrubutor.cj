package server_framework.server

import net.http.{HttpRequestDistributor, HttpRequestHandler, FuncHandler}

public class BaseDistrubutor <: HttpRequestDistributor {
    private var handler: HttpRequestHandler

    BaseDistrubutor() {
        this.handler = FuncHandler({httpContext =>})
    }

    public func register(path: String, handler: HttpRequestHandler): Unit {
        this.handler = handler
    }

    public func distribute(path: String): HttpRequestHandler {
        return this.handler
    }
}
