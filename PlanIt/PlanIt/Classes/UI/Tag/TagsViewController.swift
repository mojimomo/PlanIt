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
    var tagCounts = [Int]()
    var tagMaps = [TagMap]()
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
    
    ///显示未开始项目
    var isShowNotBegin : Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("isShowNotBegin") as Bool!
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isShowNotBegin")
        }
    }
    ///显示未开始项目
    var isShowFinished : Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("isShowFinished") as Bool!
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isShowFinished")
        }
    }
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        //self.view.tintColor = UIColor.blackColor()
        self.view.backgroundColor = allBackground
        self.title = "标签选择"
        tags = Tag().loadAllData()
        tagMaps = TagMap().loadAllData()
        let projects = Project().loadAllData()
        //添加项目总素        
        var counts = 0
        for project in projects {
            if isShowFinished{
                 if project.isFinished == .Finished{
                    counts += 1
                }
            }else{
                if project.isFinished != .Finished{
                    counts += 1
                }
            }
        }
        tagCounts.append(counts)
        
        //添加没有标签的
        var noTagCount = 0
        if tagMaps.count != 0{
            for project in projects{
                if isShowFinished{
                    if project.isFinished == .Finished{
                        for tagMap in tagMaps{
                            if tagMap.projectID == project.id{
                                break
                            }else if tagMap == tagMaps.last{
                                noTagCount += 1
                            }
                        }
                    }
                }else{
                    if project.isFinished != .Finished{
                        for tagMap in tagMaps{
                            if tagMap.projectID == project.id{
                                break
                            }else if tagMap == tagMaps.last{
                                noTagCount += 1
                            }
                        }
                    }
                }
            }
        }else{
            noTagCount = counts
        }

        tagCounts.append(noTagCount)
        
        //添加标签
        for tag in tags{
            var tagCount = 0
            for tagMap in tagMaps{
                if tagMap.tagID == tag.id{
                    for project in projects{
                        if tagMap.projectID == project.id{
                            if isShowFinished{
                                if project.isFinished == .Finished{
                                    tagCount += 1
                                }
                            }else{
                                if project.isFinished != .Finished{
                                    tagCount += 1
                                }
                            }
                            break
                        }
                    }
                    
                }
            }
            tagCounts.append(tagCount)
        }
        
        selectTags = [Bool](count: tags.count, repeatedValue: false)
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .Done, target: self, action: #selector(TagsViewController.handleBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 1))
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0

    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //判断是否第一次打开此页面
        if((NSUserDefaults.standardUserDefaults().boolForKey("IsFirstLaunchTagsView") as Bool!) == false){
            print("第一次打开标签页面")
            //设置为非第一次打开此页面
            if tags.count > 0 {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsFirstLaunchTagsView")
                let indexPath = NSIndexPath(forRow: tags.count + 1, inSection: 0)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath){
                    self.callFirstRemain("点击查看包含\(tags.last!.name)标签的项目", view: cell)
                }
            }
        }else{
            
        }
    }
    
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = tags.count + 2
        return cnt
    }
    
    ///配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! TagTableViewCell
        //配置cell
        if indexPath.row == 0{
            cell.tagName = "显示全部"
            cell.tagCounts = tagCounts[indexPath.row]
            let sepView = UIView(frame: CGRect(x: 15, y: 43.5, width: self.tableView.bounds.width - 30, height: 0.5))
            sepView.backgroundColor = UIColor.colorFromHex("#EFEFEF")
            cell.addSubview(sepView)
        }else if indexPath.row == 1{
            cell.tagName = "无标签"
            cell.tagCounts = tagCounts[indexPath.row]
        }else{
            cell.tagName = tags[indexPath.row - 2].name
            cell.tagCounts = tagCounts[indexPath.row]
        }
        return cell
    }
    
    ///点击某个单元格触发的方法
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //全部
        if indexPath.row == 0{
            delegate?.passSelectedTag(nil)
        //无标签
        }else if indexPath.row == 1{
            let newTag = Tag()
            newTag.id = -1
            delegate?.passSelectedTag(newTag)
        //按标签
        }else{
            delegate?.passSelectedTag(tags[indexPath.row - 2])
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
