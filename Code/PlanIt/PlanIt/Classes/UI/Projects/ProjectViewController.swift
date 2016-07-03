//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
import Popover

class ProjectViewController: UIViewController, TagsViewDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource ,AddProcessDelegate{

    @IBOutlet weak var tagsBarButton: UIBarButtonItem!
    @IBOutlet weak var projectTableView: UITableView!{
        didSet{
            projectTableView.tag = tableViewTag.ProjectsTable
            projectTableView.delegate = self
            projectTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var projectName: UILabel!
    struct tableViewTag {
        static let MuneTable = 0
        static let TagsTable = 1
        static let ProjectsTable = 2
    }
    //表格高度
    let tableViewHeight : CGFloat = 44
    private var selectTag : Tag?
    private var popover: Popover!
    private var waveLoadingIndicator: WaveLoadingIndicator!
    private var oldPercent = 0
    private var newPercent = 0
    private var increasePercent = 0
    private var texts = ["显示未开始", "已完成", "设置"]
    private var popoverOptions: [PopoverOption] = [
        .Type(.Down),
        .CornerRadius(0.0),
        .ArrowSize(CGSize(width: 0.0, height: 0.0)),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    private var showPercentPopoverOptions: [PopoverOption] = [
        .Type(.Down),
        .CornerRadius(8.0),
        .ArrowSize(CGSize(width: 0.0, height: 0.0)),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .Animation(.None)
    ]
    ///显示未开始项目
    private var isShowNotBegin = false
    ///显示未开始项目
    private var isShowFinished = false
    ///添加项目按钮
    var addProjectButton: UIButton?
    ///项目列表
    var projects = [Project]()
    var orginProjects = [Project]()
    ///cell边距
    var cellMargin : CGFloat = 15.0
    ///添加新项目底部边距
    var addProjectButtonMargin : CGFloat = 20.0
    ///添加按钮尺寸
    var addProjectButtonSize : CGSize = CGSize(width: 0, height: 0)
    private struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    
    ///呼出标签栏
    @IBAction func callTag(sender: UIBarButtonItem) {
        let tagsViewControl = self.storyboard?.instantiateViewControllerWithIdentifier("ShowTags") as! TagsViewController
        tagsViewControl.title = "标签"
        tagsViewControl.view.backgroundColor = allBackground
        tagsViewControl.delegate = self
        
        //设置加载动画
        let transition = CATransition()
        transition.duration = 1.0
        transition.type = kCATransitionPush //推送类型
        transition.subtype = kCATransitionFromLeft //从左侧
        tagsViewControl.view.layer.addAnimation(transition, forKey: "Reveal")
        
        let navController = UINavigationController.init(rootViewController: tagsViewControl)
        //状态栏和导航栏不透明
        navController.navigationBar.translucent = false
        //设置导航栏颜色
        navController.navigationBar.barTintColor = otherNavigationBackground
        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)    }
    
    ///点击点开抽屉菜单
    @IBAction func callMenu(sender: AnyObject) {
//        //获取此页面的抽屉菜单页
//        if let drawer = self.navigationController?.parentViewController as? KYDrawerController{
//            //设置菜单页状态
//            drawer.setDrawerState( .Opened, animated: true)
//        }
        let startPoint = CGPoint(x: self.view.frame.width / 2, y: 0)
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 135 + rectStatus.size.height))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatus.size.height))
        tableView.tag = tableViewTag.MuneTable
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = false
        tableView.separatorStyle = .None
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView,  point: startPoint)
    }

    ///点击创建新项目
    @IBAction func addProject(sender: UIBarButtonItem) {
        //查找故事板中EditProject
        let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
        addNewProjectViewController.title = "新增项目"
        addNewProjectViewController.tableState = .Add
        addNewProjectViewController.modalPresentationStyle = .Popover
        addNewProjectViewController.preferredContentSize = CGSizeMake(view.bounds.width * 0.8, view.bounds.height * 0.8)
        
        if let popController = addNewProjectViewController.popoverPresentationController {
            let sourceView = view
            popController.permittedArrowDirections = .Up
            popController.sourceView = self.navigationController?.view
            let y = sourceView.center.y + sourceView.bounds.height / 2
            popController.sourceRect = CGRectMake(sourceView.center.x, y, 0, 0)
            popController.delegate = self
        }
        
        self.presentViewController(addNewProjectViewController, animated: true, completion: nil)
    }

    // MARK: - Func
    //点击是否显示未开始
    func showNotBegin(){
        isShowNotBegin = !isShowNotBegin
        loadData()
        self.projectTableView.reloadData()
    }
    
    ///加载所有数据
    func loadData(){
        //读取原始数据
        if selectTag != nil{
            title = selectTag?.name
            projects = TagMap().searchProjectFromTag(selectTag!)
        }else{
            projects = Project().loadAllData()
            if isShowFinished{
               title = "已完成项目"
            }else{
                title = "全部项目"
            }
        }
        
        var index = 0
        
        for project in projects {
            //不显示未开始
            if !isShowNotBegin {
                if project.isFinished == .NotBegined {
                    projects.removeAtIndex(index)
                    continue
                }
            }
            //显示结束
            if isShowFinished {
                if project.isFinished != .Finished {
                    projects.removeAtIndex(index)
                    continue
                }
            }else{
                if project.isFinished == .Finished {
                    projects.removeAtIndex(index)
                    continue
                }
            }
            index++
        }
        
        //添加统计label
        if projects.count != 0{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: 70 + 100))
            let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: 70))
            countLabel.text = "\(projects.count)个项目"
            countLabel.font = projectCountsFont
            countLabel.textColor = projectCountsFontColor
            countLabel.textAlignment = .Center
            countLabel.backgroundColor = UIColor.clearColor()
            footerView.addSubview(countLabel)
            projectTableView.tableFooterView = footerView
        }else{
            projectTableView.tableFooterView = nil
        }
    }
    
    ///更新表格
    func updateTable(){
        self.projectTableView.reloadData()
    }
    
    //MARK: - View Controller Lifecle
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        self.navigationController?.navigationBar.barTintColor = navigationBackground
        self.navigationController?.navigationBar.tintColor = navigationTintColor
        self.navigationController?.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        
        //不显示分割线
        self.projectTableView.separatorStyle = .None
        //上下2个cell的边距
        self.projectTableView.sectionFooterHeight = 13
        self.projectTableView.sectionHeaderHeight = 13

        //设计背景色
        self.projectTableView.backgroundColor = allBackground
        
        if let addImage = UIImage(named: "add"){
            let addImageClick = UIImage(named: "addclick")
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.sharedApplication().statusBarFrame
            //添加按钮
            addProjectButtonSize = addImage.size
            addProjectButton = UIButton(frame: CGRectMake((self.view.bounds.size.width - addImage.size.width)/2 , self.view.bounds.size.height - addImage.size.height - rectNav!.size.height - rectStatus.size.height - addProjectButtonMargin, addImage.size.width, addImage.size.height))
            addProjectButton?.setImage(addImage, forState: .Normal)
            addProjectButton?.setImage(addImageClick, forState: .Highlighted)
            addProjectButton?.addTarget(self, action: "addNewProject", forControlEvents: .TouchUpInside)
            
            //阴影 颜色#9C4E50
            addProjectButton?.layer.shadowColor = UIColor(red: 156/255, green: 78/255, blue: 80/255, alpha: 0.35).CGColor
            addProjectButton?.layer.shadowOffset = CGSize(width: 0, height: 2)
            addProjectButton?.layer.shadowOpacity = 1
            addProjectButton?.layer.shadowRadius = 2.0
            
            self.view.addSubview(addProjectButton!)
            self.view.bringSubviewToFront(addProjectButton!)

        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //配置导航栏
        self.navigationController?.navigationBar.barTintColor = navigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //读取数据按照id顺序排序
        loadData()
        
        //更新表格
        projectTableView.reloadData()

    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (velocity.y > 0.0)
        {
//            projectTableView.bounds = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
//            //向上滑动隐藏导航栏
//            self.navigationController!.navigationBar.hidden = true
            //self.addProjectButton?.hidden = true
        }else
        {
//            projectTableView.bounds = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)
//            //向下滑动显示导航栏
//            self.navigationController!.navigationBar.hidden = false
            //self.addProjectButton?.hidden = false
        }
    }

//    override func  scrollViewDidScroll(scrollView: UIScrollView) {
//        //获取导航栏高度
//        let rectNav = self.navigationController?.navigationBar.frame
//        //获取静态栏的高度
//        let rectStatus = UIApplication.sharedApplication().statusBarFrame
//        //设置按钮位置
//        addProjectButton?.frame = CGRectMake((self.view.bounds.size.width - addProjectButtonSize.width)/2 , self.tableView.contentOffset.y + self.view.bounds.size.height - addProjectButtonSize.height - rectNav!.size.height - rectStatus.size.height - addProjectButtonMargin, addProjectButtonSize.width, addProjectButtonSize.height)
//    }
    
    // MARK: - 跳转动作
    ///弹出完成百分比view    
    func showProcessChange(oldPercent: Double, newPercent: Double, name: String){
        self.oldPercent = Int(oldPercent)
        self.increasePercent = Int(oldPercent)
        self.newPercent = Int(newPercent)
        
        //整体通知
        let rect = UIScreen.mainScreen().bounds
        let startPoint = CGPoint(x: rect.width / 2 , y: rect.height / 2 - 120)
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 240))
        showView.backgroundColor = UIColor.whiteColor()
        
        //波浪试图
        waveLoadingIndicator = WaveLoadingIndicator(frame:CGRect(x: 20, y: 60, width: 160, height: 160))
        waveLoadingIndicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        waveLoadingIndicator.progress = Double(self.oldPercent) / 100        
        showView.addSubview(waveLoadingIndicator)

        //分割线
        let blackView = UIView(frame: CGRect(x: 10, y: 45, width: 180, height: 1))
        blackView.backgroundColor = UIColor ( red: 0.8078, green: 0.8118, blue: 0.8157, alpha: 1.0 )
        showView.addSubview(blackView)
        
        //标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.textAlignment = .Center
        titleLabel.text = name
        titleLabel.textColor = UIColor ( red: 0.2784, green: 0.2824, blue: 0.2902, alpha: 1.0 )
        showView.addSubview(titleLabel)
        
        //显示
        self.popover = Popover(options: self.showPercentPopoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(showView,  point: startPoint)
        let timeInterval = 1.0 / (newPercent - oldPercent)
        NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "handleIncreasePercent:", userInfo: nil, repeats: true)
    }
    
    func handleIncreasePercent(timer: NSTimer){
        if self.increasePercent <= self.newPercent{
            self.waveLoadingIndicator.progress = Double(self.increasePercent) / 100
            self.increasePercent++
        }else{
            timer.invalidate()
            self.popover.dismiss()
        }
    }
    
    ///新增进程
    func addProcess(sender: UIButton){
        if let indexPath = self.projectTableView.indexPathForCell(sender.superview as! ProjectTableViewCell){
            //是否是未完成项目
            if projects[indexPath.section].isFinished == .NotFinished || projects[indexPath.section].isFinished == .OverTime{
                 print("添加项目编号为\(indexPath.section)打卡进度")
                //打卡项目
                if projects[indexPath.section].type == .Punch{
                    let process = Process()
                    process.projectID = projects[indexPath.section].id
                    let name = projects[indexPath.section].name
                    let currentTime = NSDate()
                    let dateFormat = NSDateFormatter()
                    dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
                    dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
                    let old = projects[indexPath.section].percent
                    process.recordTime = dateFormat.stringFromDate(currentTime)
                    process.done = 1.0
                    process.remark = "打卡"
                    process.insertProcess()
                    ProcessDate().chengeData(projects[indexPath.section].id, timeDate: currentTime, changeValue: 1.0)
                    projects[indexPath.section].increaseDone(1.0)
                    //更新图标
                    loadData()
                    updateTable()
                    let new = projects[indexPath.section].percent
                    showProcessChange(old, newPercent: new, name: name)
                    
                    //记录进度项目
                }else if projects[indexPath.section].type == .Normal{
                     print("打开项目编号为\(indexPath.section)进度页面")
                    let addProcessViewController = self.storyboard?.instantiateViewControllerWithIdentifier("addProcess") as! AddProcessTableViewController
                    //设置每个cell的项目
                    addProcessViewController.delegate = self
                    addProcessViewController.project = projects[indexPath.section]
                    addProcessViewController.title = "添加进度-\(projects[indexPath.section].name)"
                    //压入导航栏
                    addProcessViewController.view.backgroundColor = allBackground
                    addProcessViewController.modalTransitionStyle = .CoverVertical
                    let navController = UINavigationController.init(rootViewController: addProcessViewController)
                    //状态栏和导航栏不透明
                    navController.navigationBar.translucent = false
                    //设置导航栏颜色
                    navController.navigationBar.barTintColor = otherNavigationBackground
                    //去除导航栏分栏线
//                    navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//                    navController.navigationBar.shadowImage = UIImage()
                    navController.navigationBar.tintColor = navigationTintColor
                    navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
                    self.navigationController?.presentViewController(navController, animated: true, completion: nil)
                    //不记录项目
                }else if projects[indexPath.section].type == .NoRecord{
                    print("项目编号为\(indexPath.section)完成项目")
                    let name = projects[indexPath.section].name
                    projects[indexPath.section].finishDone()
                    //更新图标
                    loadData()
                    updateTable()
                    showProcessChange(0, newPercent: 100, name: name)
                    
                }
            //项目完成
            }else if projects[indexPath.section].isFinished == .Finished{
                let alerController = UIAlertController(title: "是否确定删除该项目？", message: nil, preferredStyle: .ActionSheet)
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                    self.projects[indexPath.section].deleteProject()
                    //更新图标
                    self.loadData()
                    self.updateTable()
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
    }
    
    ///添加新项目
    func addNewProject(){
        let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
        addNewProjectViewController.title = "新增项目"
        addNewProjectViewController.tableState = .Add
        //设置view颜色
        addNewProjectViewController.view.backgroundColor = allBackground
        addNewProjectViewController.modalTransitionStyle = .CoverVertical
        let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
        //状态栏和导航栏不透明
        navController.navigationBar.translucent = false
        //设置导航栏颜色
        navController.navigationBar.barTintColor = otherNavigationBackground
        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
         //UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    ///单个项目页面
    func getMoreInfor(sender: UIButton){
        if let indexPath = self.projectTableView.indexPathForCell(sender.superview as! ProjectTableViewCell){
            if projects[indexPath.section].type != .NoRecord {
                print("打开项目编号为\(indexPath.section)统计页面")
                let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Statistics") as! StatisticsViewController
                //设置view背景色
                statisticsViewController.view.backgroundColor = allBackground
                //设置每个cell的项目
                statisticsViewController.project = projects[indexPath.section]
                
                //修改样式
                self.navigationController?.navigationBar.barTintColor = otherNavigationBackground
                self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
                self.navigationController?.navigationBar.shadowImage = nil
                
                //压入导航栏
                self.navigationController?.pushViewController(statisticsViewController, animated: true)
            }else{
                print("打开项目编号为\(indexPath.section)编辑页面")
                let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
                addNewProjectViewController.title = projects[indexPath.section].name
                addNewProjectViewController.tableState = .Edit
                addNewProjectViewController.view.backgroundColor = allBackground
                addNewProjectViewController.modalTransitionStyle = .CoverVertical
                let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
                //状态栏和导航栏不透明
                navController.navigationBar.translucent = false
                //设置导航栏颜色
                navController.navigationBar.barTintColor = otherNavigationBackground
                //去除导航栏分栏线
//                navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//                navController.navigationBar.shadowImage = UIImage()
                navController.navigationBar.tintColor = navigationTintColor
                navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
                self.navigationController?.presentViewController(navController, animated: true, completion: nil)
                addNewProjectViewController.project = projects[indexPath.section]
            }

        }
    }


    
    // MARK: - UITableViewDataSource
    ///确认节数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //表格类型
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            return 1
            //项目表格
        case tableViewTag.ProjectsTable:
            return projects.count
            //标签表格
        case tableViewTag.TagsTable:
            return 1
        default:
            return 0
        }
    }

    ///确定每行高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //表格类型
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            return tableViewHeight
            //项目表格
        case tableViewTag.ProjectsTable:
            return tableViewHeight
            //标签表格
        case tableViewTag.TagsTable:
            return tableViewHeight
        default:
            return 0
        }
    }
    
    ///确定行数
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        //表格类型
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            return 3
            //项目表格
        case tableViewTag.ProjectsTable:
            return 1
            //标签表格
        case tableViewTag.TagsTable:
            return 3
        default:
            return 0
        }
    }
    
    ///配置cell内容
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) ->
        UITableViewCell {
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.text = self.texts[indexPath.row]
            if indexPath.row == 0{
                let isShowAllSwitch = UISwitch(frame: CGRect(x: self.view.bounds.width - 60, y: 5, width: 40, height: 40))
                isShowAllSwitch.onTintColor = switchColor
                isShowAllSwitch.on = isShowNotBegin
                isShowAllSwitch.addTarget(self, action: "showNotBegin", forControlEvents: .ValueChanged)
                cell.addSubview(isShowAllSwitch)
            }
            if indexPath.row == 1{
                cell.accessoryType = .DisclosureIndicator
                if isShowFinished {
                    cell.textLabel?.text = "未完成"
                }
            }
            return cell
            
            //项目表格
        case tableViewTag.ProjectsTable:
                let cell = projectTableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
            
                let addProcessButtonTag = 1000
                let getMoreInforTag = 1001
                //复用清除之前的按钮
                for subView in cell.subviews{
                    if subView.tag == addProcessButtonTag || subView.tag == getMoreInforTag{
                        subView.removeFromSuperview()
                    }
                }
                
                //配置cell
                cell.project = projects[indexPath.section]
                cell.roundBackgroundColor = allBackground
                cell.needPercent = true
                cell.percent = projects[indexPath.section].percent
                
                //if projects[indexPath.section].isFinished == .NotFinished{
                //新增进度按钮
                let addProcessFrame = CGRectMake(cell.frame.width - cell.frame.height - self.cellMargin , 0, cell.frame.height , cell.frame.height)
                let addProcessButton = UIButton(frame: addProcessFrame)
                
                
                //根据不同任务类型使用不同的图标
                var imageString = ""
                var selectString = ""
                switch(projects[indexPath.section].type){
                case .NoRecord:
                    if projects[indexPath.section].isFinished == .NotBegined{
                        imageString = "norecordno"
                        selectString = "norecordno"
                    }else{
                        imageString = "norecord"
                        selectString = "norecordclick"
                    }
                case .Punch:
                    if projects[indexPath.section].isFinished == .NotBegined{
                        imageString = "punchno"
                        selectString = "punchno"
                    }else{
                        imageString = "punch"
                        selectString = "punchclick"
                    }
                case .Normal:
                    if projects[indexPath.section].isFinished == .NotBegined{
                        imageString = "recordno"
                        selectString = "recordno"
                    }else{
                        imageString = "record"
                        selectString = "recordclick"
                    }
                default:break
                }
                
                if projects[indexPath.section].isFinished == .Finished{
                    imageString = "filedelete"
                    selectString = "filedeleteclick"
                }
                
                let processView = UIProgressView(frame: cell.frame)
                processView.setProgress(1.0 , animated: true)
                cell.addSubview(processView)
                cell.backgroundView = processView
                
                //读取图片
                let buttonImage = UIImage(named: imageString)
                let buttonSelectedIamge = UIImage(named: selectString)
                //进行缩
                addProcessButton.setImage(buttonImage, forState: .Normal)
                addProcessButton.setImage(buttonSelectedIamge, forState: .Highlighted)
                addProcessButton.addTarget(self, action: "addProcess:", forControlEvents: .TouchUpInside)
                addProcessButton.tag = addProcessButtonTag
                //添加按钮
                cell.addSubview(addProcessButton)
                //}
                
                //单个项目页面按钮
                let getMoreInfor = UIButton(frame: CGRectMake(0, 0, cell.frame.width - cell.frame.height - self.cellMargin, cell.frame.height))
                getMoreInfor.setBackgroundImage(.None, forState: .Normal)
                getMoreInfor.setBackgroundImage(.None, forState: .Highlighted)
                getMoreInfor.addTarget(self, action: "getMoreInfor:", forControlEvents: .TouchUpInside)
                getMoreInfor.tag = getMoreInforTag
                cell.addSubview(getMoreInfor)
                return cell
            //标签表格
        case tableViewTag.TagsTable:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.text = self.texts[indexPath.row]
            
            return cell
        default:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            return cell
        }
    }
  
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //表格类型
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            if indexPath.row == 1 {
                isShowFinished = !isShowFinished
                loadData()
                self.projectTableView.reloadData()
            }
             self.popover.dismiss()
            //项目表格
        case tableViewTag.ProjectsTable:
            return
            //标签表格
        case tableViewTag.TagsTable:
             self.popover.dismiss()
        default:
            return
        }
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ivc = segue.destinationViewController as? EditProjectTableViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "addProject":
                    ivc.title = "新增项目"
                    ivc.tableState = .Add
                default: break
                }
            }
        }else if let ivc = segue.destinationViewController as? TagsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "showTags":
                    ivc.title = "标签"
                    ivc.delegate = self
                  default: break
                }
            }
        }
    }
    // MARK: - Popover presentation delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func popoverPresentationController(popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverToRect rect: UnsafeMutablePointer<CGRect>, inView view: AutoreleasingUnsafeMutablePointer<UIView?>) {
        print("Will reposition popover")
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        print("Did Dismiss popover")
    }
    
    func opoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("Should Dismiss popover")
        print(popoverPresentationController.popoverBackgroundViewClass)
        return true
    }
        
    // MARK: - TagsView delegate
    func passSelectedTag(selectedTag: Tag?){
        selectTag = selectedTag
        return
    }
    
    // MARK: - addProcess delegate
    func addProcessTableViewAct(old: Double, new: Double, name: String){
        showProcessChange(old, newPercent: new, name: name)
    }
    
}