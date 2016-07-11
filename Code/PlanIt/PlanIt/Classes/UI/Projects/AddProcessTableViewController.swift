//
//  addProcessTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/6/19.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
protocol AddProcessDelegate: class{
    func addProcessTableViewAct(old: Double, new: Double, name: String)
}

class AddProcessTableViewController: UITableViewController ,UITextFieldDelegate{
    var project = Project()
    var delegate: AddProcessDelegate?
    private var oldPercent = 0.0
    private var newPercent = 0.0
    @IBOutlet weak var doneTextField: UITextField!
    @IBOutlet weak var currentProcessTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var currentProcessLabel: UILabel!
    
    struct UITag {
        static let doneTextField = 1004
        static let remarkTextField = 1005
    }
    
    @IBAction func doneDidChanged(sender: UITextField) {
        if doneTextField.text != ""{
            if Double(doneTextField.text!)! > project.rest{
                doneTextField.text = "\(Int(project.rest))"
            }
            currentProcessLabel.text = "已记录总量:  \(Int(project.complete) +  Int(doneTextField.text!)!) / \(Int(project.total))"
        }
    }
    
    func finishEdit(){
        if doneTextField.text != "" {
            oldPercent = project.percent
            let process = Process()
            process.projectID = project.id
            let currentTime = NSDate()
            let dateFormat = NSDateFormatter()
            dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
            dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
            //dateFormat.dateStyle = .LongStyle
             process.recordTime = dateFormat.stringFromDate(currentTime)
            process.done = Double(doneTextField.text!)!
            process.remark = remarkTextField.text!
            process.insertProcess()
            ProcessDate().chengeData(project.id, timeDate: currentTime, changeValue: process.done)
            project.increaseDone(process.done)
            newPercent = project.percent
            cancel()
        }
    }
    
    @IBAction func remarkDidChanged(sender: UITextField) {
        if  sender.text?.characters.count > 20 {
            sender.text = (sender.text! as NSString).substringToIndex(20)
        }
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            if self.newPercent != 0{
               self.delegate?.addProcessTableViewAct(self.oldPercent, new: self.newPercent, name: self.project.name)
            }
        }
    }
    
    // MARK: - TableView delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - ViewContrl Lifecle
    override func viewDidLoad() {
        super.viewDidLoad()
        doneTextField.tag = UITag.doneTextField
        doneTextField.delegate = self
        remarkTextField.tag = UITag.remarkTextField
        remarkTextField.delegate = self
        
        let addBarButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: "finishEdit")
        self.navigationItem.rightBarButtonItem = addBarButton
        
        let cancelBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancelBarButton
        doneTextField.placeholder = project.unit
        currentProcessLabel.text = "已记录总量:  \(Int(project.complete)) / \(Int(project.total))"
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 25))
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 25
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField.tag{
        case UITag.doneTextField:
            let new = newText as String
            if newText.length >= 0 && newText.length <= 6 && new.validateNum(){
                return true
            }else {
                return false
            }
        case UITag.remarkTextField:
            if newText.length >= 0 && newText.length <= 20{
                return true
            }else {
                return false
            }
        default:
            return true
        }
    }
}
	