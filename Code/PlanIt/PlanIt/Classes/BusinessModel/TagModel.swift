//
//  TagModel.swift
//  PlanIt
//
//  Created by Ken on 16/4/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//TagModel
class Tag: SQLTable{
    //标签序号
    var id: Int = -1
    //标签名称
    var name = ""
    
    init() {
        super.init(tableName:"tasks")
    }
    
    required convenience init(tableName:String) {
        self.init()
    }
}