//
//  File.swift
//  MyAwesomeProject
//
//  Created by 孔凡伍 on 2016/12/16.
//
//

import Foundation
import SQLite

public class FWDBManager {
    let dbPath = "./DataBase/db"
    
    init() {
        createDB()
    }
    
    static let shareManager = FWDBManager()
    
    func createDB() {
        var sqlite: SQLite
        do {
            sqlite = try SQLite(dbPath)
            defer {
                sqlite.close() // 此处确定我们关闭了数据库连接
            }

            try sqlite.execute(statement: "CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY NOT NULL, user TEXT NOT NULL, pwd TEXT NOT NULL, name TEXT NOT NULL)")
            
        } catch {
            print("数据库打开失败")
        }
    }
    
    /// 保存用户信息
    ///
    /// - Parameter sql: sq语句
    /// - Returns: 状态
    func saveUserInfo(sql: String) -> Bool {
        do {
            let sqlite = try SQLite(dbPath)
            defer {
                sqlite.close()
            }
            
            try sqlite.execute(statement: sql)
        } catch {
            return false
        }
        return true
    }
    
    
    /// 查询用户用户是否存在
    ///
    /// - Parameters:
    ///   - sql: 查询语句
    ///   - userName: 查询用户名
    /// - Returns: true 存在
    func searchUser(sql: String, userName: String) -> Bool {
        var bl = false
        do {
            let sqlite = try SQLite(dbPath)
            defer {
                sqlite.close()
            }
            
            try sqlite.forEachRow(statement: sql) {(statement: SQLiteStmt, i:Int) -> () in
                let user = statement.columnText(position: 0)
                if userName == user {
                    bl = true
                    return
                }
            }
        } catch {
            bl = false
        }
        return bl;
    }
}
