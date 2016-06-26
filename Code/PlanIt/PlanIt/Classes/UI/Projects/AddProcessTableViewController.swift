//
//  addProcessTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/6/19.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class AddProcessTableViewController: UITableViewController {
    var project = Project()
    
    @IBOutlet weak var doneTextField: UITextField!
    @IBOutlet weak var currentProcessTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: "finishEdit")
        self.navigationItem.rightBarButtonItem = addBarButton

        let cancelBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancelBarButton
        
        currentProcessTextField.text = "\(project.complete) / \(project.total)"
    }
    
    @IBAction func editDoneDidEnd(sender: UITextField) {
        if doneTextField.text != ""{
            if Double(doneTextField.text!)! > project.rest{
                doneTextField.text = "\(project.rest)"
            }
            currentProcessTextField.text = "\(project.complete +  Double(doneTextField.text!)!) / \(project.total)"
        }
    }
    
    func finishEdit(){
        if doneTextField.text != "" {
            let process = Process()
            process.projectID = project.id
            let currentTime = NSDate()
            let dateFormat = NSDateFormatter()
            dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
            dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
            dateFormat.dateStyle = .LongStyle
            process.recordTime = dateFormat.stringFromDate(currentTime)
            process.done = Double(doneTextField.text!)!
            process.remark = doneTextField.text!
            process.insertProcess()
            ProcessDate().chengeData(project.id, timeDate: currentTime, changeValue: process.done)
            project.increaseDone(process.done)
            cancel()
        }
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}
	