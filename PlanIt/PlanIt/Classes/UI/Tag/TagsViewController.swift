//
//  TagsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/16.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

protocol TagsViewDelegate: class {
    func passSelectedTag(_ selectedTag: Tag?)
}

class TagsViewController: UITableViewController {
    var tags = [Tag]()
    var tagCounts = [Int]()
    var tagMaps = [TagMap]()
    var selectTags = [Bool]()
    var isEditingMod = false
    var delegate:TagsViewDelegate?
    
    fileprivate struct Storyboard{
        static let CellReusIdentifier = "TagCell"
    }
    @IBOutlet var tagsTableView: UITableView!
    
    @IBAction func finishAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func finishEdit(_ sender: AnyObject) {
        isEditingMod = !isEditingMod
        self.tagsTableView.setEditing(isEditingMod, animated: true)
    }
    
    func handleBack(){
        self.navigationController?.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    ///显示未开始项目
    var isShowNotBegin : Bool{
        get{
            return UserDefaults.standard.bool(forKey: "isShowNotBegin") as Bool!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "isShowNotBegin")
        }
    }
    ///显示未开始项目
    var isShowFinished : Bool{
        get{
            return UserDefaults.standard.bool(forKey: "isShowFinished") as Bool!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "isShowFinished")
        }
    }
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        //self.view.tintColor = UIColor.blackColor()
        self.view.backgroundColor = allBackground
        self.title = NSLocalizedString("Select Tags", comment: "")
        tags = Tag().loadAllData()
        tagMaps = TagMap().loadAllData()
        let projects = Project().loadAllData()
        //添加项目总素        
        var counts = 0
        for project in projects {
            if isShowFinished{
                 if project.isFinished == .finished{
                    counts += 1
                }
            }else{
                if project.isFinished != .finished{
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
                    if project.isFinished == .finished{
                        for tagMap in tagMaps{
                            if tagMap.projectID == project.id{
                                break
                            }else if tagMap == tagMaps.last{
                                noTagCount += 1
                            }
                        }
                    }
                }else{
                    if project.isFinished != .finished{
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
                                if project.isFinished == .finished{
                                    tagCount += 1
                                }
                            }else{
                                if project.isFinished != .finished{
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
        
        selectTags = [Bool](repeating: false, count: tags.count)
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(TagsViewController.handleBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 0

    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //判断是否第一次打开此页面
        if((UserDefaults.standard.bool(forKey: "IsFirstLaunchTagsView") as Bool!) == false){
            print("第一次打开标签页面")
            //设置为非第一次打开此页面
            if tags.count > 0 {
                UserDefaults.standard.set(true, forKey: "IsFirstLaunchTagsView")
                let indexPath = IndexPath(row: tags.count + 1, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath){
                    self.callFirstRemain(String(format: NSLocalizedString("Tap to check all projects with tag %@", comment: ""), tags.last!.name), view: cell)
                }
            }
        }else{
            
        }
    }
    
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(_ tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = tags.count + 2
        return cnt
    }
    
    ///配置cell内容
    override func tableView(_ tv:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReusIdentifier, for: indexPath) as! TagTableViewCell
        //配置cell
        //去除分割线
        for view in cell.subviews {
            if view.tag == 1025{
                view.removeFromSuperview()
            }
        }
        //显示全部
        if (indexPath as NSIndexPath).row == 0{
            cell.tagName = NSLocalizedString("Show All", comment: "")
            cell.tagCounts = tagCounts[(indexPath as NSIndexPath).row]
            let sepView = UIView(frame: CGRect(x: 15, y: 43.5, width: self.tableView.bounds.width - 30, height: 0.5))
            sepView.tag = 1025
            sepView.backgroundColor = UIColor.colorFromHex("#EFEFEF")
            cell.addSubview(sepView)
        //无标签
        }else if (indexPath as NSIndexPath).row == 1{
            cell.tagName = NSLocalizedString("Untagged", comment: "")
            cell.tagCounts = tagCounts[(indexPath as NSIndexPath).row]
        //其他tag
        }else{
            cell.tagName = tags[(indexPath as NSIndexPath).row - 2].name
            cell.tagCounts = tagCounts[(indexPath as NSIndexPath).row]
        }
        return cell
    }
    
    ///点击某个单元格触发的方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //全部
        if (indexPath as NSIndexPath).row == 0{
            delegate?.passSelectedTag(nil)
        //无标签
        }else if (indexPath as NSIndexPath).row == 1{
            let newTag = Tag()
            newTag.id = -1
            delegate?.passSelectedTag(newTag)
        //按标签
        }else{
            delegate?.passSelectedTag(tags[(indexPath as NSIndexPath).row - 2])
        }
        
        self.navigationController?.dismiss(animated: true, completion: { () -> Void in
            
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
