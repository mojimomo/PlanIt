//
//  EditProjectTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/9.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

enum editProjectTableState{
    case Add, Edit
}

class EditProjectTableViewController: UITableViewController ,TagsViewDataSource{
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

    //按钮文字
    var finishEditButtonText = ""
    //项目名称
    var projectName:String{
        get{
            return (projectNameLabel?.text)!
        }
        set{
            projectNameLabel?.text = newValue
        }
    }
    //项目开始时间
    var projectBeginTime:String{
        get{
            return (beginTimeLabel?.text)!
        }
        set{
            beginTimeLabel?.text = newValue
        }
    }
    //项目结束时间
    var projectEndTime:String{
        get{
            return (endTimeLabel?.text)!
        }
        set{
            endTimeLabel?.text = newValue
        }
    }
    //项目单位
    var projectUnit:String{
        get{
            return (unitTextField?.text)!
        }
        set{
            unitTextField?.text = newValue
        }
    }
    //项目总量
    var projectTotal:Double{
        get{
            return Double((totalTextField?.text)!)!
        }
        set{
            totalTextField?.text = "\(newValue)"
        }
    }
    private struct storyBoard {
        static let addFinishEditButton = "新增项目"
        static let deleteFinishEditButton = "删除项目"
    }
    
    //当前表状态（修改状态、新增状态）
    var tableState: editProjectTableState = .Add{
        didSet{
            //根据不同状态设置不同的UI
            switch tableState{
            case .Add:
                finishEditButtonText = storyBoard.addFinishEditButton
            case .Edit:
                finishEditButtonText = storyBoard.deleteFinishEditButton
            //default: break
            }
            updateUI()
        }
        
    }
    
    //当前项目
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
    

    //项目类别
    var projectType = ProjectType.Normal{
        didSet{
            //根据不同项目类别设置不同的状态
            switch projectType{
            case ProjectType.Normal:
                recordSwitch.setOn(true, animated: false)
                punchSwitch.setOn(false, animated: false)
            case ProjectType.Punch:
                recordSwitch.setOn(true, animated: false)
                punchSwitch.setOn(true, animated: false)
            case ProjectType.NoRecord:
                recordSwitch.setOn(false, animated: false)
                punchSwitch.setOn(false, animated: false)
            default: break
            }
        }
    }

    //MARK: - Action
    @IBAction func changeIsRecorded(sender: UISwitch) {
        if sender.on{
            projectType = ProjectType.Normal
        }else{
            projectType = ProjectType.NoRecord
        }
        updateUI()
    }
    
    @IBAction func changeIsPunch(sender: UISwitch) {
        if sender.on{
            projectType = ProjectType.Punch
        }else{
            projectType = ProjectType.Normal
        }
    }
    
    @IBAction func editBeginTime(sender: AnyObject) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .Date
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
            
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                let dateString = dateFormat.stringFromDate(datePicker.date)
                self.projectBeginTime = dateString
            })
   
            //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            
            //添加动作
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            //显示alert
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    @IBAction func editEndTime(sender: AnyObject) {
        if IS_IOS8{
            //创建datepicker控件
            let datePicker = UIDatePicker()
            //设置模式为日期模式
            datePicker.datePickerMode = .Date
            //创建UIAlertController
            let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
            alerController.view.addSubview(datePicker)
        
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
                let dateString = dateFormat.stringFromDate(datePicker.date)
                self.projectEndTime = dateString
            })
            
             //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            
            //添加动作
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            //显示alert
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })
        }
    }


    
    //完成编辑
    @IBAction func finishEdit(sender: AnyObject) {
        switch self.tableState{
        case .Add:
            addNewProject()
        case .Edit:
            deleteProject()
        }
    }
 
    //MARK: - Func
    //新增项目
    private func addNewProject(){
        if projectName == "" {
            callAlert("提交错误",message: "项目名称不能为空!")
            return
        }else if projectName.characters.count > 12 {
            callAlert("提交错误",message: "项目名称不能超过12!")
            return
        }else{
            project.name = projectName
        }

        
        if projectBeginTime != "" && projectEndTime != ""{
                if project.setNewProjectTime(projectBeginTime, endTime: projectEndTime) == false{
                    callAlert("提交错误",message: "开始结束时间不正确!")
                    return
                }
        }else{
            callAlert("提交错误",message: "时间不能为空!")
            return
        }
        switch projectType{
        case ProjectType.NoRecord: break
        default:
            if projectUnit == ""{
                callAlert("提交错误",message: "项目任务单位不能为空!")
                return
            }else if project.unit.characters.count > 10 {
                callAlert("提交错误",message: "项目任务单位不能超过10!")
                return
            }else{
                project.unit = projectUnit
            }
            if  projectTotal != 0{
                project.setNewProjectTotal(projectTotal)
            }else{
                callAlert("提交错误",message: "项目任务总量不能为0!")
                return
            }
        }
        if project.check(){
            if(project.insertProject()){
                callAlert("提交成功",message: "新建项目成功!")
                return
            }
        }
        callAlert("提交失败",message: "新建项目失败!")
    }
   
    //删除项目
    private func deleteProject(){
        let alerController = UIAlertController(title: "是否确定删除该项目？", message: nil, preferredStyle: .ActionSheet)
        //创建UIAlertAction 确定按钮
        let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
            self.project.deleteProject()
        })
        //创建UIAlertAction 取消按钮
        let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
        })
        //添加动作
        alerController.addAction(alerActionOK)
        alerController.addAction(alerActionCancel)
        //显示alert
        self.presentViewController(alerController, animated: true, completion: { () -> Void in
            
        })
    }
    
    //更新界面
    private func updateUI(){
        self.tableView.reloadData()
        //self.tableView.setNeedsDisplay()
    }
    
    //发起提示
    func callAlert(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "好的", style: .Default,
            handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Override TableView
    //隐藏某cell
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //创建3个NSIndexPath对应相应的cell位置
        let unitCellPath = NSIndexPath(forRow: 1, inSection: 2)
        let totalCellPath = NSIndexPath(forRow: 2, inSection: 2)
        let checkCellPath = NSIndexPath(forRow: 3, inSection: 2)
        //比较NSIndexPath
        if indexPath == unitCellPath || indexPath == totalCellPath || indexPath == checkCellPath{
            if (projectType == ProjectType.NoRecord) {
                // 假设改行原来高度为0
                return 0;
            } else {
                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        }else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    //点击某个单元格触发的方法
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //设置单元格打勾
        let tagCellPath = NSIndexPath(forRow: 1, inSection: 0)
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
                    self.project.tags = selectedTags
                }) { () -> () in
            }
        }

    }
    
    //MARK: - View Controller Lifecle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)        //设置按钮标题
        finishEditButton?.setTitle(finishEditButtonText, forState: .Normal)
        projectTotal = 0
        projectType = ProjectType.Normal
        
        //初始化代码
        let nowDate = NSDate()
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let dateString = dateFormat.stringFromDate(nowDate)
        beginTimeLabel?.text = dateString
        endTimeLabel?.text = dateString
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ivc = segue.destinationViewController as? TagsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "tags":
                    ivc.title = "选择标签"
                    ivc.DateSource = self
                default: break
                }
            }
        }
    }
    
    func projectForTagsView(sneder: TagsViewController) -> Project? {
        return project
    }
}
