//
//  TagMapModel.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

//TagMapModel
class TagMap: NSObject{
    //标签映射序号
    var id: Int = -1
    //标签序号
    var tagID: Int = -1
    //项目序号
    var projectID: Int = -1
    
    override init() {
        super.init()
    }
    
    init(tagID: Int, projectID: Int){
        super.init()
        self.tagID = tagID
        self.projectID = projectID
    }
    
    init(dict : [String : AnyObject]) {
        super.init()
        //setValuesForKeysWithDictionary(dict)
        id = dict["id"]!.integerValue
        tagID = dict["tagID"]!.integerValue
        projectID = dict["projectID"]!.integerValue
    }
    
    //MARK:- 数据操作
    //通过项目查找标签
    func searchTagFromProject(project: Project) -> [Tag]{
        var tags = [Tag]()
        var tagMaps = [TagMap]()
        tagMaps = loadProjectData(project)
        for tagMap in tagMaps{
            if let tagTmps = Tag().loadData(tagMap.tagID){
                tags.append(tagTmps)
            }
        }
        return tags
    }
    
    //通过标签查找项目
    func searchProjectFromTag(tag: Tag) -> [Project]{
        var projects = [Project]()
        var tagMaps = [TagMap]()
        tagMaps = loadTagData(tag)
        for tagMap in tagMaps{
            if let tagTmps = Project().loadData(tagMap.projectID){
                projects.append(tagTmps)
            }
        }
        return projects
    }
    // MARK:- 和数据库之间的操作
    /// 加载某tag所有的数据
    func loadTagData(tag: Tag) -> [TagMap]{
        var tagMaps : [TagMap] = [TagMap]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_tagmap WHERE tagID = '\(tag.id)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return tagMaps
        }
        
        // 3.遍历数组
        for dict in array {
            let p = TagMap(dict: dict)
            tagMaps.append(p)
        }
        return tagMaps
    }
    
    /// 加载某项目所有的数据
    func loadProjectData(project: Project) -> [TagMap]{
        var tagMaps : [TagMap] = [TagMap]()
        
        // 1.获取查询语句
        let querySQL = "SELECT * FROM t_tagmap WHERE projectID = '\(project.id)';"
        
        // 2.执行查询语句
        guard let array = SQLiteManager.shareIntance.querySQL(querySQL) else {
            print("查询所有Project数据失败")
            return tagMaps
        }
        
        // 3.遍历数组
        for dict in array {
            let p = TagMap(dict: dict)
            tagMaps.append(p)
        }
        return tagMaps
    }
    
    //添加新的标签
    func insertTagMap() -> Bool{
        // 1.获取插入的SQL语句
        let insertSQL = "INSERT INTO t_tagmap (tagID, projectID) VALUES ('\(tagID)', '\(projectID)');"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(insertSQL) {
            print("插入新标签映射成功")
            return true
        }else{
            print("插入新标签映射失败")
            return false
        }
    }
    
    //删除此进程
    func deleteTagMap() -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_tagmap WHERE id = '\(id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除标签映射成功")
            return true
        }else{
            print("删除标签映射失败")
            return false
        }
    }

    //更具tag和project删除进程
    func deleteTagMap(tag: Tag, project: Project) -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_tagmap WHERE tagID = '\(tag.id)' and projectID = '\(project.id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除标签映射成功")
            return true
        }else{
            print("删除标签映射失败")
            return false
        }
    }
    
    //根据project删除进程
    func deleteTagMapWithProject(project: Project) -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_tagmap WHERE projectID = '\(project.id)';"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除标签映射成功")
            return true
        }else{
            print("删除标签映射失败")
            return false
        }
    }
    
    //更具tag删除进程
    func deleteTagMapWithTag(tag: Tag) -> Bool{
        // 1.获取删除的SQL语句
        let deleteSQL = "DELETE FROM t_tagmap WHERE tagID = '\(tag.id)' ;"
        
        // 2.执行SQL语句
        if SQLiteManager.shareIntance.execSQL(deleteSQL) {
            print("删除标签映射成功")
            return true
        }else{
            print("删除标签映射失败")
            return false
        }
    }
}
