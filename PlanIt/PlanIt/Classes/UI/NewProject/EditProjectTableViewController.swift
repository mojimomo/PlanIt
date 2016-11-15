//
//  EditProjectTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/9.
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


enum EditProjectTableState{
    case add, edit
}

enum EditProjectBackState{
    case addSuccess, editSucceess, deleteSucceess
}

protocol EditProjectTableViewDelegate: class{
    func goBackAct(_ state: EditProjectBackState)
}

class EditProjectTableViewController: UITableViewController ,UITextFieldDelegate{
    @IBOutlet weak var projectNameLabel: UITextField!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var punchSwitch: UISwitch!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var taskUnitCell: UITableViewCell!
    @IBOutlet weak var taskTotalCell: UITableViewCell!
    @IBOutlet weak var checkProjectCell: UITableViewCell!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var finishEditButton: UIButton!
    @IBOutlet weak var punchCell: UITableViewCell!
    
    let maxLengthDict  = [UITag.projectNameLabel : 25, UITag.unitTextField : 12, UITag.totalTextField : 12]
    
    struct UITag {
        static let projectNameLabel = 1001
        static let unitTextField = 1002
        static let totalTextField = 1003
    }
    
    
    var delegate: EditProjectTableViewDelegate?
    ///按钮文字
    var finishEditButtonText = ""
    ///项目名称
    var projectName:String{
        get{
            return (projectNameLabel?.text)!
        }
        set{
            projectNameLabel?.text = newValue
        }
    }
    ///项目开始时间
    var projectBeginTime:String{
        get{
            return (beginTimeLabel?.text)!
        }
        set{
            beginTimeLabel?.text = newValue
        }
    }
    ///项目结束时间
    var projectEndTime:String{
        get{
            return (endTimeLabel?.text)!
        }
        set{
            endTimeLabel?.text = newValue
        }
    }
    ///项目单位
    var projectUnit:String{
        get{
            return (unitTextField?.text)!
        }
        set{
            unitTextField?.text = newValue
        }
    }
    ///项目总量
    var projectTotal:Double{
        get{
            if totalTextField?.text != ""{
                return Double((totalTextField?.text)!)!
            }else{
                return 0
            }
        }
        set{
            totalTextField?.text = "\(Int(newValue))"
        }
    }
    fileprivate struct storyBoard {
        static let addFinishEditButton = "新增项目"
        static let deleteFinishEditButton = "删除项目"
    }
    
    ///当前表状态（修改状态、新增状态）
    var tableState: EditProjectTableState = .add
    
    ///当前项目
    var project = Project(){
        didSet{
            projectName = project.name
            projectBeginTime = project.beginTime
            projectEndTime = project.endTime
            projectType = project.type
            projectUnit = project.unit
            projectTotal = project.total
            updateUI()
        }
    }   
    

    ///项目类别
    var projectType = ProjectType.normal{
        didSet{
            //根据不同项目类别设置不同的状态
            switch projectType{
            case .normal:
                recordSwitch?.setOn(true, animated: false)
                punchSwitch?.setOn(false, animated: false)
                punchCell.isHidden = false
                taskUnitCell.isHidden = false
                taskTotalCell.isHidden = false
                
//                punchSwitch.enabled = true
//                unitTextField.enabled = true
//                totalTextField.enabled = true
            case .punch:
                recordSwitch?.setOn(true, animated: false)
                punchSwitch?.setOn(true, animated: false)
                punchCell.isHidden = false
                taskUnitCell.isHidden = false
                taskTotalCell.isHidden = false
                
//                punchSwitch.enabled = true
//                unitTextField.enabled = true
//                totalTextField.enabled = true
            case .noRecord:
                recordSwitch?.setOn(false, animated: false)
                punchSwitch?.setOn(false, animated: false)
                punchCell.isHidden = true
                taskUnitCell.isHidden = true
                taskTotalCell.isHidden = true
                
//                punchSwitch.enabled = false
//                unitTextField.enabled = false
//                totalTextField.enabled = false
            default: break
            }
        }
    }

    //MARK: - Action
    ///是否改变项目类型
    @IBAction func changeIsRecorded(_ sender: UISwitch) {
        if sender.isOn{
            projectType = .normal
        }else{
            projectType = .noRecord
        }
        updateUI()
    }
    
    ///是否改变签到任务
    @IBAction func changeIsPunch(_ sender: UISwitch) {
        if sender.isOn{
            projectType = .punch
            if unitTextField.text == "" && totalTextField.text == ""{
                unitTextField.text = NSLocalizedString("times",comment: "")
                //unitTextField.text = "次" (没能本地化)
                let days = projectBeginTime.FormatToNSDateYYYYMMMMDD()!.daysToEndDate(projectEndTime.FormatToNSDateYYYYMMMMDD()!)
                totalTextField.text = "\(days + 1)"
            }            
        }else{
            projectType = .normal
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
    
    //是否改变开始时间
    func editBeginTime(_ rect: CGRect) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .date
            //设置日期
            datePicker.setDate(self.project.beginTimeDate as Date, animated: false)
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            alerController.view.addSubview(datePicker)
            
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .cancel, handler: { (UIAlertAction) -> Void in
                let dateString = datePicker.date.FormatToStringYYYYMMDD()
                self.projectBeginTime = dateString
            })
   
//            //创建UIAlertAction 取消按钮
//            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
//                
//            })
            
            //添加动作
            alerController.addAction(alerActionOK)
            //alerController.addAction(alerActionCancel)
            
            if let popoverPresentationController = alerController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = rect
                //配置位置
                datePicker.frame = CGRect(x: 0, y: 0, width: alerController.view.bounds.width ,height: alerController.view.bounds.height)
                datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
            }else{
                //配置位置
                datePicker.frame = CGRect(x: 0, y: 0, width: alerController.view.bounds.width ,height: alerController.view.bounds.height - 50)
                datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            
            //显示alert
            self.present(alerController, animated: true, completion: { () -> Void in
                
            })
            

        }
    }
    
    ///是否改变结束时间
    func editEndTime(_ rect: CGRect) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .date
            //设置日期
            datePicker.setDate(self.project.endTimeDate.increaseDays(-1)!, animated: false)
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            alerController.view.addSubview(datePicker)
        
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .cancel, handler: { (UIAlertAction) -> Void in
                let dateString = datePicker.date.FormatToStringYYYYMMDD()
                weak var weakSelf = self
                weakSelf?.projectEndTime = dateString
            })
            
             //创建UIAlertAction 取消按钮
            //let alerActionCancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
                
            //})
            
            //添加动作
            alerController.addAction(alerActionOK)
            //alerController.addAction(alerActionCancel)
            
            if let popoverPresentationController = alerController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = rect
                //配置位置
                datePicker.frame = CGRect(x: 0, y: 0, width: alerController.view.bounds.width ,height: alerController.view.bounds.height)
                datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
            }else{
                //配置位置
                datePicker.frame = CGRect(x: 0, y: 0, width: alerController.view.bounds.width ,height: alerController.view.bounds.height - 50)
                datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            
            
            //显示alert
            self.present(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }


    
    ///完成编辑
    @IBAction func finishEdit(_ sender: AnyObject) {
        switch self.tableState{
        case .add:
            addNewProject()
        case .edit:
            finishEditProject()
        }
    }
 
    ///返回上个页面
    func handleDismiss(){
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    ///删除项目
    func deleteProject(){
        let alertController = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: NSLocalizedString("The operation is not reversible.", comment: ""), preferredStyle: .alert)
        //创建UIAlertAction 取消按钮
        let alerActionOK = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        //创建UIAlertAction 确定按钮
        let alerActionCancel = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler:  {(UIAlertAction) -> Void in
            weak var weakSelf = self
            weakSelf?.project.deleteProject()
            weakSelf?.dismiss(animated: true) { () -> Void in
                weakSelf?.delegate?.goBackAct(.deleteSucceess)
            }
        })
        //添加动作
        alertController.addAction(alerActionOK)
        alertController.addAction(alerActionCancel)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect =  CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        //显示alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Func
    ///完成新增项目
    fileprivate func addNewProject(){
        if projectName == "" {
            callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Project must have a name.", comment: ""))
            return
        }else{
            project.name = projectName
            if !project.nameIsVailed(){
                callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Project with the name already exists.", comment: ""))
                return
            }
        }
            
        if projectBeginTime != "" && projectEndTime != ""{
            if self.project.setNewProjectTime(self.projectBeginTime, endTime: self.projectEndTime) == false{
                self.callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Start and end time are not set correctly.", comment: ""))
                return
            }
        }else{
            callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Project must have start and end time.", comment: ""))
            return
        }
        
        project.type = projectType
        switch projectType{
        case .noRecord: break
        default:
            if projectUnit == ""{
                callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Progress Units cannot be empty.", comment: ""))
                return
            }else{
                project.unit = projectUnit
            }

            if  projectTotal != 0 {
                project.setNewProjectTotal(projectTotal)
            }else{
                callAlert(NSLocalizedString("Submit Failed", comment: "提交错误"),message: NSLocalizedString("Progress Totals cannot be empty or 0.", comment: ""))
                return
            }
        }
        if project.check(){
            if(project.insertProject()){
                //callAlertAndBack("提交成功",message: "新建项目成功!")

                switch project.type{
                case .punch: MobClick.event("1001")
                case .normal: MobClick.event("1002")
                case .noRecord: MobClick.event("1002")
                default:break
                }
                
                //返回
                handleDismiss()
                self.delegate?.goBackAct(.addSuccess)
                return
            }
        }
        callAlert(NSLocalizedString("Failed", comment: "提交失败"),message: "")
    }
   
    ///完成修改项目
    fileprivate func finishEditProject(){
        if projectName == "" {
            callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Project must have a name.", comment: ""))
            return
        }else{
            project.name = projectName
        }
        
        if projectBeginTime != "" && projectEndTime != ""{
            if self.project.setNewProjectTime(self.projectBeginTime, endTime: self.projectEndTime) == false{
                self.callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Start and end time are not set correctly.", comment: ""))
                return
            }
        }else{
            callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Project must have start and end time.", comment: ""))
            return
        }
        project.type = projectType
        switch projectType{
        case .noRecord: break
        default:
            if projectUnit == ""{
                callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Progress Units cannot be empty.", comment: ""))
                return
            }else{
                project.unit = projectUnit
            }
            if  projectTotal != 0{
                if !project.editProjectTotal(projectTotal) {
                    callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Progress Totals must be greater than you've completed.", comment: ""))
                    return
                }
                project.setNewProjectTime(projectBeginTime, endTime: projectEndTime)
            }else{
                callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: NSLocalizedString("Progress Totals cannot be empty or 0.", comment: ""))
                return
            }
        }
        if project.check(){
            if(project.updateProject()){
                //callAlertAndBack("修改成功",message: "修改项目成功!")
                self.dismiss(animated: true) { () -> Void in
                    self.delegate?.goBackAct(.editSucceess)
                }
                return
            }
        }
        callAlert(NSLocalizedString("Edit Failed", comment: "修改错误"),message: "")
    }

    
    ///更新界面
    fileprivate func updateUI(){
        self.tableView.reloadData()
        //self.tableView.setNeedsDisplay()
    }   


    
    //MARK: -  TableView Delegate
//    ///隐藏某cell
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        //创建3个NSIndexPath对应相应的cell位置
//        let unitCellPath = NSIndexPath(forRow: 1, inSection: 2)
//        let totalCellPath = NSIndexPath(forRow: 2, inSection: 2)
//        let checkCellPath = NSIndexPath(forRow: 0, inSection: 3)
//        //比较NSIndexPath
//        if indexPath == unitCellPath || indexPath == totalCellPath || indexPath == checkCellPath{
//            if (projectType == .NoRecord) {
//                // 假设改行原来高度为0
//                return 0;
//            } else {
//                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
//            }
//        }else {
//            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
//        }
//    }

    
    ///点击某个单元格触发的方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beginTimeCellPath = IndexPath(row: 0, section: 1)
        let endTimeCellPath = IndexPath(row: 1, section: 1)
        let tagCellPath = IndexPath(row: 1, section: 0)
        switch indexPath{
        case beginTimeCellPath:
            if  tableState == .edit && project.isFinished != .finished{
                let processes = Process().loadData(project.id)
                if processes.count == 0{
                    let rect = tableView.rectForRow(at: indexPath)
                    editBeginTime(rect)
                }else{
                    callAlert(NSLocalizedString("EditFailed", comment: "无法修改"), message: NSLocalizedString("Progress exists", comment: ""))
                }
            }else if tableState == .add{
                let rect = tableView.rectForRow(at: indexPath)
                editBeginTime(rect)
            }
        case endTimeCellPath:
            if project.isFinished != .finished {
                let rect = tableView.rectForRow(at: indexPath)
                editEndTime(rect)
            }
        case tagCellPath:
            if indexPath == tagCellPath{
                let tags = Tag().loadAllData()
                for tag in tags{
                    for selectedTag in project.tags{
                        if tag.name == selectedTag.name{
                            tag.isSelected = true
                        }
                    }
                }
                RRTagController.displayTagController(parentController: self, tags: tags, blockFinish: { (selectedTags, unSelectedTags) -> () in
                    weak var weakSelf = self
                    weakSelf?.project.tags = selectedTags
                    }) { () -> () in
                }
            }
        default:break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        projectNameLabel.delegate = self
        projectNameLabel.tag = UITag.projectNameLabel
        unitTextField.delegate = self
        unitTextField.tag = UITag.unitTextField
        totalTextField.delegate = self
        totalTextField.tag = UITag.totalTextField
        unitTextField.autocorrectionType = .no
        projectNameLabel.autocorrectionType = .no
        switch tableState{
        case .add:
            //添加新增项目按钮
         let addButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .done, target: self, action: #selector(EditProjectTableViewController.finishEdit(_:)))
            self.navigationItem.rightBarButtonItem = addButton
            
            //新增返回按钮
            let backButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(EditProjectTableViewController.handleDismiss))
            self.navigationItem.leftBarButtonItem = backButton
        case .edit:
            //添加新增项目按钮
            let addButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .done, target: self, action: #selector(EditProjectTableViewController.finishEdit(_:)))
            
            ///新增返回按钮
            let backButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(EditProjectTableViewController.handleDismiss))
            
            //新增删除按钮
            let deleteButton = UIBarButtonItem(image: UIImage(named: "delete"), style: .done, target: self, action: #selector(EditProjectTableViewController.deleteProject))
            
            //按钮间的空隙
            let gap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                action: nil)
            gap.width = 10;
            
            //用于消除右边边空隙，要不然按钮顶不到最边上
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
                action: nil)
            spacer.width = 0;

            //设置按钮
            self.navigationItem.leftBarButtonItems = [spacer, backButton, gap, deleteButton]
            self.navigationItem.rightBarButtonItem = addButton
            
//            //新增删除按钮
//            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.bounds.width , height: 44.0 ))
//            deleteButton.backgroundColor = UIColor.whiteColor()
//            deleteButton.setTitle("删除项目", forState: .Normal)
//            deleteButton.setTitleColor(UIColor.redColor(), forState: .Normal)
//            deleteButton.addTarget(self, action: "deleteProject", forControlEvents: .TouchUpInside)
//            self.tableView.tableFooterView = deleteButton

            //default: break
        }

        //初始化代码
        let nowDate = Date()
        let nextDate = nowDate.increaseDays(7)!
        project.beginTime = nowDate.FormatToStringYYYYMMDD()
        project.endTime = nextDate.FormatToStringYYYYMMDD()
        beginTimeLabel?.text = project.beginTime
        endTimeLabel?.text = project.endTime
        projectType = .normal
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 25))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0

        //添加lebel观察者
        NotificationCenter.default.addObserver(self,selector:  #selector(EditProjectTableViewController.textFiledEditChanged(_:)),name: NSNotification.Name.UITextFieldTextDidChange ,object: projectNameLabel)
        NotificationCenter.default.addObserver(self,selector:  #selector(EditProjectTableViewController.textFiledEditChanged(_:)),name: NSNotification.Name.UITextFieldTextDidChange ,object: unitTextField)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //删除观察者
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: projectNameLabel)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: unitTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        //设置按钮标题
        finishEditButton?.setTitle(finishEditButtonText, for: UIControlState())
        if tableState == .edit{
            recordSwitch.isEnabled = false
            punchSwitch.isEnabled = false
        }
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ivc = segue.destination as? TagsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "showTags":
                    ivc.title = NSLocalizedString("Select Tags", comment: "选择标签")
                default: break
                }
            }
        }
    }
    
    func projectForTagsView(_ sneder: TagsViewController) -> Project? {
        return project
    }

    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString

        switch textField.tag{
//        case UITag.projectNameLabel:
//            if newText.length >= 0 && newText.length <= 10{
//                return true
//            }else {
//                return false
//            }
//        case UITag.unitTextField:
//            if newText.length >= 0 && newText.length <= 5{
//                return true
//            }else {
//                return false
//            }
        case UITag.totalTextField:
            let new = newText as String
            if newText.length >= 0 && newText.length <= maxLengthDict[UITag.totalTextField] &&  (new.validateNum() || new == ""){
                return true
            }else {
                return false
            }

        default:
            return true
        }
    }

}
