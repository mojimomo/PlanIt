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
class Project: SQLTable{
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
    
    init() {
        super.init(tableName:"Project")
    }
    
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
    func isEmpyt() -> Bool {
        //判断项目前面3个属性是否为空
        if  name != "" &&  beginTime !=  "" && endTime != "" {
            if type == ProjectType.Normal ||  type == ProjectType.Punch {
                if unit != "" && total != -1 && isFinished != ProjectIsFinished.NoSet
                    && complete != -1 && rest != -1{
                    return true
                }
            }else if type == ProjectType.NoRecord{
               return true
            }
        }
        return false
    }
    
    required convenience init(tableName:String) {
        self.init()
    }
 }

