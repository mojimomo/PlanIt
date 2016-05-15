//
//  ProcessModel.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//ProcessModel
class Process{
    //进度序号
    var id: Int = -1
    //项目序号
    var projectID: Int = -1
    //记录时间
    var recordTime = NSDate()
    //完成工作量
    var done: Double? = -1
    
    init() {
    }
}