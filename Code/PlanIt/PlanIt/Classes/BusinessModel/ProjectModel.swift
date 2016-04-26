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
class Project{
    //项目编号
    var id: Int = -1
    //项目名称
    var name: String?
    //项目类型
    var type: Int = ProjectType.NoRecord
    //项目开始时间
    var beginTime = NSDate()
    //项目结束时间
    var endTime = NSDate()
    //任务单位
    var unit: String?
    //任务总量
    var Total: Int = -1
    //是否完成
    var isFinished: Int = ProjectIsFinished.NoSet
    //完成量
    var complete: Int = -1
    //剩余量
    var rest: Int = -1
    //Tag表
    var Tags = [Tag]()
    //备注
    var remark: String?
 }

