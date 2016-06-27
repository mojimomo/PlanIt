//
//  TagsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/16.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

protocol TagsViewDelegate: class {
    func passSelectedTag(selectedTag: Tag?)
}

class TagsViewController: UITableViewController {
    var tags = [Tag]()
    var selectTags = [Bool]()
    var isEditingMod = false
    var delegate:TagsViewDelegate?
    
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
    
    func handleBack(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - viewlife
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.tintColor = UIColor.blackColor()
        self.view.backgroundColor = allBackground
        self.title = "标签"
        tags = Tag().loadAllData()
        selectTags = [Bool](count: tags.count, repeatedValue: false)
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .Done, target: self, action: "handleBack")        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = tags.count + 1
        return cnt
    }
    
    ///配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath)
        //配置cell
        if indexPath.row == 0{
            cell.textLabel?.text = "显示全部"
        }else{
            cell.textLabel?.text = tags[indexPath.row - 1].name
        }
        return cell
    }
    
    ///点击某个单元格触发的方法
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0{
            delegate?.passSelectedTag(nil)
        }else{
            delegate?.passSelectedTag(tags[indexPath.row - 1])
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
//        //设置单元格打勾
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        if selectTags[indexPath.row] == true{
//            cell?.accessoryType = .None
//            selectTags[indexPath.row] = false
//        }else if selectTags[indexPath.row] == false{
//            cell?.accessoryType = .Checkmark
//            selectTags[indexPath.row] = true
//        }
    }
}
