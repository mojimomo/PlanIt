//
//  Project.swift
//  PlanIt
//
//  Created by Ken on 16/4/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//项目类别
struct ProjectType {
    //未设置
    static let NoSet = -1
    //正常类型
    static let Normal = 0
    //不记录类型
    static let NoRecord = 1
    //签到类型
    static let Punch = 2
}

//项目是否完成
struct ProjectIsFinished {
    //未设置
    static let NoSet = -1
    //未完成
    static let NotFinished = 0
    //已完成
    static let Finished = 1
    //未开始
    static let NotBegined = 2
}

//项目model
class Project: NSObject {
    //项目编号
    var id: Int = -1
    //项目名称
    var name = ""
    //项目类型
    var type: Int = ProjectType.NoRecord
    //项目开始时间
    var beginTime = ""{
        didSet{
            if beginTime != ""{
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                beginTimeDate = dateFormat.dateFromString(beginTime)!
            }
        }
    }
    
    //项目结束时间
    var endTime = ""{
        didSet{
            if endTime != ""{
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                endTimeDate = dateFormat.dateFromString(endTime)!
            }
        }
    }

    //任务单位
    var unit = ""
    //任务总量
    var total: Double = 0.0
    //是否完成
    var isFinished: Int = ProjectIsFinished.NoSet
    //完成量
    var complete: Double = 0.0
    //剩余量
    var rest: Double = 0.0
    //标签
    //var tags = [Tag]()
    //备注
    //var remark: String?
    private var beginTimeDate = NSDate()
    private var endTimeDate = NSDate()
    
    override init() {
        super.init()
    }
    
    init(dict : [String : AnyObject]) {
        super.init()        
        //setValuesForKeysWithDictionary(dict)
        id = dict["id"]!.integerValue
        name = String(dict["name"])
        type = dict["type"]!.integerValue
        beginTime = String(dict["beginTime"])
        endTime = String(dict["endTime"])
        unit = String(dict["unit"])
        total = dict["total"]!.doubleValue
        isFinished = dict["isFinished"]!.integerValue
        complete = dict["complete"]!.doubleValue
        rest = dict["rest"]!.doubleValue
    }

    // MARK:- 数据操作
    //新建项目设置总量
    func setNewProjectTotal(total: Double){
        self.total = total
        self.complete = 0
        self.rest = total
    }
    
    //新建项目设置时间
    func setNewProjectTime(beginTime: String, endTime: String) -> Bool{
        if beginTime != "" && endTime != ""
        {
            self.beginTime = beginTime
            self.endTime = endTime
            let nowTimeDate = NSDate()
            //初始化项目状态
            self.isFinished = ProjectIsFinished.NoSet
            //开始时间<结束时间
            if beginTimeDate.compare(endTimeDate) == NSComparisonResult.OrderedAscending{
                //开始时间>现在时间
                if beginTimeDate.compare(nowTimeDate) == NSComparisonResult.OrderedDescending{
                    self.isFinished = ProjectIsFinished.NotBegined
                    //结束时间<现在时间
                }else if endTimeDate.compare(nowTimeDate) == NSComparisonResult.OrderedAscending{
                    self.isFinished = ProjectIsFinished.Finished
                    //结束时间>现在时间
                }else if endTimeDate.compare(nowTimeDate) == NSComparisonResult.OrderedDescending{
                    self.isFinished = ProjectIsFinished.NotFinished
                }
            }
        }
        if self.isFinished != ProjectIsFinished.NoSet{
            return true
        }else{
            return false
        }
    }
    
    //判断project数据是否有缺漏
    func check() -> Bool {
        //判断项目前面3个属性是否为空
        if  name != "" &&  beginTime !=  "" && endTime != "" {
            if type == ProjectType.Normal ||  type == ProjectType.Punch {
                if unit != "" && total != 0 && isFinished != ProjectIsFinished.NoSet
                    && complete != 0 && rest != 0{
                    return true
                }
            }else if type == ProjectType.NoRecord{
               return true
            }
        }
        return false
    }
 
    // MARK:- 和数据库之间的操作
    /// 加载所有的数据
    func loadAllData() -> [Project]{
        var projects : [Project] = [Project]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_project;"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return projects
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Project(dict: dict)
            projects.append(p)
        }
        return projects
    }


    func insertProject() -> Bool{
        // 1.获取插入的SQL语句
        let insertSQL = "INSERT INTO t_project (name, type, beginTime, endTime, unit, total, isFinished, complete, rest) VALUES ('\(name)', '\(type)', '\(beginTime)', '\(endTime)', '\(unit)', '\(total)', '\(isFinished)', '\(complete)', '\(rest)');"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(insertSQL) {
            print("插入新项目成功")
            return true
        }else{
            print("插入新项目失败")
            return false
        }
    }
    
    func updateProject() -> Bool{
        // 1.获取修改的SQL语句
        let updateSQL = "UPDATE t_project SET name = '\(name)', type = '\(type)', beginTime = '\(beginTime)', endTime = '\(endTime)', unit = '\(unit)', total = '\(total)', isFinished ='\(isFinished)', complete = '\(complete)', rest = '\(rest)'WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(updateSQL) {
            print("修改项目成功")
            return true
        }else{
            print("修改项目失败")
            return false
        }
    }

    func deleteProject() -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_project WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除项目成功")
            return true
        }else{
            print("删除项目失败")
            return false
        }
    }
 }

