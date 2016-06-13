//
//  TagsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/16.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

protocol TagsViewDataSource: class {
    func projectForTagsView(sneder: TagsViewController) -> Project?
}

class TagsViewController: UITableViewController {
    var tags = [Tag]()
    var selectTags = [Bool]()
    var isEditingMod = false
    var DateSource:TagsViewDataSource?
    
    private struct Storyboard{
        static let CellReusIdentifier = "TagCell"
    }
    @IBOutlet var tagsTableView: UITableView!
    
    @IBAction func finishAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func finishEdit(sender: AnyObject) {
        isEditingMod = !isEditingMod
        self.tagsTableView.setEditing(isEditingMod, animated: true)
    }
    
    // MARK: - viewlife
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tintColor = UIColor.blackColor()
        tags = Tag().loadAllData()
        selectTags = [Bool](count: tags.count, repeatedValue: false)
    }
    
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = tags.count
        return cnt
    }
    
    ///配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath)
        //配置cell
        cell.textLabel?.text = tags[indexPath.row].name
        return cell
    }
    
    ///点击某个单元格触发的方法
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //设置单元格打勾
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if selectTags[indexPath.row] == true{
            cell?.accessoryType = .None
            selectTags[indexPath.row] = false
        }else if selectTags[indexPath.row] == false{
            cell?.accessoryType = .Checkmark
            selectTags[indexPath.row] = true
        }
    }
}
