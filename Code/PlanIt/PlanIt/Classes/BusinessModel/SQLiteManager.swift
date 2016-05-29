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
    let dbName = "db.sqlite3"
    
    /// 数据库句柄
    var db : COpaquePointer = nil
    
    override init() {
        super.init()
        openDB(dbName)
    }
    
    /// 提供一个函数,让别人可以打开一个数据库
    func openDB(dbName : String) {
        // 1.获取数据库文件存放的路径
        guard var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else {
            print("没有获取到路径")
            return
        }
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        print("数据库路径: \(path)")
        
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
        //创建t_project表格
        // 获取创建表的SQL语句
        let createProjectTableSQL = "CREATE TABLE IF NOT EXISTS t_project ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT NOT NULL, \n" +
            "name TEXT NOT NULL, \n" +
            "type INTEGER NOT NULL, \n" +
            "beginTime TEXT  NOT NULL, \n" +
            "endTime  TEXT  NOT NULL, \n" +
            "unit TEXT, \n" +
            "total DOUBLE, \n" +
            "complete DOUBLE, \n" +
            "rest DOUBLE \n" +
        ");"
        // 执行SQL语句
        if execSQL(createProjectTableSQL) {
            print("创建t_project表成功")
        }
        
        //创建t_process表格
        // 获取创建表的SQL语句
        let createProcessTableSQL = "CREATE TABLE IF NOT EXISTS t_process ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT NOT NULL, \n" +
            "recordTime TEXT NOT NULL, \n" +
            "projectID INTEGER NOT NULL, \n" +
            "done double\n" +
            "remark TEXT, \n" +
        ");"
        // 执行SQL语句
        if execSQL(createProcessTableSQL) {
            print("创建t_process表成功")
        }

        //创建t_processdate表格
        // 获取创建表的SQL语句
        let createProcessDateTableSQL = "CREATE TABLE IF NOT EXISTS t_processdate ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT NOT NULL, \n" +
            "recordTime TEXT NOT NULL, \n" +
            "projectID INTEGER NOT NULL, \n" +
            "done double\n" +
        ");"
        // 执行SQL语句
        if execSQL(createProcessDateTableSQL) {
            print("创建t_processdate表成功")
        }
        
        //创建t_tag表格
        // 获取创建表的SQL语句
        let createTagTableSQL = "CREATE TABLE IF NOT EXISTS t_tag ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT NOT NULL, \n" +
            "name TEXT NOT NULL \n" +
        ");"
        // 执行SQL语句
        if execSQL(createTagTableSQL) {
            print("创建t_tag表成功")
        }
        
        //创建t_tag表格
        // 获取创建表的SQL语句
        let createTagMapTableSQL = "CREATE TABLE IF NOT EXISTS t_tagmap ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT NOT NULL, \n" +
            "projectID INTEGER NOT NULL, \n" +
            "tagID INTEGER NOT NULL \n" +
        ");"
        // 执行SQL语句
        if execSQL(createTagMapTableSQL) {
            print("创建t_tagmap表成功")
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