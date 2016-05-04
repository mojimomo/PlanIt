//
//  TagMapModel.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//TagMapModel
class TagMap: SQLTable {
    //标签映射序号
    var id: Int = -1
    //标签序号
    var tagID: Int = -1
    //项目序号
    var projectID: Int = -1
    
    init() {
        super.init(tableName:"TagMap")
    }
    
    required convenience init(tableName:String) {
        self.init()
    }
}