//
//  processesTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/28.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProcessesTableViewController: UITableViewController {
    var project = Project()
    var months = [String]()
    var records = [Int]()
    var processes = [Process]()
    var isEditingMod = false
    var noDataView : UIView!
    var noDataButton : UIButton!
    @IBOutlet var processTableView: UITableView!
    
    @IBAction func finishEdit(sender: AnyObject) {
        isEditingMod = !isEditingMod
        self.processTableView.setEditing(isEditingMod, animated: true)
    }
    
    private struct Storyboard{
        static let CellReusIdentifier = "ProcessCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let editBarButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .Done, target: self, action: "finishEdit:")
//        self.navigationItem.rightBarButtonItem = ///删除某一行
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "back"), style: .Done, target: self, action: #selector(ProcessesTableViewController.dissmiss))
        self.navigationItem.leftBarButtonItem = backBarButton
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 1))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0
        
        self.tableView.estimatedRowHeight = 2.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadProcess()
    }

    func dissmiss(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return records[section]
    }
    
    ///配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProcessTableViewCell
        
        //配置cell
        cell.unit = project.unit
        var index = 0
        for group in 0 ..< indexPath.section  {
            index += records[group]
        }
        index += indexPath.row
        cell.process = processes[index]
        return cell
    }
    
    ///删除某一行
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //if isEditingMod == true{
            var index = 0
            for group in 0 ..< indexPath.section  {
                index += records[group]
            }
            index += indexPath.row
            //删除数据库
            let process =  processes[index]
            process.deleteProcess()
            project.increaseDone(-process.done)
            ProcessDate().chengeData(process.projectID, timeDate: process.recordTimeDate, changeValue: -process.done)
            //删除输出源
            processes.removeAtIndex(index)
            records[indexPath.section] -= 1
            //是否是分组最后一行
            if records[indexPath.section] == 0{
                records.removeAtIndex(indexPath.section)
                months.removeAtIndex(indexPath.section)
                processTableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation:  .Fade)
            }else{
                //删除表格
                processTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        if records.count == 0{
            loadProcess()
        }
        //}
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
        
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[section]
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    ///确认节数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return months.count
    }
    
    ///自定义删除按钮文字
    override func tableView(tableView:UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath:NSIndexPath) ->String?{
        return "删除"
    }
    
    // MARK: - Func
    func loadProcess(){
        ///清除无数据试图
        noDataView?.removeFromSuperview()
        noDataButton?.removeFromSuperview()
        
        ///加载数据
        processes = Process().loadData(project.id)
        if processes.count > 0 {
            for process in processes{
                var index = 0
                if months.count == 0{
                    months.append(process.month)
                    records.append(1)
                }else{
                    for month in months{
                        if process.month == month{
                            records[index] += 1
                            break
                        }else if month == months.last {
                            months.append(process.month)
                            records.append(1)
                        }
                        index += 1
                    }
                }
            }
        }else{
            var noDataImageString = ""
            switch project.type {
            case .Normal:
                noDataImageString = "recordnodata"
            case .Punch:
                noDataImageString = "punchnodata"
            default:break
            }
            
            //添加没有数据图片
            let noDataImage = UIImage(named: noDataImageString)
            noDataView = UIImageView(image: noDataImage)
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.sharedApplication().statusBarFrame
            noDataView.center = CGPoint(x: UIScreen.mainScreen().bounds.width / 2, y: (UIScreen.mainScreen().bounds.height - (rectNav?.height)! - rectStatus.height) / 2 - (rectNav?.height)! - rectStatus.height)
            self.tableView.addSubview(noDataView)
            
            //添加去添加按钮
            noDataButton = UIButton(type: .System)
            noDataButton.setTitle("去添加", forState: .Normal)
            noDataButton.setTitleColor(UIColor.colorFromHex("#85b4ea"), forState: .Normal)
            noDataButton.sizeToFit()
            let margin:CGFloat = 10
            noDataButton.center = CGPoint(x: UIScreen.mainScreen().bounds.width / 2, y: (UIScreen.mainScreen().bounds.height - (rectNav?.height)! - rectStatus.height) / 2 - (rectNav?.height)! - rectStatus.height + noDataView.bounds.height / 2 + noDataButton.bounds.height / 2 + margin)
            noDataButton.addTarget(self, action: #selector(ProcessesTableViewController.handleBack), forControlEvents: .TouchUpInside)
            self.tableView.addSubview(noDataButton)
        }
    }
    
    func handleBack(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}


