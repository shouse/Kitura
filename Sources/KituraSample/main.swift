/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// KituraSample shows examples for creating custom routes.

import sys
import net
import router

import LoggerAPI
import HeliumLogger

#if os(Linux)
    import Glibc
#endif

import Foundation

// All Web apps need a router to define routes
let router = Router()

// Using an implementation for a Logger
Log.logger = HeliumLogger()

/** 
* RouterMiddleware can be used for intercepting requests and handling custom behavior
* such as authentication and other routing
*/
class EchoTest: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        for  (key, value) in request.headers {
            print("EchoTest. key=\(key). value=\(value).")
        }
    }
}


// This route executes the echo middleware
router.use("/*", middleware: EchoTest())

router.get("/hello") { _, response, next in
     response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
     do {
         try response.status(HttpStatusCode.OK).send("Hello World!").end()
     }
     catch {}
     next()
}

router.post("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a POST request").end()
    }
    catch {}
    next()
}

router.put("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a PUT request").end()
    }
    catch {}
    next()
}

router.delete("/") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a DELETE request").end()
    }
    catch {}
    next()
}

// Handing errors
router.get("/error") { _, response, next in
    response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [:])
    next()
}

// Handling redirects
router.get("/redir") { _, response, next in
    do {
        try response.redirect("http://www.ibm.com")
    }
    catch {}
    
    next()
}

// Reading parameters
router.get("/users/:user") { request, response, next in
    response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    let p1 = request.params["user"] ?? "(nil)"
    do {
        try response.status(HttpStatusCode.OK).send(
            "<!DOCTYPE html><html><body>" +
            "<b>User:</b> \(p1)" +
            "</body></html>\n\n").end()
    }
    catch {}
    next()
}


let server = HttpServer.listen(8090,
    delegate: router)
        
Server.run()

