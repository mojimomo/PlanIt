//
//  Project.swift
//  PlanIt
//
//  Created by Ken on 16/4/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation
import UIKit

///项目类别
enum ProjectType: Int{
    ///未设置
    case NoSet = -1
    ///正常类型
    case Normal = 0
    ///不记录类型
    case NoRecord = 1
    ///签到类型
    case Punch = 2
}

///项目是否完成
enum ProjectIsFinished: Int{
    ///未设置
    case  NoSet = -1
    ///未完成
    case  NotFinished = 0
    ///已完成
    case Finished = 1
    ///未开始
    case NotBegined = 2
    ///超时
    case OverTime = 3
}

///项目model
class Project: NSObject {
    ///项目编号
    var id: Int = -1
    ///项目名称
    var name = ""
    ///项目类型
    var type: ProjectType = .NoRecord
    ///项目结束时间
    var endTime = ""{
        didSet{
            if endTime != ""{
                endTimeDate = endTime.FormatToNSDateYYYYMMMMDD()!.increase1Day()!
            }
        }
    }
    ///项目开始时间
    var beginTime = ""{
        didSet{
            if beginTime != ""{
                beginTimeDate = beginTime.FormatToNSDateYYYYMMMMDD()!
            }
        }
    }
 
    ///距离结束时间 越大超时越久
    var outTime = 0.0
    ///任务单位
    var unit = ""
    ///任务总量
    var total: Double = 0.0
    ///是否完成
    var isFinished: ProjectIsFinished = .NoSet
    ///完成量
    var complete: Double = 0.0
    ///剩余量
    var rest: Double = 0.0
    ///标签
    var tags = [Tag]()
    ///标签字符串
    var tagString = ""
    ///百分比 0 - 100
    var percent = 0.0
    ///备注
    //var remark: String?
    var beginTimeDate = NSDate()
    var endTimeDate = NSDate()
    //几天后推送
    var day : Int{
        get{
            if NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int! == 0{
                NSUserDefaults.standardUserDefaults().setInteger( 3 , forKey: "daysLocalNotifiication")
            }
            return NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int
        }
        set{
            NSUserDefaults.standardUserDefaults().setInteger( newValue , forKey: "daysLocalNotifiication")
        }
    }
    //几条推送
    var numNotife : Int{
        get{
            if NSUserDefaults.standardUserDefaults().integerForKey("numsLocalNotifiication") as Int! == 0{
                NSUserDefaults.standardUserDefaults().setInteger( 0 , forKey: "numsLocalNotifiication")
            }
            return NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int
        }
        set{
            NSUserDefaults.standardUserDefaults().setInteger( newValue , forKey: "numsLocalNotifiication")
        }
    }
    
    override init() {
        super.init()
    }
    
    init(dict : [String : AnyObject]) {
        super.init()        
        //setValuesForKeysWithDictionary(dict)
        id = dict["id"]!.integerValue
        name = String(dict["name"]!)
        type = ProjectType(rawValue: dict["type"]!.integerValue)!
        beginTime = String(dict["beginTime"]!)
        endTime = String(dict["endTime"]!)
        unit = String(dict["unit"]!)
        total = dict["total"]!.doubleValue
        complete = dict["complete"]!.doubleValue
        rest = dict["rest"]!.doubleValue
        
        //刷新tag
        freshenTags()
        
        //计算是否完成
        setNewProjectTime(beginTime, endTime: endTime)
        
        //计算百分比
        if type != .NoRecord{
            if total != 0{
                percent = complete * 100 / total
            }
        }else{
//            if isFinished == .OverTime || isFinished == .Finished{
//                percent = 100
//            }else if isFinished == .NotBegined {
//                percent = 0
//            }else{
//                let timeEnd = endTimeDate.timeIntervalSince1970
//                let timeBegin = beginTimeDate.timeIntervalSince1970
//                let currentDate = NSDate()
//                let timecurrent = currentDate.timeIntervalSince1970
//                percent = (timecurrent - timeBegin)/(timeEnd - timeBegin)
//            }
        }
        
        if isFinished == .Finished{
            percent = 0
        }

        //计算到结束的时间时间
        let timeNow = NSDate().timeIntervalSince1970
        let timeEnd = endTimeDate.timeIntervalSince1970
        outTime = timeNow - timeEnd

    }

    // MARK:- 数据操作
    ///新增推送
    func addNotification() {
        if isFinished == .Finished{
            return
        }

        // 初始化一个通知
        let localNoti = UILocalNotification()
        // 通知的触发时间
        let fireDate = endTimeDate.dateByAddingTimeInterval(-Double(day)*24*60*60)
        //let fireDate = NSDate().dateByAddingTimeInterval(30)
        localNoti.fireDate = fireDate
        // 设置时区
        localNoti.timeZone = NSTimeZone.defaultTimeZone()
        // 通知上显示的主题内容
        if day == 1 {
            localNoti.alertBody = "\(name)项目今天到期"
        } else {
            localNoti.alertBody = "\(name)项目还有\(day-1)天到期"
        }
        // 收到通知时播放的声音，默认消息声音
        localNoti.soundName = UILocalNotificationDefaultSoundName
        //待机界面的滑动动作提示
        localNoti.alertAction = "打开应用"
        // 应用程序图标右上角显示的消息数
        numNotife += 1
        localNoti.applicationIconBadgeNumber = numNotife
        // 通知上绑定的其他信息，为键值对
        localNoti.userInfo = ["id": "\(id)",  "name": "\(name)"]
        // 添加通知到系统队列中，系统会在指定的时间触发
        UIApplication.sharedApplication().scheduleLocalNotification(localNoti)
    }
    
    ///删除此条推送
    func deleteNotification() {
        if let locals = UIApplication.sharedApplication().scheduledLocalNotifications {
            for localNoti in locals {
                if let dict = localNoti.userInfo {
                    if dict.keys.contains("id") && dict["id"] is String && (dict["id"] as! String) == "\(id)" {
                        // 取消通知
                        UIApplication.sharedApplication().cancelLocalNotification(localNoti)
                    }
                }
            }
        }
    }
    
    ///删除所有推送
    class func deleteAllNotificication(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    ///新建项目设置总量
    func setNewProjectTotal(total: Double){
        self.total = total
        self.complete = 0
        self.rest = total
    }
    
    ///修改项目总量
    func editProjectTotal(total: Double) -> Bool{
        if total < complete{
            return false
        }else if total == complete{
            self.total = total
            self.rest = 0
            self.isFinished = .Finished
            self.deleteNotification()
            return true
        }else{
            self.total = total
            self.rest = total - complete
            return true
        }
    }
    
    ///变化完成量
    func increaseDone(done: Double){
        if type != .NoRecord{
            complete += done
            rest -= done
            percent = complete * 100 / total
            if complete >= total{
                complete = total
                rest = 0
                percent = 100.0
                self.deleteNotification()
            }else if complete < 0{
                complete = 0
                rest = total
                percent = 0.0
            }
            updateProject()
        }
    }
    
    ///不记录时间项目完成
    func finishDone(){
        if type == .NoRecord{
            complete += 1
            updateProject()
            self.deleteNotification()
        }
    }
    
    ///新建项目设置时间
    func setNewProjectTime(beginTime: String, endTime: String) -> Bool{
        if beginTime != "" && endTime != ""
        {
            self.beginTime = beginTime
            self.endTime = endTime
            //初始化项目状态
            isFinished = .NoSet
            //开始时间<结束时间
            if beginTimeDate.compare(endTimeDate) == NSComparisonResult.OrderedAscending{
                //开始时间>现在时间
                if beginTimeDate.timeIntervalSinceNow > 0{
                    isFinished = .NotBegined
                    //结束时间<现在时间
                }else if endTimeDate.timeIntervalSinceNow < 0{
                    //不记录时间项目
                    switch type{
                    case .NoRecord:
                        if complete == 1{
                            isFinished = .Finished
                        }else{
                            isFinished = .OverTime
                        }
                    default:
                        if complete < total{
                            isFinished = .OverTime
                        }else{
                           isFinished = .Finished
                        }
                    }
                    //结束时间>现在时间
                }else if endTimeDate.timeIntervalSinceNow > 0{
                    switch type{
                    case .NoRecord:
                        if complete == 1{
                            isFinished = .Finished
                        }else{
                            isFinished = .NotFinished
                        }
                    default:
                        if complete < total{
                            isFinished = .NotFinished
                        }else{
                            isFinished = .Finished
                        }
                    }
                }
            }
        }
        if isFinished != .NoSet{
            return true
        }else{
            return false
        }
    }
    
    ///判断project数据是否有缺漏
    func check() -> Bool {
        //判断项目前面3个属性是否为空
        if  name != "" &&  beginTime !=  "" && endTime != "" {
            if type == .Normal ||  type == .Punch {
                if unit != "" && total != 0 && isFinished != .NoSet
                    && total != 0{
                    return true
                }
            }else if type == .NoRecord{
               return true
            }
        }
        print("Project参数不正确")
        return false
    }
 
    ///刷新tags
    func freshenTags(){
        //如果id不等于默认值
        if id != -1{
            tags = TagMap().searchTagFromProject(self)
            for tag in tags{
                tagString = tagString + tag.name + " "
            }
        }
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

    /// 加载所有的数据
    func loadData(id: Int) -> Project?{
      
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_project WHERE id = '\(id)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return nil
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Project(dict: dict)
            return p
        }
        
        return nil
    }

    /// 加载所有的数据
    func selectID() -> Int?{
        var projects : [Project] = [Project]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_project WHERE name = '\(name)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return nil
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Project(dict: dict)
            projects.append(p)
        }
        return projects[0].id
    }
    
    ///插入本项目
    func insertProject() -> Bool{
        //添加推送
        addNotification()
        
        // 1.获取插入的SQL语句
        let insertSQL = "INSERT INTO t_project (name, type, beginTime, endTime, unit, total, complete, rest) VALUES ('\(name)', '\(type.rawValue)', '\(beginTime)', '\(endTime)', '\(unit)', '\(total)', '\(complete)', '\(rest)');"

        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(insertSQL) {
            print("插入新项目成功")
            
            if let selectid = selectID(){
                id = selectid
                //保存映射关系
                saveTags()
                return true
            }else{
                print("保存映射失败")
                return false
            }
            
        }else{
            print("插入新项目失败")
            return false
        }
    }
    
    ///更新本项目
    func updateProject() -> Bool{
        //删除推送
        deleteNotification()
        //添加推送
        addNotification()
        //删除之前的映射关系
        deleteTags()
        
        //保存映射关系
        saveTags()
        
        // 1.获取修改的SQL语句
        let updateSQL = "UPDATE t_project SET name = '\(name)', type = '\(type.rawValue)', beginTime = '\(beginTime)', endTime = '\(endTime)', unit = '\(unit)', total = '\(total)',  complete = '\(complete)', rest = '\(rest)'WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(updateSQL) {
            print("修改项目成功")
            return true
        }else{
            print("修改项目失败")
            return false
        }
    }
   
    ///删除本项目
    func deleteProject() -> Bool{
        //删除推送
        deleteNotification()
        
        //删除之前的映射关系
        deleteTags()
        
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
    
    ///保存映射关系
    func saveTags(){
        //保存现有的映射关系
        for tag in tags{
            let tagMap = TagMap(tagID: tag.id, projectID: self.id)
            tagMap.insertTagMap()
        }
    }
    
    ///删除之前映射关系
    func deleteTags(){
        TagMap().deleteTagMapWithProject(self)
    }
 }

