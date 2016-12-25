//
//  xuexi.swift
//  MyAwesomeProject
//
//  Created by 孔凡伍 on 2016/12/15.
//
//
#if os(Linux)
import LinuxBridge
#else
import Darwin
#endif
import Darwin
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

public class FWRoutes {
    let server: HTTPServer!

    init(server: HTTPServer) {
        self.server = server

        _ = FWDBManager.shareManager

        addFoutes()


    }

    func addFoutes() {
        // 注册您自己的路由和请求／响应句柄
        var routes = Routes()
        defer {
            // 将路由注册到服务器上
            server.addRoutes(routes)
        }

        // 添加文件路由，虚拟目录 /files/**。真实目录 ./Files
        routes.add(method: .get, uri: "/files/**", handler: {
            request, response in

            // 获得符合通配符的请求路径
            request.path = request.urlVariables[routeTrailingWildcardKey]!

            // 用文档根目录初始化静态文件句柄
            let handler = StaticFileHandler(documentRoot: "./Files")

            // 用我们的根目录和路径
            // 修改集触发请求的句柄
            handler.handleRequest(request: request, response: response)
        })

        // 注册
        routes.add(uri: "/register", handler: { request, response in
            var state: Bool = false
            var msg: String = "失败"

            defer {
                do {
                    try response.setBody(json: ["state" : state, "msg" : msg])
                } catch {}
                response.setHeader(.contentType, value: "text/html")
                response.completed()
            }

            guard let user = request.param(name: "user") else { msg = "没user字段"; return }
            guard let pwd = request.param(name: "pwd") else { msg = "没pwd字段"; return }
            guard let name = request.param(name: "name") else { msg = "没name字段"; return }

            let searchSql = "SELECT user FROM Users"
            if FWDBManager.shareManager.searchUser(sql: searchSql, userName: user) == true {
                msg = "用户存在"
            } else {
                let sql = "INSERT INTO Users (user, pwd, name) VALUES ('\(user)', '\(pwd)', '\(name)');"
                if FWDBManager.shareManager.saveUserInfo(sql: sql) == true {
                    state = true
                    msg = "成功"
                }
            }
        })

        // 上传
        routes.add(method: .post, uri: "/upload", handler:  { request, response in
            var state: Bool = false
            var msg: String = "失败"

            defer {
                do {
                    try response.setBody(json: ["state" : state, "msg" : msg])
                } catch {}
                response.setHeader(.contentType, value: "text/html")
                response.completed()
            }

            let files = self.uploadFailes(postFileUploads: request.postFileUploads)
            if files.count > 0 {
                state = true
                msg = "成功"
            }
        })
    }

    /// 处理上传来的文件，并移动至目标路径
    ///
    /// - Parameter postFileUploads: 上传文件数组
    /// - Returns: 整理数组
    func uploadFailes(postFileUploads: [MimeReader.BodySpec]?) -> [String: Any]{
        // 创建路径用于存储已上传文件
        let fileDir = Dir(Dir.workingDir.path + "Files")
        do {
            try fileDir.create()
        } catch {
            print(error)
        }

        // 通过操作fileUploads数组来掌握文件上传的情况
        // 如果这个POST请求不是分段multi-part类型，则该数组内容为空
        var files = [String: Any]()
        if let uploads = postFileUploads, uploads.count > 0 {
            // 创建一个字典数组用于检查已经上载的内容
            var ary = [[String:Any]]()

            for upload in uploads {
                ary.append([
                    "fieldName": upload.fieldName,  //字段名
                    "contentType": upload.contentType, //文件内容类型
                    "fileName": upload.fileName,    //文件名
                    "fileSize": upload.fileSize,    //文件尺寸
                    "tmpFileName": upload.tmpFileName   //上载后的临时文件名
                    ])

                let thisFile = File(upload.tmpFileName)
                do {
                    let stamp = time(nil)
                    let _ = try thisFile.moveTo(path: fileDir.path + "\(stamp)" + upload.fileName, overWrite: true)
                } catch {
                    print(error)
                }
            }
            files["files"] = ary
        }
        return files
    }









}
