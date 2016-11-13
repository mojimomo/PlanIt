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
    
    @IBAction func finishEdit(_ sender: AnyObject) {
        isEditingMod = !isEditingMod
        self.processTableView.setEditing(isEditingMod, animated: true)
    }
    
    fileprivate struct Storyboard{
        static let CellReusIdentifier = "ProcessCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let editBarButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .Done, target: self, action: "finishEdit:")
//        self.navigationItem.rightBarButtonItem = ///删除某一行
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(ProcessesTableViewController.dissmiss))
        self.navigationItem.leftBarButtonItem = backBarButton
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0
        
        self.tableView.estimatedRowHeight = 2.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProcess()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func dissmiss(){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(_ tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return records[section]
    }
    
    ///配置cell内容
    override func tableView(_ tv:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReusIdentifier, for: indexPath) as! ProcessTableViewCell
        
        //配置cell
        cell.unit = project.unit
        var index = 0
        for group in 0 ..< (indexPath as NSIndexPath).section  {
            index += records[group]
        }
        index += (indexPath as NSIndexPath).row
        cell.process = processes[index]
        return cell
    }
    
    ///删除某一行
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //if isEditingMod == true{
            var index = 0
            for group in 0 ..< (indexPath as NSIndexPath).section  {
                index += records[group]
            }
            index += (indexPath as NSIndexPath).row
            //删除数据库
            let process =  processes[index]
            process.deleteProcess()
            project.increaseDone(-process.done)
            ProcessDate().chengeData(process.projectID, timeDate: process.recordTimeDate, changeValue: -process.done)
            //删除输出源
            processes.remove(at: index)
            records[(indexPath as NSIndexPath).section] -= 1
            //是否是分组最后一行
            if records[(indexPath as NSIndexPath).section] == 0{
                records.remove(at: (indexPath as NSIndexPath).section)
                months.remove(at: (indexPath as NSIndexPath).section)
                processTableView.deleteSections(IndexSet(integer: (indexPath as NSIndexPath).section), with:  .fade)
            }else{
                //删除表格
                processTableView.deleteRows(at: [indexPath], with: .fade)
            }
        if records.count == 0{
            loadProcess()
        }
        //}
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[section]
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    ///确认节数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return months.count
    }
    
    ///自定义删除按钮文字
    override func tableView(_ tableView:UITableView, titleForDeleteConfirmationButtonForRowAt indexPath:IndexPath) ->String?{
        return NSLocalizedString("Delete", comment: "")
    }
    
    // MARK: - Func
    func loadProcess(){
        ///清除无数据试图
        noDataView?.removeFromSuperview()
        noDataButton?.removeFromSuperview()
        
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async {
            weak var weakSelf = self
            ///加载数据
            weakSelf?.processes = Process().loadData(self.project.id)
            if self.processes.count > 0 {
                for process in self.processes{
                    var index = 0
                    if weakSelf?.months.count == 0{
                        weakSelf?.months.append(process.month)
                        weakSelf?.records.append(1)
                    }else{
                        for month in self.months{
                            if process.month == month{
                                weakSelf?.records[index] += 1
                                break
                            }else if month == self.months.last {
                                weakSelf?.months.append(process.month)
                                weakSelf?.records.append(1)
                            }
                            index += 1
                        }
                    }
                }
            }
            self.processes = self.processes.reversed()
            DispatchQueue.main.async(execute: {
                weakSelf?.tableView.reloadData()
                weakSelf?.checkTableView()
            })
        }

    }
    
    func checkTableView(){
        if processes.count == 0{
            var noDataImageString = ""
            switch project.type {
            case .normal:
                noDataImageString = "recordnodata"
            case .punch:
                noDataImageString = "punchnodata"
            default:break
            }
            
            //添加没有数据图片
            let noDataImage = UIImage(named: noDataImageString)
            noDataView = UIImageView(image: noDataImage)
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.shared.statusBarFrame
            noDataView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height - (rectNav?.height)! - rectStatus.height) / 2 - (rectNav?.height)! - rectStatus.height)
            self.tableView.addSubview(noDataView)
            
            //添加去添加按钮
            noDataButton = UIButton(type: .system)
            noDataButton.setTitle(NSLocalizedString("Add Now", comment: ""), for: UIControlState())
            noDataButton.setTitleColor(UIColor.colorFromHex("#85b4ea"), for: UIControlState())
            noDataButton.sizeToFit()
            let margin:CGFloat = 10
            noDataButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height - (rectNav?.height)! - rectStatus.height) / 2 - (rectNav?.height)! - rectStatus.height + noDataView.bounds.height / 2 + noDataButton.bounds.height / 2 + margin)
            noDataButton.addTarget(self, action: #selector(ProcessesTableViewController.handleBack), for: .touchUpInside)
            self.tableView.addSubview(noDataButton)
        }
    }
    
    func handleBack(){
        self.navigationController?.popToRootViewController(animated: true)
    }
}


