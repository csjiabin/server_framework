package server_framework.server

// from std import reflect.{TypeInfo}

@Annotation
public class RouteGroup {
    let name: String
    const init(name: String) {
        this.name = name
    }
}

@Annotation[target: [MemberFunction]]
public class Route {
    let path: String
    let method: Method
    const init(path: String, method!: Method = Method.GET) {
        this.path = path
        this.method = method
    }
}

@RouteGroup["/api"]
public class UserController {
    // @Route["/user", method: Method . POST]
    UserController() {
        println("UserController")
    }



    // func getUser() {
    //     println("User 仓颉!")
    //     // let annOpt = TypeInfo.of(this).findAnnotation("server.RouteGroup")
    //     // if (let Some(ann) <- annOpt) {
    //     //     if (let Some(version) <- ann as RouteGroup) {
    //     //         println(version.code)
    //     //     }
    //     // }
    //     let ti = TypeInfo.of(this)
    //     let annotation = ti.findAnnotation<RouteGroup>().getOrThrow()
    //     match (annotation) {
    //         case annotation => println(annotation.name)
    //         case _ => println("annotation not found")
    //     }
    // }
}
