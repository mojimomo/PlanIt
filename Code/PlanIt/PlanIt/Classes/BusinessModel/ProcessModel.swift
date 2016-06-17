//
//  ProcessModel.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//ProcessModel
class Process: NSObject {
    ///进度序号
    var id: Int = -1
    ///项目序号
    var projectID: Int = -1
    ///记录时间
    var recordTime = ""{
        didSet{
            if recordTime != ""{
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                recordTimeDate = dateFormat.dateFromString(recordTime)!
            }
        }
    }
    ///完成工作量
    var done: Double = -1
    ///记录时间
    var recordTimeDate = NSDate()
    ///备注
    var remark = ""
    
    override init() {
        super.init()
    }
    
    init(dict : [String : AnyObject]) {
        super.init()
        //setValuesForKeysWithDictionary(dict)
        id = dict["id"]!.integerValue
        recordTime = String(dict["recordTime"]!)
        projectID = dict["projectID"]!.integerValue
        done = dict["done"]!.doubleValue
        remark = String(dict["remark"]!)
    }
    
    // MARK:- 和数据库之间的操作
    /// 加载所有的数据
    func loadAllData() -> [Process]{
        var processes : [Process] = [Process]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_process;"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return processes
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Process(dict: dict)
            processes.append(p)
        }
        return processes
    }
    
    /// 加载关于某项目所有的数据
    func loadData(projectID: Int) -> [Process]{
        var processes : [Process] = [Process]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_process WHERE projectID = '\(projectID)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return processes
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Process(dict: dict)
            processes.append(p)
        }
        return processes
    }
    
    ///添加新的进程
    func insertProcess() -> Bool{
        // 1.获取插入的SQL语句
        let insertSQL = "INSERT INTO t_process (projectID, recordTime, done, remark) VALUES ('\(projectID)', '\(recordTime)', '\(done)', '\(remark)');"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(insertSQL) {
            print("插入新进程成功")
            return true
        }else{
            print("插入新进程失败")
            return false
        }
    }
    
    ///删除此进程
    func deleteProcess() -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_process WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除进程成功")
            return true
        }else{
            print("删除进程失败")
            return false
        }
    }
}