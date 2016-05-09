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
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var recordSwitch: UISwitch!
    
    @IBOutlet weak var taskUnitCell: UITableViewCell!
    @IBOutlet weak var taskTotalCell: UITableViewCell!
    @IBOutlet weak var checkProjectCell: UITableViewCell!

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
