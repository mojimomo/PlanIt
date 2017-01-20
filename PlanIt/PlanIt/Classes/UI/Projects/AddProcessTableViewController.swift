//
//  addProcessTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/6/19.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

protocol AddProcessDelegate: class{
    func addProcessTableViewAct(_ old: Double, new: Double, name: String)
}

class AddProcessTableViewController: UITableViewController ,UITextFieldDelegate{
    var project = Project()
    var delegate: AddProcessDelegate?
    fileprivate var oldPercent = 0.0
    fileprivate var newPercent = 0.0
    @IBOutlet weak var doneTextField: UITextField!
    @IBOutlet weak var currentProcessTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    @IBOutlet weak var currentProcessLabel: UILabel!
    let maxLengthDict  = [UITag.doneTextField : 40, UITag.remarkTextField : 100]
    struct UITag {
        static let doneTextField = 1004
        static let remarkTextField = 1005
    }
    
    @IBAction func doneDidChanged(_ sender: UITextField) {
        if doneTextField.text != ""{
            if Double(doneTextField.text!)! > project.rest{
                doneTextField.text = "\(Int(project.rest))"
            }
            currentProcessLabel.text = NSLocalizedString("Have completed: ", comment: "新增进度页面") + "\(Int(project.complete) +  Int(doneTextField.text!)!) / \(Int(project.total))"
        }
    }
    
    func finishEdit(){
        if doneTextField.text != "" {
            //新增进度
            oldPercent = project.percent
            let process = Process()
            process.projectID = project.id
            let currentTime = Date()
            let dateFormat = DateFormatter()
            dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
            dateFormat.locale = Locale(identifier: "zh_CN")
            //dateFormat.dateStyle = .LongStyle
             process.recordTime = dateFormat.string(from: currentTime)
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
    
    @IBAction func remarkDidChanged(_ sender: UITextField) {
        if  sender.text?.characters.count > 20 {
            sender.text = (sender.text! as NSString).substring(to: 20)
        }
    }
    
    func cancel(){
        self.dismiss(animated: true) { () -> Void in
            if self.newPercent != 0{
               self.delegate?.addProcessTableViewAct(self.oldPercent, new: self.newPercent, name: self.project.name)
            }
        }
    }
    
    ///观察是否超出字符
    func textFiledEditChanged(_ sender: Notification){
        let textField = sender.object as! UITextField
        let kMaxLength = maxLengthDict[textField.tag] ?? 0
        let toBeString = textField.text!
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if selectedRange == nil {
            if (toBeString.characters.count > kMaxLength){
                let rangeIndex = (toBeString as NSString).rangeOfComposedCharacterSequence(at: kMaxLength)
                if rangeIndex.length == 1
                {
                    textField.text = (toBeString as NSString).substring(to: kMaxLength)
                }
                else
                {
                    let rangeRange = (toBeString as NSString).rangeOfComposedCharacterSequences(for: NSMakeRange(0, kMaxLength))
                    textField.text = (toBeString as NSString).substring(to: rangeRange.length)
                }
            }
        }
    }
    
    // MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - ViewContrl Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        doneTextField.tag = UITag.doneTextField
        doneTextField.delegate = self
        remarkTextField.tag = UITag.remarkTextField
        remarkTextField.delegate = self
        
        let addBarButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .done, target: self, action: #selector(AddProcessTableViewController.finishEdit))
        self.navigationItem.rightBarButtonItem = addBarButton
        
        let cancelBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(AddProcessTableViewController.cancel))
        self.navigationItem.leftBarButtonItem = cancelBarButton
        doneTextField.placeholder = project.unit
        currentProcessLabel.text = NSLocalizedString("Have completed: ", comment: "新增进度页面") + "\(Int(project.complete)) / \(Int(project.total))"
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 25))
        self.tableView.sectionFooterHeight = 0
        self.tableView.sectionHeaderHeight = 25
        
        //添加lebel观察者
        NotificationCenter.default.addObserver(self,selector:  #selector(AddProcessTableViewController.textFiledEditChanged(_:)),name: NSNotification.Name.UITextFieldTextDidChange ,object: remarkTextField)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //删除观察者
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: remarkTextField)
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        
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
	
