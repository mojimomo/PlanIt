//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
import Popover

class ProjectViewController: UIViewController, TagsViewDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource ,AddProcessDelegate, UIScrollViewDelegate ,UIGestureRecognizerDelegate, EditProjectTableViewDelegate{

    @IBOutlet weak var tagsBarButton: UIBarButtonItem!
    @IBOutlet weak var projectTableView: UITableView!{
        didSet{
            projectTableView.tag = tableViewTag.ProjectsTable
            projectTableView.delegate = self
            projectTableView.dataSource = self
        }
    }
    @IBOutlet weak var projectName: UILabel!
    ///故事版id
    private struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    ///表格标签
    private struct tableViewTag {
        static let MuneTable = 0
        static let TagsTable = 1
        static let ProjectsTable = 2
    }
    let addProcessButtonTag = 1000
    ///没有数据图像的路劲
    private var noDataImageString = ["bike", "book2"]
    ///没有数据图像视图
    private var notDataImageView : UIImageView!
    ///其他表格高度
    let tableViewHeight : CGFloat = 44
    ///菜单表格高度
    let MenuTableViewHeight : CGFloat = 60
    ///新增按钮尺寸
    private var addButtonSize : CGSize!
    ///选择的标签
    private var selectTag : Tag?
    ///菜单
    private var popover: Popover!
    ///菜单文字
    private var texts = ["显示未开始", "已完成", "设置"]
    ///菜单弹窗参数
    private var popoverOptions: [PopoverOption] = [
        .Type(.Down),
        .CornerRadius(0.0),
        .ArrowSize(CGSize(width: 0.0, height: 0.0)),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    ///提示弹窗参数
    private var showPercentPopoverOptions: [PopoverOption] = [
        .Type(.Down),
        .CornerRadius(8.0),
        .ArrowSize(CGSize(width: 0.0, height: 0.0)),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .Animation(.None)
    ]
    ///显示未开始项目
    var isShowNotBegin : Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("isShowNotBegin") as Bool!
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isShowNotBegin")
        }
    }
    ///显示未开始项目
    var isShowFinished : Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("isShowFinished") as Bool!
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isShowFinished")
        }
    }
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
    
    ///呼出标签栏
    @IBAction func callTag(sender: UIBarButtonItem) {
        let tagsViewControl = self.storyboard?.instantiateViewControllerWithIdentifier("ShowTags") as! TagsViewController
        tagsViewControl.title = "标签"
        tagsViewControl.view.backgroundColor = UIColor.whiteColor()
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
//        navController.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor(), size: CGSize(width: 1, height: 1))
//, forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage.imageWithColor(UIColor.colorFromHex("#525659"), size: CGSize(width: 0.5, height: 0.5))
        
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)    }
    
    ///点击点开抽屉菜单
    @IBAction func callMenu(sender: AnyObject) {
        //获取此页面的抽屉菜单页
        if let drawer = self.navigationController?.parentViewController as? KYDrawerController{
            //设置菜单页状态
            drawer.setDrawerState( .Opened, animated: true)
        }
        let startPoint = CGPoint(x: self.view.frame.width / 2, y: 0)
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200 + rectStatus.size.height))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatus.size.height + 12))
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
    ///打开菜单
    func handleCallOptions(){
        print("打开菜单页面")
        let muneViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Options") as! OptionsTableViewController
        
        //压入导航栏
        self.navigationController?.pushViewController(muneViewController, animated: true)
    }
    
    //点击是否显示未开始
    func showNotBegin(){
        isShowNotBegin = !isShowNotBegin
        updateTable()
    }
    
    ///根据超时快速排序
    func qsortProjectByOuttime(input: [Project]) -> [Project]{
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0.outTime > pivot.outTime }
            let greater = rest.filter { $0.outTime <= pivot.outTime }
            return qsortProjectByOuttime(lesser) + [pivot] + qsortProjectByOuttime(greater)
        } else {
            return []
        }
    }
    
    ///根据超时快速排序
    func qsortProjectByBeginTime(input: [Project]) -> [Project]{
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0.beginTimeDate.timeIntervalSince1970 < pivot.beginTimeDate.timeIntervalSince1970 }
            let greater = rest.filter { $0.beginTimeDate.timeIntervalSince1970 >= pivot.beginTimeDate.timeIntervalSince1970 }
            return qsortProjectByBeginTime(lesser) + [pivot] + qsortProjectByBeginTime(greater)
        } else {
            return []
        }
    }
    
    ///加载所有数据
    func loadData(){
        //读取原始数据
        if selectTag != nil{
            if selectTag!.id == -1{
                title = "无标签"
                projects.removeAll()
                let tagMaps = TagMap().loadAllData()
                let allProjects = Project().loadAllData()
                if tagMaps.count != 0{
                    //添加没有标签的
                    for project in allProjects{
                        for tagMap in tagMaps{
                            if tagMap.projectID == project.id{
                                break
                            }else if tagMap ==  tagMaps.last{
                                projects.append(project)
                            }
                        }
                    }
                }else{
                    projects = allProjects
                }

            }else{
                title = selectTag?.name
                projects = TagMap().searchProjectFromTag(selectTag!)
            }

        }else{
            projects = Project().loadAllData()
            if isShowFinished{
               title = "已完成项目"
            }else{
                title = "全部项目"
            }
        }
        
        var index = 0
        var notBeginedProjects = [Project]()
        
        for project in projects {
            if project.isFinished == .NotBegined {
                projects.removeAtIndex(index)
                notBeginedProjects.append(project)
                continue
            }

            //显示结束
            if isShowFinished {
                if project.isFinished != .Finished {
                    projects.removeAtIndex(index)
                    continue
                }
            }else{
                if project.isFinished == .Finished {
                    if((NSUserDefaults.standardUserDefaults().boolForKey("IsFirstLaunchFinishedProject") as Bool!) == false){
                        let startPoint = CGPoint(x: self.view.frame.width - 30, y: 55)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsFirstLaunchFinishedProject")
                        callFirstRemain("点击查看已完成", startPoint: startPoint)
                    }
                    projects.removeAtIndex(index)
                    continue
                }
            }
            index++
        }
        projects = qsortProjectByOuttime(projects)
        
        //显示未开始
        if !isShowNotBegin && !isShowFinished{
            notBeginedProjects = qsortProjectByBeginTime(notBeginedProjects)
            projects = projects + notBeginedProjects
        }
        
        //添加统计label
        notDataImageView?.removeFromSuperview()
        if projects.count != 0{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: 100 + 100))
            let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width , height: 100))
            countLabel.text = "\(projects.count)个项目"
            countLabel.font = projectCountsFont
            countLabel.textColor = projectCountsFontColor
            countLabel.textAlignment = .Center
            countLabel.backgroundColor = UIColor.clearColor()
            footerView.addSubview(countLabel)
            projectTableView.tableFooterView = footerView
        }else{
            projectTableView.tableFooterView = nil
            let count = UInt32(noDataImageString.count)
            let index = Int(arc4random() % count)
            notDataImageView = UIImageView(image: UIImage(named: noDataImageString[index]))
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.sharedApplication().statusBarFrame
            notDataImageView.center = CGPoint(x: UIScreen.mainScreen().bounds.width / 2, y: (UIScreen.mainScreen().bounds.height - (rectNav?.height)! - rectStatus.height) / 2 - (rectNav?.height)! - rectStatus.height)
            self.projectTableView.addSubview(notDataImageView)
        }
    }
    
    ///更新表格
    func updateTable(){
        loadData()
        projectTableView.reloadData()
    }
    
    ///长按响应函数
    func handleLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state ==  .Began{
            let point = gesture.locationInView(self.projectTableView)
            let indexPath = self.projectTableView.indexPathForRowAtPoint(point)
            if indexPath != nil {
                let cell = projectTableView.cellForRowAtIndexPath(indexPath!) as! ProjectTableViewCell
                cell.isShowState = true
                
                //延迟消失
                let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(queue) { () -> Void in
                    NSThread.sleepForTimeInterval(2.5)
                    dispatch_sync( dispatch_get_main_queue(), { () -> Void in
                        cell.isShowState = false
                    })
                }
            }
        }
    }
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //去除滚动条
        self.projectTableView.showsVerticalScrollIndicator = false
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
        
        
        //手势代理
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        
        if let addImage = UIImage(named: "add"){
            let addImageClick = UIImage(named: "addclick")
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.sharedApplication().statusBarFrame
            //添加按钮
            addProjectButtonSize = addImage.size
            addButtonSize = addImage.size
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
        
        //创建长按选项
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGestureRecognizer.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //配置导航栏
        self.navigationController?.navigationBar.barTintColor = navigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //读取数据按照id顺序排序
        updateTable()
        
        //判断是否第一次打开此页面
        if((NSUserDefaults.standardUserDefaults().boolForKey("IsFirstLaunchProjectView") as Bool!) == false){
            print("第一次打开项目页面")
            //设置为非第一次打开此页面
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsFirstLaunchProjectView")
            
            //创建引导项目
            let newTag = Tag(name: "生活")
            newTag.insertTag()
            let newTag2 = Tag(name: "锻炼")
            newTag2.insertTag()
            let newTag3 = Tag(name: "学习")
            newTag3.insertTag()
            
            updateTable()
            //设置引导弹窗
            callFirstRemain("点击创建新项目", view: addProjectButton!, type: .Up, showHandler: nil, dismissHandler: nil)
        }else if((NSUserDefaults.standardUserDefaults().boolForKey("IsFirstLaunchNormalProject") as Bool!) == false){
            print("第一次添加进度项目")
            var index = 0
            for project in projects{
                if project.type == .Punch ||  project.type == .Normal{
                    let indexPath = NSIndexPath(forRow: 0, inSection: index)
                    if let cell = self.projectTableView.cellForRowAtIndexPath(indexPath){
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsFirstLaunchNormalProject")
                        updateTable()
                        self.callFirstRemain("打卡/记录进度项目", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                            self.callFirstRemain("点击查看详情", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                                self.callFirstRemain("长按查看状态", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                                    for subView in cell.subviews{
                                        if subView.tag == self.addProcessButtonTag {
                                            self.callFirstRemain("点击添加进度", view: subView)
                                            break
                                        }
                                    }
                                })
                            })
                        })
                    }
                    break
                }
                index++
            }
        }else if((NSUserDefaults.standardUserDefaults().boolForKey("IsFirstLaunchNoRecordProject") as Bool!) == false){
            print("第一次添加非进度项目")
            var index = 0
            for project in projects{
                if project.type == .NoRecord{
                    let indexPath = NSIndexPath(forRow: 0, inSection: index)
                    if let cell = self.projectTableView.cellForRowAtIndexPath(indexPath){
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsFirstLaunchNoRecordProject")
                        updateTable()
                        self.callFirstRemain("不记录进度项目", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                            self.callFirstRemain("点击修改项目", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                                self.callFirstRemain("长按查看状态", view: cell, type: .Down, showHandler: nil, dismissHandler: { () -> () in
                                    for subView in cell.subviews{
                                        if subView.tag == self.addProcessButtonTag {
                                            self.callFirstRemain("点击完成项目", view: subView)
                                            break
                                        }
                                    }
                                })
                            })
                        })
                    }
                    break
                }
                index++
            }
        }
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
        //整体通知
        let rect = UIScreen.mainScreen().bounds
        let startPoint = CGPoint(x: rect.width / 2 , y: rect.height / 2 - 120)
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 240))
        showView.backgroundColor = UIColor.whiteColor()
        
        //波浪视图
        let waveLoadingIndicator = WaveLoadingIndicator(frame:CGRect(x: 20, y: 60, width: 160, height: 160))
        waveLoadingIndicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        waveLoadingIndicator.progress = oldPercent / 100
        showView.addSubview(waveLoadingIndicator)

        //分割线
        let blackView = UIView(frame: CGRect(x: 10, y: 45, width: 180, height: 1))
        blackView.backgroundColor = UIColor ( red: 0.9453, green: 0.9453, blue: 0.9453, alpha: 0.8 )
        showView.addSubview(blackView)
        
        //标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.textAlignment = .Center
        titleLabel.text = name
        titleLabel.textColor = UIColor ( red: 0.2784, green: 0.2824, blue: 0.2902, alpha: 1.0 )
        showView.addSubview(titleLabel)
        
        //显示
        let popover = Popover(options: self.showPercentPopoverOptions, showHandler: nil, dismissHandler:  {() -> () in
            self.updateTable()
            })
        popover.show(showView,  point: startPoint)
        
        //总时间 1000毫秒
        let totalTime = 2000
        //次数
        var timeOut = Int(newPercent -  oldPercent + 1)
        //周期
        let period : UInt64 = UInt64( totalTime / timeOut)
        //增量
        let addEveryTime = 1.0
        //当前百分比
        var currentPercent = oldPercent
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), period * NSEC_PER_MSEC, 0)
        dispatch_source_set_event_handler(timer, { () -> Void in
            //倒计时结束，关闭
            if (timeOut <= 0) {
                //关闭定时器
                dispatch_source_cancel(timer)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //关闭弹窗
                    if newPercent == 100.0{
                        //完成视图
                        waveLoadingIndicator.removeFromSuperview()
                        
                        let successView = UIImageView(image: UIImage(named: "oval"))
                        successView.frame = CGRect(x: 20, y: 60, width: 160, height: 160)
                        showView.addSubview(successView)
                        
                        let fillView = UIImageView(image: UIImage(named: "projectFinish"))
                        fillView.frame = CGRect(x: 20, y: 60, width: 160, height: 160)
                        showView.addSubview(fillView)
                        fillView.transform = CGAffineTransformMakeScale(0.0, 0.0)
                        UIView.animateWithDuration(1 , delay: 0,
                            usingSpringWithDamping: 1,
                            initialSpringVelocity: 0,
                            options: .CurveEaseInOut,
                            animations: {
                                fillView.transform = CGAffineTransformIdentity
                            }){ _ in
                                
                        }
                        let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
                        let queue = dispatch_get_global_queue(qos, 0)
                        dispatch_async(queue) { () -> Void in
                            NSThread.sleepForTimeInterval(1)
                            dispatch_sync( dispatch_get_main_queue(), { () -> Void in
                                popover.dismiss()
                            })
                        }
                    }else{
                        popover.dismiss()
                    }
                })
            } else {
                //设置百分比
                waveLoadingIndicator.progress = currentPercent / 100
                currentPercent = currentPercent + addEveryTime
            }
            timeOut-- 
        })
        dispatch_resume(timer)
    }

    
    ///弹出完成百分比view
    func showProcessFinish(name: String){
        //整体通知
        let rect = UIScreen.mainScreen().bounds
        let startPoint = CGPoint(x: rect.width / 2 , y: rect.height / 2 - 120)
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 240))
        showView.backgroundColor = UIColor.whiteColor()
        
        //完成视图
        let successView = UIImageView(image: UIImage(named: "projectFinish"))
        successView.frame = CGRect(x: 20, y: 60, width: 160, height: 160)
        showView.addSubview(successView)
        successView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(1 , delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .CurveEaseInOut,
            animations: {
                successView.transform = CGAffineTransformIdentity
            }){ _ in
                
        }
        //分割线
        let blackView = UIView(frame: CGRect(x: 10, y: 45, width: 180, height: 1))
        blackView.backgroundColor = UIColor ( red: 0.9453, green: 0.9453, blue: 0.9453, alpha: 0.8 )
        showView.addSubview(blackView)
        
        //标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.textAlignment = .Center
        titleLabel.text = name
        titleLabel.textColor = UIColor ( red: 0.2784, green: 0.2824, blue: 0.2902, alpha: 1.0 )
        showView.addSubview(titleLabel)
        
        //显示
        let popover = Popover(options: self.showPercentPopoverOptions, showHandler: nil, dismissHandler: {() -> () in
            self.updateTable()
            })

        popover.show(showView,  point: startPoint)
        
        let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) { () -> Void in
            NSThread.sleepForTimeInterval(1)
            dispatch_sync( dispatch_get_main_queue(), { () -> Void in
                popover.dismiss()
            })
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
                    process.insertProcess()
                    ProcessDate().chengeData(projects[indexPath.section].id, timeDate: currentTime, changeValue: 1.0)
                    projects[indexPath.section].increaseDone(1.0)
                    let new = projects[indexPath.section].percent
                    showProcessChange(old, newPercent: new, name: name)                    

                    MobClick.event("2001")
                    //记录进度项目
                }else if projects[indexPath.section].type == .Normal{
                     print("打开项目编号为\(indexPath.section)进度页面")
                    let addProcessViewController = self.storyboard?.instantiateViewControllerWithIdentifier("addProcess") as! AddProcessTableViewController
                    //设置每个cell的项目
                    addProcessViewController.delegate = self
                    addProcessViewController.project = projects[indexPath.section]
                    addProcessViewController.title = "\(projects[indexPath.section].name)"
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
                    showProcessFinish(name)
                    
                    MobClick.event("2003")
                }
            //项目完成
            }else if projects[indexPath.section].isFinished == .Finished{
                callAlertAsk("是否确定删除该项目？", okHandler: {(UIAlertAction) -> Void in
                    self.projects[indexPath.section].deleteProject()
                    self.callAlertSuccess("删除成功!")
                    }, cancelandler: nil, completion: nil)
            }else if projects[indexPath.section].isFinished == .NotBegined{
                var type = ""
                switch projects[indexPath.section].type{
                case .Normal:
                    type = "记录进度"
                case .Punch:
                    type = "打卡"
                case .NoRecord:
                    type = "标记完成"
                default: break
                }
                callAlert("项目未开始",message: "修改项目开始时间以\(type)！")
            }
        }
    }
    
    ///添加新项目
    func addNewProject(){
        let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
        addNewProjectViewController.title = "新增项目"
        addNewProjectViewController.tableState = .Add
        addNewProjectViewController.delegate = self
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
        // Creating shadow path for better performance

//        navController.navigationBar.layer.shadowColor = navigationShadowsColor.CGColor
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
            return MenuTableViewHeight
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
            cell.textLabel?.textColor = navigationFontColor
            cell.textLabel?.font = UIFont(name: "PingFangSC-Light", size: 17.0)!
            if indexPath.row == 0{
                let isShowAllSwitch = UISwitch(frame: CGRect(x: self.view.bounds.width - 65, y: 14, width: 40, height: MenuTableViewHeight))
                isShowAllSwitch.onTintColor = switchColor
                isShowAllSwitch.on = !isShowNotBegin
                isShowAllSwitch.addTarget(self, action: "showNotBegin", forControlEvents: .ValueChanged)
                cell.addSubview(isShowAllSwitch)
            }
            if indexPath.row == 1{
                cell.accessoryType = .DisclosureIndicator
                if isShowFinished {
                    cell.textLabel?.text = "进行中"
                }
            }
            return cell
            
            //项目表格
        case tableViewTag.ProjectsTable:
                let cell = projectTableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
                
                //复用清除之前的按钮
                for subView in cell.subviews{
                    if subView.tag == addProcessButtonTag {
                        subView.removeFromSuperview()
                    }
                }
                
                //配置cell
                cell.project = projects[indexPath.section]
                cell.roundBackgroundColor = allBackground
                cell.needPercent = true
                cell.percent = projects[indexPath.section].percent
                cell.isShowState = false
                
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
                selectTag = nil
                updateTable()
            }else if indexPath.row == 2{
                handleCallOptions()
            }
             self.popover.dismiss()
            //项目表格
        case tableViewTag.ProjectsTable:
                if projects[indexPath.section].type != .NoRecord {
                    print("打开项目编号为\(indexPath.section)统计页面")
                    let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Statistics") as! StatisticsViewController
                    //设置view背景色
                    statisticsViewController.view.backgroundColor = allBackground
                    //设置每个cell的项目
                    statisticsViewController.project = projects[indexPath.section]
                    
                    
                    //压入导航栏
                    self.navigationController?.pushViewController(statisticsViewController, animated: true)
                }else{
                    print("打开项目编号为\(indexPath.section)编辑页面")
                    let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
                    addNewProjectViewController.title = projects[indexPath.section].name
                    addNewProjectViewController.tableState = .Edit
                    addNewProjectViewController.delegate = self
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
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        //scrollView已经有拖拽手势，直接拿到scrollView的拖拽手势
//        let pan = scrollView.panGestureRecognizer
//        //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
//        let velocity = pan.velocityInView(scrollView).y
//        
//        if velocity < -5 {
//            
//            //向上拖动，隐藏导航栏
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//
//            //获取静态栏的高度
//            let rectStatus = UIApplication.sharedApplication().statusBarFrame
//            addProjectButton?.frame = CGRectMake          ((self.view.bounds.size.width - addButtonSize.width)/2 , self.view.bounds.size.height - addButtonSize.height - rectStatus.size.height - addProjectButtonMargin, addButtonSize.width, addButtonSize.height)
//        }
//        else if velocity > 5 {
//            //向下拖动，显示导航栏
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//
//            //获取导航栏高度
//            let rectNav = self.navigationController?.navigationBar.frame
//            //获取静态栏的高度
//            let rectStatus = UIApplication.sharedApplication().statusBarFrame
//            addProjectButton?.frame = CGRectMake          ((self.view.bounds.size.width - addButtonSize.width)/2 , self.view.bounds.size.height - addButtonSize.height - (rectNav?.size.height)! - rectStatus.size.height - addProjectButtonMargin, addButtonSize.width, addButtonSize.height)
//            
//        }
//        else if velocity == 0{
//            
//            //停止拖拽
//        }
    }
    
    
    
    func toggle() {
        UIView.animateWithDuration(2) {
            self.navigationController?.navigationBarHidden = self.navigationController?.navigationBarHidden == false
        }
    }

    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count >= 2 {
            return true
        }
        return false
    }
    // MARK: - EditProjectTableViewDelegate
    func goBackAct(state: EditProjectBackState){
        switch state{
        case .AddSuccess:
            callAlertSuccess("创建成功!")
//        case .DeleteSucceess:
//            callAlertSuccess("删除成功!")
        case .EditSucceess:
            callAlertSuccess("编辑成功!")
        default: break
        }
    }
}



extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}
