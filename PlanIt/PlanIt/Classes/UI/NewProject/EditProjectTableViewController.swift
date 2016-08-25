//
//  EditProjectTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/9.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

enum EditProjectTableState{
    case Add, Edit
}

enum EditProjectBackState{
    case AddSuccess, EditSucceess, DeleteSucceess
}

protocol EditProjectTableViewDelegate: class{
    func goBackAct(state: EditProjectBackState)
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
    
    let maxLengthDict  = [UITag.projectNameLabel : 10, UITag.unitTextField : 5, UITag.totalTextField : 6]
    
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
    private struct storyBoard {
        static let addFinishEditButton = "新增项目"
        static let deleteFinishEditButton = "删除项目"
    }
    
    ///当前表状态（修改状态、新增状态）
    var tableState: EditProjectTableState = .Add
    
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
    var projectType = ProjectType.Normal{
        didSet{
            //根据不同项目类别设置不同的状态
            switch projectType{
            case .Normal:
                recordSwitch?.setOn(true, animated: false)
                punchSwitch?.setOn(false, animated: false)
                punchCell.hidden = false
                taskUnitCell.hidden = false
                taskTotalCell.hidden = false
                
//                punchSwitch.enabled = true
//                unitTextField.enabled = true
//                totalTextField.enabled = true
            case .Punch:
                recordSwitch?.setOn(true, animated: false)
                punchSwitch?.setOn(true, animated: false)
                punchCell.hidden = false
                taskUnitCell.hidden = false
                taskTotalCell.hidden = false
                
//                punchSwitch.enabled = true
//                unitTextField.enabled = true
//                totalTextField.enabled = true
            case .NoRecord:
                recordSwitch?.setOn(false, animated: false)
                punchSwitch?.setOn(false, animated: false)
                punchCell.hidden = true
                taskUnitCell.hidden = true
                taskTotalCell.hidden = true
                
//                punchSwitch.enabled = false
//                unitTextField.enabled = false
//                totalTextField.enabled = false
            default: break
            }
        }
    }

    //MARK: - Action
    ///是否改变项目类型
    @IBAction func changeIsRecorded(sender: UISwitch) {
        if sender.on{
            projectType = .Normal
        }else{
            projectType = .NoRecord
        }
        updateUI()
    }
    
    ///是否改变签到任务
    @IBAction func changeIsPunch(sender: UISwitch) {
        if sender.on{
            projectType = .Punch
            if unitTextField.text == "" && totalTextField.text == ""{
                unitTextField.text = "次"
                let days = projectBeginTime.FormatToNSDateYYYYMMMMDD()!.daysToEndDate(projectEndTime.FormatToNSDateYYYYMMMMDD()!)
                totalTextField.text = "\(days + 1)"
            }            
        }else{
            projectType = .Normal
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
    
    //是否改变开始时间
    func editBeginTime(rect: CGRect) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .Date
            //设置日期
            datePicker.setDate(self.project.beginTimeDate, animated: false)
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
            
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Cancel, handler: { (UIAlertAction) -> Void in
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
                datePicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height)
                datePicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                
            }else{
                //配置位置
                datePicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height - 50)
                datePicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
            
            //显示alert
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
            

        }
    }
    
    ///是否改变结束时间
    func editEndTime(rect: CGRect) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .Date
            //设置日期
            datePicker.setDate(self.project.endTimeDate.increaseDays(-1)!, animated: false)
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
        
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Cancel, handler: { (UIAlertAction) -> Void in
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
                datePicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height)
                datePicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                
            }else{
                //配置位置
                datePicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height - 50)
                datePicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
            
            
            //显示alert
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }


    
    ///完成编辑
    @IBAction func finishEdit(sender: AnyObject) {
        switch self.tableState{
        case .Add:
            addNewProject()
        case .Edit:
            finishEditProject()
        }
    }
 
    ///返回上个页面
    func dismiss(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    ///删除项目
    func deleteProject(){
        let alertController = UIAlertController(title: "确认删除", message: "无法撤销删除操作", preferredStyle: .Alert)
        //创建UIAlertAction 确定按钮
        let alerActionOK = UIAlertAction(title: "取消", style: .Default, handler: nil)
        //创建UIAlertAction 取消按钮
        let alerActionCancel = UIAlertAction(title: "确定", style: .Destructive, handler:  {(UIAlertAction) -> Void in
            weak var weakSelf = self
            weakSelf?.project.deleteProject()
            weakSelf?.dismissViewControllerAnimated(true) { () -> Void in
                weakSelf?.delegate?.goBackAct(.DeleteSucceess)
            }
        })
        //添加动作
        alertController.addAction(alerActionOK)
        alertController.addAction(alerActionCancel)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect =  CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        }
        //显示alert
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Func
    ///完成新增项目
    private func addNewProject(){
        if projectName == "" {
            callAlert("提交错误",message: "项目名称不能为空")
            return
        }else{
            project.name = projectName
            if !project.nameIsVailed(){
                callAlert("提交错误",message: "项目名称不能重复")
                return
            }
        }
            
        if projectBeginTime != "" && projectEndTime != ""{
            if self.project.setNewProjectTime(self.projectBeginTime, endTime: self.projectEndTime) == false{
                self.callAlert("修改错误",message: "开始结束时间不正确")
                return
            }
        }else{
            callAlert("提交错误",message: "时间不能为空")
            return
        }
        
        project.type = projectType
        switch projectType{
        case .NoRecord: break
        default:
            if projectUnit == ""{
                callAlert("提交错误",message: "项目任务单位不能为空")
                return
            }else{
                project.unit = projectUnit
            }

            if  projectTotal != 0 {
                project.setNewProjectTotal(projectTotal)
            }else{
                callAlert("提交错误",message: "项目任务总量不能为空或0")
                return
            }
        }
        if project.check(){
            if(project.insertProject()){
                //callAlertAndBack("提交成功",message: "新建项目成功!")

                switch project.type{
                case .Punch: MobClick.event("1001")
                case .Normal: MobClick.event("1002")
                case .NoRecord: MobClick.event("1002")
                default:break
                }
                
                //返回
                dismiss()
                self.delegate?.goBackAct(.AddSuccess)
                return
            }
        }
        callAlert("提交失败",message: "新建项目失败")
    }
   
    ///完成修改项目
    private func finishEditProject(){
        if projectName == "" {
            callAlert("修改错误",message: "项目名称不能为空")
            return
        }else{
            project.name = projectName
        }
        
        if projectBeginTime != "" && projectEndTime != ""{
            if self.project.setNewProjectTime(self.projectBeginTime, endTime: self.projectEndTime) == false{
                self.callAlert("修改错误",message: "开始结束时间不正确")
                return
            }
        }else{
            callAlert("修改错误",message: "时间不能为空")
            return
        }
        project.type = projectType
        switch projectType{
        case .NoRecord: break
        default:
            if projectUnit == ""{
                callAlert("修改错误",message: "项目任务单位不能为空")
                return
            }else{
                project.unit = projectUnit
            }
            if  projectTotal != 0{
                if !project.editProjectTotal(projectTotal) {
                    callAlert("修改错误",message: "项目任务总量不能小于已完成量")
                    return
                }
                project.setNewProjectTime(projectBeginTime, endTime: projectEndTime)
            }else{
                callAlert("修改错误",message: "项目任务总量不能为0")
                return
            }
        }
        if project.check(){
            if(project.updateProject()){
                //callAlertAndBack("修改成功",message: "修改项目成功!")
                self.dismissViewControllerAnimated(true) { () -> Void in
                    self.delegate?.goBackAct(.EditSucceess)
                }
                return
            }
        }
        callAlert("修改失败",message: "新建项目失败")
    }

    
    ///更新界面
    private func updateUI(){
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
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let beginTimeCellPath = NSIndexPath(forRow: 0, inSection: 1)
        let endTimeCellPath = NSIndexPath(forRow: 1, inSection: 1)
        let tagCellPath = NSIndexPath(forRow: 1, inSection: 0)
        switch indexPath{
        case beginTimeCellPath:
            if  tableState == .Edit && project.isFinished != .Finished{
                let processes = Process().loadData(project.id)
                if processes.count == 0{
                    let rect = tableView.rectForRowAtIndexPath(indexPath)
                    editBeginTime(rect)
                }else{
                    callAlert("无法修改", message: "项目已添加进度")
                }
            }else if tableState == .Add{
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                editBeginTime(rect)
            }
        case endTimeCellPath:
            if project.isFinished != .Finished {
                let rect = tableView.rectForRowAtIndexPath(indexPath)
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
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        unitTextField.autocorrectionType = .No
        projectNameLabel.autocorrectionType = .No
        switch tableState{
        case .Add:
            //添加新增项目按钮
         let addButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: #selector(EditProjectTableViewController.finishEdit(_:)))
            self.navigationItem.rightBarButtonItem = addButton
            
            //新增返回按钮
            let backButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: #selector(EditProjectTableViewController.dismiss))
            self.navigationItem.leftBarButtonItem = backButton
        case .Edit:
            //添加新增项目按钮
            let addButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: #selector(EditProjectTableViewController.finishEdit(_:)))
            
            ///新增返回按钮
            let backButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: #selector(EditProjectTableViewController.dismiss))
            
            //新增删除按钮
            let deleteButton = UIBarButtonItem(image: UIImage(named: "delete"), style: .Done, target: self, action: #selector(EditProjectTableViewController.deleteProject))
            
            //按钮间的空隙
            let gap = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
                action: nil)
            gap.width = 10;
            
            //用于消除右边边空隙，要不然按钮顶不到最边上
            let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
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
        let nowDate = NSDate()
        let nextDate = nowDate.increaseDays(7)!
        project.beginTime = nowDate.FormatToStringYYYYMMDD()
        project.endTime = nextDate.FormatToStringYYYYMMDD()
        beginTimeLabel?.text = project.beginTime
        endTimeLabel?.text = project.endTime
        projectType = .Normal
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 25))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0

        //添加lebel观察者
        NSNotificationCenter.defaultCenter().addObserver(self,selector:  #selector(EditProjectTableViewController.textFiledEditChanged(_:)),name: UITextFieldTextDidChangeNotification ,object: projectNameLabel)
        NSNotificationCenter.defaultCenter().addObserver(self,selector:  #selector(EditProjectTableViewController.textFiledEditChanged(_:)),name: UITextFieldTextDidChangeNotification ,object: unitTextField)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        //删除观察者
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: projectNameLabel)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: unitTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        //设置按钮标题
        finishEditButton?.setTitle(finishEditButtonText, forState: .Normal)
        if tableState == .Edit{
            recordSwitch.enabled = false
            punchSwitch.enabled = false
        }
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ivc = segue.destinationViewController as? TagsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "showTags":
                    ivc.title = "选择标签"
                default: break
                }
            }
        }
    }
    
    func projectForTagsView(sneder: TagsViewController) -> Project? {
        return project
    }

    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)

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
