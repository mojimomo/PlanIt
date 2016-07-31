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
    let maxLengthDict  = [UITag.doneTextField : 6, UITag.remarkTextField : 20]
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
            //新增进度
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
            
            MobClick.event("2002")
            
            //返回
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
    
    ///观察是否超出字符
    func textFiledEditChanged(sender: NSNotification){
        let textField = sender.object as! UITextField
        let kMaxLength = maxLengthDict[textField.tag] ?? 0
        let toBeString = textField.text!
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if selectedRange == nil {
            if (toBeString.characters.count > kMaxLength){
                let rangeIndex = (toBeString as NSString).rangeOfComposedCharacterSequenceAtIndex(kMaxLength)
                if rangeIndex.length == 1
                {
                    textField.text = (toBeString as NSString).substringToIndex(kMaxLength)
                }
                else
                {
                    let rangeRange = (toBeString as NSString).rangeOfComposedCharacterSequencesForRange(NSMakeRange(0, kMaxLength))
                    textField.text = (toBeString as NSString).substringToIndex(rangeRange.length)
                }
            }
        }
    }
    
    // MARK: - TableView delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - ViewContrl Lifecycle
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
        
        //添加lebel观察者
        NSNotificationCenter.defaultCenter().addObserver(self,selector:  "textFiledEditChanged:",name: UITextFieldTextDidChangeNotification ,object: remarkTextField)
    }
    
    override func viewDidDisappear(animated: Bool) {
        //删除观察者
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: remarkTextField)
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField.tag{
        case UITag.doneTextField:
            let new = newText as String
            if newText.length >= 0 && newText.length <= maxLengthDict[UITag.doneTextField] && (new.validateNum() || new == ""){
                return true
            }else {
                return false
            }
//        case UITag.remarkTextField:
//            if newText.length >= 0 && newText.length <= maxLengthDict[UITag.remarkTextField]{
//                return true
//            }else {
//                return false
//            }
        default:
            return true
        }
    }
}
	