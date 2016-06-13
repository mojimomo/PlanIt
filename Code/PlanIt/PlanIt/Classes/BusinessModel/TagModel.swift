//
//  TagModel.swift
//  PlanIt
//
//  Created by Ken on 16/4/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//标签Model
class Tag: NSObject{
    ///标签序号
    var id: Int = -1
    ///标签名称
    var name = ""
    ///是否被选中
    var isSelected = false
    ///是否被锁定
    var isLocked = false
    var textContent = ""
    
    override init() {
        super.init()
    }
    
    init(name : String) {
        super.init()
        self.name = name
        self.textContent = name
    }
    
    init(dict : [String : AnyObject]) {
        super.init()
        //setValuesForKeysWithDictionary(dict)
        id = dict["id"]!.integerValue
        name = String(dict["name"]!)
        textContent = name
    }
    
    // MARK:- 和数据库之间的操作
    /// 加载所有的数据
    func loadAllData() -> [Tag]{
        var tags : [Tag] = [Tag]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_tag;"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return tags
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Tag(dict: dict)
            tags.append(p)
        }
        return tags
    }
    
    /// 加载所有的数据
    func loadData(id: Int) -> Tag?{
        var tags : [Tag] = [Tag]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_tag WHERE id = '\(id)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return nil
        }
        
        // 3.遍历数组
        for dict in array {
            let p = Tag(dict: dict)
            tags.append(p)
        }
        return tags[0]
    }
    
    ///添加新的标签
    func insertTag() -> Bool{
        // 1.获取插入的SQL语句
        let insertSQL = "INSERT INTO t_tag (name) VALUES ('\(name)');"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(insertSQL) {
            print("插入新标签成功")
            return true
        }else{
            print("插入新标签失败")
            return false
        }
    }
    
    ///删除此进程
    func deleteTag() -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_tag WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除标签成功")
            return true
        }else{
            print("删除标签失败")
            return false
        }
    } 
    
    
}