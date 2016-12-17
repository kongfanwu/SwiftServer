import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger

struct Filter404: HTTPResponseFilter {
    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if case .notFound = response.status {
            response.setBody(string: "文件 \(response.request.path) 不存在。")
            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
            callback(.done)
        } else {
            callback(.continue)
        }
    }
}

public class main {
    let server = HTTPServer()
    
    init() {
        // 监听8181端口
        server.serverPort = 8181
        // 设置文档根目录
        // 这是可选的。
        // 如果不希望提供静态内容就不需要设置。
        // 设置文档根目录后，
        // 系统会自动为路由增加一个静态文件处理句柄
        // 实际目录 /Users/kongfanwu/Library/Developer/Xcode/DerivedData/MyAwesomeProject-ecefspusbltlfedfpqvrptxqtgui/Build/Products/Debug/files
        server.documentRoot = "./webroot"
        
        // 添加相应404过滤
        let responseFilters404: [(HTTPResponseFilter, HTTPFilterPriority)] = [(Filter404(), .high)]
        server.setResponseFilters(responseFilters404)
        
        // 初始化一个日志记录器
        let myLogger = RequestLogger()
        // 增加过滤器
        // 首先增加高优先级的过滤器
        server.setRequestFilters([(myLogger, .high)])
        // 最后增加低优先级的过滤器
        server.setResponseFilters([(myLogger, .low)])

        // 添加路由
        _ = FWRoutes(server: server)
        
        do {
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络出现错误：\(err) \(msg)")
        } catch {} //加入一个空的catch，用于关闭catch。否则会报错：Errors thrown from here are not handled because the enclosing catch is not exhaustive
    }
}

_ = main()

