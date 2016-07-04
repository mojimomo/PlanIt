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
        let editBarButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .Done, target: self, action: "finishEdit:")
        self.navigationItem.rightBarButtonItem = editBarButton
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "back"), style: .Done, target: self, action: "dissmiss")
        self.navigationItem.leftBarButtonItem = backBarButton
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 1))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0
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
        for var group = 0; group < indexPath.section ; group++ {
            index += records[group]
        }
        index += indexPath.row
        cell.process = processes[index]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if isEditingMod == true{
            let process =  processes[indexPath.row]
            process.deleteProcess()
            project.increaseDone(-process.done)
            ProcessDate().chengeData(process.projectID, timeDate: process.recordTimeDate, changeValue: -process.done)
            processes.removeAtIndex(indexPath.row)
            processTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[section]
    }
    
    ///确认节数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return months.count
    }
    
    // MARK: - Func
    func loadProcess(){
        processes = Process().loadData(project.id)
        for process in processes{
            var index = 0
            if months.count == 0{
                months.append(process.month)
                records.append(1)
            }else{
                for month in months{
                    if process.month == month{
                        records[index]++
                        break
                    }else if month == months.last {
                        months.append(process.month)
                        records.append(1)
                    }
                    index++
                }
            }
        }
    }

}
