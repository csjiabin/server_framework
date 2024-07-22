package server_framework.server

import net.http.HttpContext
import serialization.serialization.Serializable
import encoding.json.ToJson
import encoding.url.Form
import std.io.InputStream

public class BaseHttpContext {
    private let context: HttpContext

    private let queryForm: Form
    private let formContent: Form
    private let bodyForm: InputStream

    public BaseHttpContext(context: HttpContext) {
        this.context = context
        this.queryForm = context.request.url.queryForm
        this.formContent = context.request.form
        this.bodyForm = context.request.body
    }

    public func status(status: UInt16) {
        this.context.responseBuilder.status(status)
        return this
    }

    public func header(name: String, value: String) {
        this.context.responseBuilder.header(name, value)
        return this
    }

    public func html(content: String) {
        this.header("content-type", "text/html; charset=utf-8")
        this.context.responseBuilder.body(content)
    }

    public func text(content: String) {
        this.context.responseBuilder.body(content)
    }

    public func json<T>(data: T) where T <: Serializable<T> {
        this.header("content-type", "text/json; charset=utf-8")
        this.context.responseBuilder.body(data.serialize().toJson().asObject().toJsonString())
        return this
    }

    public mut prop httpContext: HttpContext {
        get() {
            return this.context
        }
        set(value) {
            println("set query ${value.request.url.path}")
        }
    }

    public mut prop query: Form {
        get() {
            return this.queryForm
        }
        set(value) {
            println("set query ${value.toEncodeString()}")
        }
    }

    /** 
     * 获取请求中的表单信息
     * 如果请求方法为 POST，PUT，PATCH，且 content-type 包含 application/x-www-form-urlencoded，获取请求 body 部分，用 form 格式解析
     * 如果请求方法不为 POST，PUT，PATCH，获取请求 url 中 query 部分 注意
     * 如果用该接口读取了 body，body 已被消费完，后续将无法通过 body.read 读取 body
     * 如果 form 不符合 Form 格式，抛 UrlSyntaxException 异常
     */
    public mut prop form: Form {
        get() {
            return this.formContent
        }
        set(value) {
            println("set query ${value.toEncodeString()}")
        }
    }
}
