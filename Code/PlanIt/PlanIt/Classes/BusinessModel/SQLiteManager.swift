//
//  SQLiteManager.swift
//  PlanIt
//
//  Created by Ken on 16/5/15.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class SQLiteManager: NSObject {
    // let修饰常量是线程安全
    static let shareIntance : SQLiteManager = SQLiteManager()
    
    /// 数据库句柄
    var db : COpaquePointer = nil
    
    /// 提供一个函数,让别人可以打开一个数据库
    func openDB(dbName : String) {
        // 1.获取数据库文件存放的路径
        guard var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else {
            print("没有获取到路径")
            return
        }
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        print(path)
        
        // 2.打开数据库:如果有数据库则打开,如果没有则创建
        // 参数三:数据库句柄(类似于游戏手柄).
        // COpaquePointer : Swift中是没有指针,但是在Swift和OC/C开发过程中使用指针再所难免
        SQLITE_OK
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("打开或者创建数据库失败")
            return
        }
        
        // 3.创建表
        createTable()
    }
    
    
    /// 创建一张表
    func createTable() {
        // 1.获取创建表的SQL语句
        let createTableSQL = "CREATE TABLE IF NOT EXISTS t_person ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "name TEXT, \n" +
            "age INTEGER\n" +
        ");"
        
        // 2.执行SQL语句
        if execSQL(createTableSQL) {
            print("创建表成功")
        }
    }
    
    /// 执行SQL语句(创建表/添加/删除/修改)
    func execSQL(sqlString : String) -> Bool {
        // 1.参数一:数据库句柄
        // 2.参数二:sql语句
        // 3.参数三:执行完语句会回调的闭包,一般传nil即可
        // 4.参数四:和参数三相关的一个参数.一般传nil科技
        // 5.参数五:错误信息.
        return sqlite3_exec(db, sqlString, nil, nil, nil) == SQLITE_OK
    }
    
    
    /// 执行查询操作(将查询到的结果返回到一个字典数组中)
    func querySQL(querySQL : String) -> [[String : AnyObject]]? {
        
        // 1.定义游标指针
        var stmt : COpaquePointer = nil
        
        // 2.查询的准备工作(给stmt赋值)
        // 1.参数一:数据库句柄
        // 2.参数二:查询语句
        // 3.参数三:查询语句的长度. -1是自动计算
        // 4.参数四:数据库`游标`对象
        if sqlite3_prepare_v2(db, querySQL, -1, &stmt, nil) != SQLITE_OK {
            print("没有准备好查询")
            return nil
        }
        
        // 3.查看是否有下一条语句
        var dictArray = [[String : AnyObject]]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            // 有下一条语句,则将该语句转成字典,放入数组中
            dictArray.append(getRecord(stmt))
        }
        
        return dictArray
    }
    
    /// 根据'游标指针'获取一条数据
    func getRecord(stmt : COpaquePointer) -> [String : AnyObject] {
        // 1.获取字段个数
        let count = sqlite3_column_count(stmt)
        var dict = [String : AnyObject]()
        for i in 0..<count {
            // 2.取出字典对应的key
            let cKey = sqlite3_column_name(stmt, i)
            guard let key = String(CString: cKey, encoding: NSUTF8StringEncoding) else {
                continue
            }
            
            // 3.取出字典对应的value
            let cValue = UnsafePointer<Int8>(sqlite3_column_text(stmt, i))
            guard let value = String(CString: cValue, encoding: NSUTF8StringEncoding) else {
                continue
            }
            
            // 4.将键值放入字典中
            dict[key] = value
        }
        
        return dict
    }
}