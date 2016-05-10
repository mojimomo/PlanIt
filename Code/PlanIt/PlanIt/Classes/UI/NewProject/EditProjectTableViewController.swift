//
//  EditProjectTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/9.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class EditProjectTableViewController: UITableViewController {

    @IBOutlet weak var projectNameLabel: UITextField!

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var taskUnitCell: UITableViewCell!
    @IBOutlet weak var taskTotalCell: UITableViewCell!
    @IBOutlet weak var checkProjectCell: UITableViewCell!

    var project = Project(){
        didSet{
            beginTimeLabel?.text = project.beginTime
            endTimeLabel?.text = project.endTime
            updateUI()
        }
    }
    
    //是否打开记录进度
    var recordIsOpen = true
    
    @IBAction func changeIsRecorded(sender: UISwitch) {
        if sender.on{
            recordIsOpen = true
        }else{
            recordIsOpen = false
        }
        updateUI()
    }
    
    @IBAction func editBeginTime(sender: AnyObject) {
        if IS_IOS8{
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .Date
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
            
            let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                let dateString = dateFormat.stringFromDate(datePicker.date)
                self.project.beginTime = dateString
                self.beginTimeLabel?.text = dateString
            })
            
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    @IBAction func editEndTime(sender: AnyObject) {
        if IS_IOS8{
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .Date
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
            
            let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                let dateString = dateFormat.stringFromDate(datePicker.date)
                self.project.endTime = dateString
                self.endTimeLabel?.text = dateString
            })
            
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }

    //隐藏某cell
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //创建3个NSIndexPath对应相应的cell位置
        let unitCellPath = NSIndexPath(forRow: 1, inSection: 2)
        let totalCellPath = NSIndexPath(forRow: 2, inSection: 2)
        let checkCellPath = NSIndexPath(forRow: 3, inSection: 2)
        //比较NSIndexPath
        if indexPath == unitCellPath || indexPath == totalCellPath || indexPath == checkCellPath{
            if (!recordIsOpen) {
                // 假设改行原来高度为0
                return 0;
            } else {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        }else {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    private func updateUI(){
        self.tableView.reloadData()
        //self.tableView.setNeedsDisplay()
    }
}
