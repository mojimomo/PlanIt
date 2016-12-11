//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

import Popover
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ProjectViewController: UIViewController, TagsViewDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource ,AddProcessDelegate, UIScrollViewDelegate ,UIGestureRecognizerDelegate, EditProjectTableViewDelegate{

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var addProjectButton: UIButton!
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
    fileprivate struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    ///表格标签
    fileprivate struct tableViewTag {
        static let MuneTable = 0
        static let TagsTable = 1
        static let ProjectsTable = 2
    }
    let addProcessButtonTag = 1000
    ///没有数据图像的路劲
    fileprivate var noDataImageString = [NSLocalizedString("bike", comment: ""), NSLocalizedString("book", comment: "")]
    ///没有数据图像视图
    fileprivate var notDataImageView : UIImageView!
    ///其他表格高度
    let tableViewHeight : CGFloat = 44
    ///菜单表格高度
    let MenuTableViewHeight : CGFloat = 60
    ///选择的标签
    fileprivate var selectTag : Tag?
    ///菜单
    fileprivate var popover: Popover!
    ///状态栏遮盖
    fileprivate var statusView: UIView!
    ///菜单文字
    fileprivate var texts = [NSLocalizedString("Show Scheduled", comment: ""), NSLocalizedString("Completed", comment: ""), NSLocalizedString("Settings", comment: "")]
    ///菜单弹窗参数
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .cornerRadius(0.0),
        .arrowSize(CGSize(width: 0.0, height: 0.0)),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    //获取静态栏的高度
    let rectStatusHeight = UIApplication.shared.statusBarFrame.height
    //导航栏的高度
    let navBarHeight : CGFloat = 44.0
    ///提示弹窗参数
    fileprivate var showPercentPopoverOptions: [PopoverOption] = [
        .type(.down),
        .cornerRadius(8.0),
        .arrowSize(CGSize(width: 0.0, height: 0.0)),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .animation(.none)
    ]
    ///显示未开始项目
    var isShowNotBegin : Bool{
        get{
            return UserDefaults.standard.bool(forKey: "isShowNotBegin") as Bool!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "isShowNotBegin")
        }
    }
    ///显示未开始项目
    var isShowFinished : Bool{
        get{
            return UserDefaults.standard.bool(forKey: "isShowFinished") as Bool!
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "isShowFinished")
        }
    }

    ///项目列表
    var projects = [Project]()
    var orginProjects = [Project]()
    ///cell边距
    var cellMargin : CGFloat = 15.0
//    ///添加新项目底部边距
//    var addProjectButtonMargin : CGFloat = 20.0
//    ///添加按钮尺寸
//    var addProjectButtonSize : CGSize = CGSize(width: 0, height: 0)
    
    ///呼出标签栏
    @IBAction func callTag(_ sender: UIBarButtonItem) {
        let tagsViewControl = self.storyboard?.instantiateViewController(withIdentifier: "ShowTags") as! TagsViewController
        tagsViewControl.title = NSLocalizedString("Tags", comment: "")
        tagsViewControl.view.backgroundColor = UIColor.white
        tagsViewControl.delegate = self
        
        //设置加载动画
        let transition = CATransition()
        transition.duration = 1.0
        transition.type = kCATransitionPush //推送类型
        transition.subtype = kCATransitionFromLeft //从左侧
        tagsViewControl.view.layer.add(transition, forKey: "Reveal")
        
        let navController = UINavigationController.init(rootViewController: tagsViewControl)
        //状态栏和导航栏不透明
        navController.navigationBar.isTranslucent = false
        //设置导航栏颜色
        navController.navigationBar.barTintColor = otherNavigationBackground
        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor(), size: CGSize(width: 1, height: 1))
//, forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage.imageWithColor(UIColor.colorFromHex("#525659"), size: CGSize(width: 0.5, height: 0.5))
        
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.present(navController, animated: true, completion: nil)    }
    
    ///点击点开抽屉菜单
    @IBAction func callMenu(_ sender: AnyObject) {
        //获取此页面的抽屉菜单页
        if let drawer = self.navigationController?.parent as? KYDrawerController{
            //设置菜单页状态
            drawer.setDrawerState( .opened, animated: true)
        }
        let startPoint = CGPoint(x: self.view.frame.width / 2, y: 0)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200 + rectStatusHeight))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatusHeight + 12))
        tableView.tag = tableViewTag.MuneTable
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView,  point: startPoint)
    }

    ///点击创建新项目
    @IBAction func addNewProject(_ sender: UIButton) {
        addNewProject()
    }
    
    // MARK: - Func
    func toggle() {
        UIView.animate(withDuration: 2, animations: {
            self.navigationController?.isNavigationBarHidden = self.navigationController?.isNavigationBarHidden == false
        }) 
    }
    
    fileprivate func checkTableView(){
        //添加统计label
        notDataImageView?.removeFromSuperview()
        projectTableView?.tableFooterView = nil
        if projects.count != 0{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 100 + 100))
            let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 100))
            countLabel.text = "\(projects.count) " + NSLocalizedString("projects", comment: "项目列表底端计数")
            countLabel.font = projectCountsFont
            countLabel.textColor = projectCountsFontColor
            countLabel.textAlignment = .center
            countLabel.backgroundColor = UIColor.clear
            footerView.addSubview(countLabel)
            projectTableView?.tableFooterView = footerView
        }else{
            let count = UInt32(noDataImageString.count)
            let index = Int(arc4random() % count)
            notDataImageView = UIImageView(image: UIImage(named: noDataImageString[index]))
            //获取导航栏高度
            notDataImageView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height - navBarHeight - rectStatusHeight) / 2 - navBarHeight - rectStatusHeight)
            self.projectTableView?.addSubview(notDataImageView)
        }
    }
    
    ///打开菜单
    func handleCallOptions(){
        print("打开菜单页面")
        let muneViewController = self.storyboard?.instantiateViewController(withIdentifier: "Options") as! OptionsTableViewController
        
        //压入导航栏
        self.navigationController?.pushViewController(muneViewController, animated: true)
    }
    
    ///隐藏导航栏
    func setNavBarHidden(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if statusView == nil{
            statusView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatusHeight + 12))
            statusView.backgroundColor = allBackground
        }
        self.view.addSubview(statusView)
        self.view.bringSubview(toFront: statusView)
    }
    
    ///显示导航栏
    func setNavBarShown(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        projectTableView.tableHeaderView = nil
        if statusView != nil{
            statusView.removeFromSuperview()
        }
    }
    
    //点击是否显示未开始
    func showNotBegin(){
        isShowNotBegin = !isShowNotBegin
        updateTable()
    }
    
    ///根据超时快速排序
    func qsortProjectByOuttime(_ input: [Project]) -> [Project]{
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0.outTime > pivot.outTime }
            let greater = rest.filter { $0.outTime <= pivot.outTime }
            var output = qsortProjectByBeginTime(lesser) + [pivot]
            output += qsortProjectByBeginTime(greater)
            return output
        } else {
            return []
        }
    }
    
    ///根据超时快速排序
    func qsortProjectByBeginTime(_ input: [Project]) -> [Project]{
        if let (pivot, rest) = input.decompose {
            let lesser = rest.filter { $0.beginTimeDate.timeIntervalSince1970 < pivot.beginTimeDate.timeIntervalSince1970 }
            let greater = rest.filter { $0.beginTimeDate.timeIntervalSince1970 >= pivot.beginTimeDate.timeIntervalSince1970 }
            var output = qsortProjectByBeginTime(lesser) + [pivot]
            output += qsortProjectByBeginTime(greater)
            return output
        } else {
            return []
        }
    }
    
    ///加载所有数据
    func loadData(){
        //读取原始数据
        if selectTag != nil{
            if selectTag!.id == -1{
                title = NSLocalizedString("Untagged", comment: "")
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
            title = NSLocalizedString("All", comment: "首页导航栏标题")
            projects = Project().loadAllData()
            if isShowFinished{
               title = NSLocalizedString("Completed", comment: "首页导航栏标题")
            }
        }
        
        var index = 0
        var notBeginedProjects = [Project]()
        
        for project in projects {
            if project.isFinished == .notBegined {
                projects.remove(at: index)
                notBeginedProjects.append(project)
                continue
            }

            //显示结束
            if isShowFinished {
                if project.isFinished != .finished {
                    projects.remove(at: index)
                    continue
                }
            }else{
                if project.isFinished == .finished {
                    if((UserDefaults.standard.bool(forKey: "IsFirstLaunchFinishedProject") as Bool!) == false){
                        let startPoint = CGPoint(x: self.view.frame.width - 32.5, y: 55)
                        UserDefaults.standard.set(true, forKey: "IsFirstLaunchFinishedProject")
                        callFirstRemain(NSLocalizedString("Check completed projects", comment: ""), startPoint: startPoint)
                    }
                    projects.remove(at: index)
                    continue
                }
            }
            index += 1
        }
        projects = qsortProjectByOuttime(projects)
        
        //显示未开始
        if !isShowNotBegin && !isShowFinished{
            notBeginedProjects = qsortProjectByBeginTime(notBeginedProjects)
            projects = projects + notBeginedProjects
        }

    }
    
    ///更新表格
    func updateTable(){
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.loadData()
            DispatchQueue.main.async{
                self.indicator.stopAnimating()
                self.projectTableView.reloadData()
                self.checkTableView()
                self.indicator.isHidden = true
            }
        }
    }
    
    ///长按响应函数
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state ==  .began{
            let point = gesture.location(in: self.projectTableView)
            let indexPath = self.projectTableView.indexPathForRow(at: point)
            if indexPath != nil {
                let cell = projectTableView.cellForRow(at: indexPath!) as! ProjectTableViewCell
                if cell.project.isFinished == .finished{
                    return
                }
                for subView in cell.subviews{
                    if subView.tag == addProcessButtonTag {
                        if subView.pointInView(subView.convert(point, from: self.projectTableView)) == false{
                            cell.isShowState = true
                            //延迟消失
                            let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                            queue.async { () -> Void in
                                Thread.sleep(forTimeInterval: 2.5)
                                DispatchQueue.main.sync(execute: { () -> Void in
                                    cell.isShowState = false
                                })
                            }
                        }
                    }
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
        self.projectTableView.separatorStyle = .none
        //上下2个cell的边距
        self.projectTableView.sectionFooterHeight = 13
        self.projectTableView.sectionHeaderHeight = 13

        //设计背景色
        self.projectTableView.backgroundColor = allBackground
        
        
        //手势代理
        self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        
//        if let addImage = UIImage(named: "add"){
//            let addImageClick = UIImage(named: "addclick")
//
//            //添加按钮
//            addProjectButtonSize = addImage.size
//            addProjectButton = UIButton(frame: CGRectMake(0 , 0, addImage.size.width, addImage.size.height))
//            addProjectButton.setImage(addImage, forState: .Normal)
//            addProjectButton.setImage(addImageClick, forState: .Highlighted)
//            addProjectButton.addTarget(self, action: #selector(ProjectViewController.addNewProject), forControlEvents: .TouchUpInside)
//            addProjectButton.center.x = UIScreen.mainScreen().bounds.width / 2
        
            //阴影 颜色#9C4E50
            addProjectButton.layer.shadowColor = UIColor(red: 156/255, green: 78/255, blue: 80/255, alpha: 0.35).cgColor
            addProjectButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            addProjectButton.layer.shadowOpacity = 1
            addProjectButton.layer.shadowRadius = 2.0
        
//            addProjectButton.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(addProjectButton)
//            self.view.bringSubviewToFront(addProjectButton)
//        addProjectButton.addConstraint(NSLayoutConstraint(item: addProjectButton, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 20.0))
//        }
        
        //创建长按选项
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ProjectViewController.handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //配置导航栏
        self.navigationController?.navigationBar.barTintColor = navigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //读取数据按照id顺序排序
        updateTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavBarShown()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //checkTableView()
        //判断是否第一次打开此页面
        if((UserDefaults.standard.bool(forKey: "IsFirstLaunchProjectView") as Bool!) == false){
            print("第一次打开项目页面")
            //设置为非第一次打开此页面
            UserDefaults.standard.set(true, forKey: "IsFirstLaunchProjectView")
            
            //创建引导项目
            let newTag = Tag(name: NSLocalizedString("Life", comment: ""))
            newTag.insertTag()
            let newTag2 = Tag(name: NSLocalizedString("Workout", comment: ""))
            newTag2.insertTag()
            let newTag3 = Tag(name: NSLocalizedString("Study", comment: ""))
            newTag3.insertTag()
            
            //updateTable()
            //设置引导弹窗
            callFirstRemain(NSLocalizedString("Create a new project", comment: ""), view: addProjectButton, type: .up, showHandler: nil, dismissHandler: nil)
        }else{
            //是否第一次创建普通项目
            if((UserDefaults.standard.bool(forKey: "IsFirstLaunchNormalProject") as Bool!) == false){
                print("第一次添加进度项目")
                var index = 0
                for project in projects{
                    if project.type == .punch ||  project.type == .normal{
                        let indexPath = IndexPath(row: 0, section: index)
                        if let cell = self.projectTableView.cellForRow(at: indexPath){
                            UserDefaults.standard.set(true, forKey: "IsFirstLaunchNormalProject")
                            self.callFirstRemainMultiLine(NSLocalizedString("◎ Click to check details\n◉ LongPress to glance process tips", comment: ""), view: cell, type: .down, showHandler: nil, dismissHandler: { () -> () in
                                for subView in cell.subviews{
                                    if subView.tag == self.addProcessButtonTag {
                                        self.callFirstRemain(NSLocalizedString("Record progress", comment: ""), view: subView)
                                        break
                                    }
                                }
                            })
                        }
                        break
                    }
                    index += 1
                }
            }
            
            //是否第一次创建不记录项目
            if((UserDefaults.standard.bool(forKey: "IsFirstLaunchNoRecordProject") as Bool!) == false){
                print("第一次添加非进度项目")
                var index = 0
                for project in projects{
                    if project.type == .noRecord{
                        let indexPath = IndexPath(row: 0, section: index)
                        if let cell = self.projectTableView.cellForRow(at: indexPath){
                            UserDefaults.standard.set(true, forKey: "IsFirstLaunchNoRecordProject")
                            updateTable()
                            self.callFirstRemainMultiLine(NSLocalizedString("◎ Click to check details\n◉ LongPress to glance process tips", comment: ""), view: cell, type: .down, showHandler: nil, dismissHandler: { () -> () in
                                for subView in cell.subviews{
                                    if subView.tag == self.addProcessButtonTag {
                                        self.callFirstRemain(NSLocalizedString("Mark as completed", comment: ""), view: subView)
                                        break
                                    }
                                }
                            })
                        }
                        break
                    }
                    index += 1
                }
            }
        }
        
        if UserDefaultTool.shareIntance.numsOfOpenTimes == 15{
            if !IS_IOS9{
                let alertController = UIAlertController(title: NSLocalizedString("You have been using Markplan for a while. How do you feel?", comment: ""), message: nil, preferredStyle: .alert)
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: NSLocalizedString("Rate Markplan", comment: ""), style: .default, handler: {(UIAlertAction) -> () in
                        let url = "itms-apps://itunes.apple.com/app/id1141710914"
                        UIApplication.shared.openURL(URL(string: url)!)
                    })
                //创建UIAlertAction 取消按钮
                let alerActionMore = UIAlertAction(title: NSLocalizedString("Send Feeback", comment: ""), style: .default, handler: {(UIAlertAction) -> () in
                    print("打开菜单页面")
                    let muneViewController = self.storyboard?.instantiateViewController(withIdentifier: "Options") as! OptionsTableViewController
                    
                    //压入导航栏
                    self.navigationController?.pushViewController(muneViewController, animated: true)
                    muneViewController.feedBack()
                    })
                //创建UIAlertAction 取消按钮
                let alerActionCancel = UIAlertAction(title: NSLocalizedString("Remind Me Later", comment: ""), style: .destructive, handler: {(UIAlertAction) -> () in
                    
                })
                
                //添加动作
                alertController.addAction(alerActionOK)
                alertController.addAction(alerActionMore)
                alertController.addAction(alerActionCancel)
                
                if let popoverPresentationController = alertController.popoverPresentationController {
                    popoverPresentationController.sourceView = self.view
                    popoverPresentationController.sourceRect =  CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
                }
                
                //显示alert
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                UserDefaultTool.shareIntance.numsOfOpenTimes = UserDefaultTool.shareIntance.numsOfOpenTimes + 1;
                
                // Create the dialog
                let popup = PopupDialog(title: NSLocalizedString("You have been using Markplan for a while. How do you feel?", comment: ""), message: nil, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: true) {
                    print("Completed")
                }
                
                // Create first button
                let buttonOne = DefaultButton(title: NSLocalizedString("Rate Markplan", comment: "")) {
                    let url = "itms-apps://itunes.apple.com/app/id1141710914"
                    UIApplication.shared.openURL(URL(string: url)!)
                }
                
                // Create second button
                let buttonTwo = DefaultButton(title: NSLocalizedString("Send Feeback", comment: "")) {
                    print("打开菜单页面")
                    let muneViewController = self.storyboard?.instantiateViewController(withIdentifier: "Options") as! OptionsTableViewController
                    
                    //压入导航栏
                    self.navigationController?.pushViewController(muneViewController, animated: true)
                    muneViewController.feedBack()
                }
                
                // Create second button
                let buttonThree = CancelButton(title: NSLocalizedString("Remind Me Later", comment: "")) {
                    
                }
                // Add buttons to dialog
                popup.addButtons([buttonTwo, buttonOne, buttonThree])
                
                // Present dialog
                self.present(popup, animated: true, completion: nil)
            }
        }else{
            UserDefaultTool.shareIntance.numsOfOpenTimes = UserDefaultTool.shareIntance.numsOfOpenTimes + 1;
        }
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
    // MARK: - 跳转动作
    ///弹出完成百分比view    
    func showProcessChange(_ oldPercent: Double, newPercent: Double, name: String){
        //整体通知
        let rect = UIScreen.main.bounds
        let startPoint = CGPoint(x: rect.width / 2 , y: rect.height / 2 - 120)
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 240))
        showView.backgroundColor = UIColor.white
        
        //波浪视图
        let waveLoadingIndicator = WaveLoadingIndicator(frame:CGRect(x: 20, y: 60, width: 160, height: 160))
        waveLoadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        waveLoadingIndicator.progress = oldPercent / 100
        showView.addSubview(waveLoadingIndicator)

        //分割线
        let blackView = UIView(frame: CGRect(x: 10, y: 45, width: 180, height: 1))
        blackView.backgroundColor = UIColor ( red: 0.9453, green: 0.9453, blue: 0.9453, alpha: 0.8 )
        showView.addSubview(blackView)
        
        //标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.textAlignment = .center
        titleLabel.text = name
        titleLabel.textColor = UIColor ( red: 0.2784, green: 0.2824, blue: 0.2902, alpha: 1.0 )
        showView.addSubview(titleLabel)
        
        //显示
        let popover = Popover(options: self.showPercentPopoverOptions, showHandler: nil, dismissHandler:  {() -> () in
            weak var weakSelf = self
            weakSelf?.updateTable()
            })
        popover.show(showView,  point: startPoint)
        
        //总时间 1000毫秒
        let totalTime = 2000
        //次数
        var timeOut = Int(newPercent -  oldPercent + 1)
        //周期
        let period : Int = Int( totalTime / timeOut)
        //增量
        let addEveryTime = 1.0
        //当前百分比
        
        var currentPercent = oldPercent
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.scheduleRepeating(deadline: .now(), interval: .milliseconds(period), leeway: .seconds(0))
        timer.setEventHandler(handler: { () -> Void in
            //倒计时结束，关闭
            if (timeOut <= 0) {
                //关闭定时器
                timer.cancel()
                DispatchQueue.main.async(execute: { () -> Void in
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
                        fillView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                        UIView.animate(withDuration: 1 , delay: 0,
                            usingSpringWithDamping: 1,
                            initialSpringVelocity: 0,
                            options: UIViewAnimationOptions(),
                            animations: {
                                fillView.transform = CGAffineTransform.identity
                            }){ _ in
                                
                        }

                        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                        queue.async { () -> Void in
                            Thread.sleep(forTimeInterval: 1)
                            DispatchQueue.main.sync(execute: { () -> Void in
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
            timeOut -= 1
        })
        timer.resume()
    }

    
    ///弹出完成百分比view
    func showProcessFinish(_ name: String){
        //整体通知
        let rect = UIScreen.main.bounds
        let startPoint = CGPoint(x: rect.width / 2 , y: rect.height / 2 - 120)
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 240))
        showView.backgroundColor = UIColor.white
        
        //完成视图
        let successView = UIImageView(image: UIImage(named: "projectFinish"))
        successView.frame = CGRect(x: 20, y: 60, width: 160, height: 160)
        showView.addSubview(successView)
        successView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 1 , delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions(),
            animations: {
                successView.transform = CGAffineTransform.identity
            }){ _ in
                
        }
        //分割线
        let blackView = UIView(frame: CGRect(x: 10, y: 45, width: 180, height: 1))
        blackView.backgroundColor = UIColor ( red: 0.9453, green: 0.9453, blue: 0.9453, alpha: 0.8 )
        showView.addSubview(blackView)
        
        //标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        titleLabel.textAlignment = .center
        titleLabel.text = name
        titleLabel.textColor = UIColor ( red: 0.2784, green: 0.2824, blue: 0.2902, alpha: 1.0 )
        showView.addSubview(titleLabel)
        
        //显示
        let popover = Popover(options: self.showPercentPopoverOptions, showHandler: nil, dismissHandler: {() -> () in
            weak var weakSelf = self
            weakSelf?.updateTable()
            })

        popover.show(showView,  point: startPoint)
        
        let queue = DispatchQueue.global()
        queue.async { () -> Void in
            Thread.sleep(forTimeInterval: 1)
            DispatchQueue.main.sync(execute: { () -> Void in
                popover.dismiss()
            })
        }
    }


    ///新增进程
    func addProcess(_ sender: UIButton){
        if let indexPath = self.projectTableView.indexPath(for: sender.superview as! ProjectTableViewCell){
            //是否是未完成项目
            if projects[(indexPath as NSIndexPath).section].isFinished == .notFinished || projects[(indexPath as NSIndexPath).section].isFinished == .overTime{
                 print("添加项目编号为\((indexPath as NSIndexPath).section)打卡进度")
                //打卡项目
                if projects[(indexPath as NSIndexPath).section].type == .punch{
                    let process = Process()
                    process.projectID = projects[(indexPath as NSIndexPath).section].id
                    let name = projects[(indexPath as NSIndexPath).section].name
                    let currentTime = Date()
                    let dateFormat = DateTool.shareIntance.dateFormatYYYYMMMMDDHHMMCN
                    let old = projects[(indexPath as NSIndexPath).section].percent
                    process.recordTime = dateFormat.string(from: currentTime)
                    process.done = 1.0
                    process.insertProcess()
                    ProcessDate().chengeData(projects[(indexPath as NSIndexPath).section].id, timeDate: currentTime, changeValue: 1.0)
                    projects[(indexPath as NSIndexPath).section].increaseDone(1.0)
                    let new = projects[(indexPath as NSIndexPath).section].percent
                    showProcessChange(old, newPercent: new, name: name)                    

                    MobClick.event("2001")
                    //记录进度项目
                }else if projects[(indexPath as NSIndexPath).section].type == .normal{
                     print("打开项目编号为\((indexPath as NSIndexPath).section)进度页面")
                    let addProcessViewController = self.storyboard?.instantiateViewController(withIdentifier: "addProcess") as! AddProcessTableViewController
                    //设置每个cell的项目
                    addProcessViewController.delegate = self
                    addProcessViewController.project = projects[(indexPath as NSIndexPath).section]
                    addProcessViewController.title = "\(projects[(indexPath as NSIndexPath).section].name)"
                    //压入导航栏
                    addProcessViewController.view.backgroundColor = allBackground
                    addProcessViewController.modalTransitionStyle = .coverVertical
                    let navController = UINavigationController.init(rootViewController: addProcessViewController)
                    //状态栏和导航栏不透明
                    navController.navigationBar.isTranslucent = false
                    //设置导航栏颜色
                    navController.navigationBar.barTintColor = otherNavigationBackground

                    navController.navigationBar.tintColor = navigationTintColor
                    navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
                    self.navigationController?.present(navController, animated: true, completion: nil)
                    //不记录项目
                }else if projects[(indexPath as NSIndexPath).section].type == .noRecord{
                    print("项目编号为\((indexPath as NSIndexPath).section)完成项目")
                    let name = projects[(indexPath as NSIndexPath).section].name
                    projects[(indexPath as NSIndexPath).section].finishDone()
                    showProcessFinish(name)
                    
                    MobClick.event("2003")
                }
            //项目完成
            }else if projects[(indexPath as NSIndexPath).section].isFinished == .finished{
                let alertController = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: NSLocalizedString("The operation is not reversible.", comment: ""), preferredStyle: .alert)
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
                //创建UIAlertAction 取消按钮
                let alerActionCancel = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler:  {(UIAlertAction) -> Void in
                    weak var weakSelf = self
                    weakSelf?.projects[(indexPath as NSIndexPath).section].deleteProject()
                    weakSelf?.callAlertSuccess(NSLocalizedString("Deleted", comment: ""))
                    weakSelf?.updateTable()
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

            }else if projects[(indexPath as NSIndexPath).section].isFinished == .notBegined{
                var type = ""
                switch projects[(indexPath as NSIndexPath).section].type{
                case .normal:
                    type = NSLocalizedString("record progress", comment: "")
                case .punch:
                    type = NSLocalizedString("mark", comment: "")
                case .noRecord:
                    type = NSLocalizedString("mark as completed", comment: "")
                default: break
                }
                callAlert(NSLocalizedString("Not Started", comment: ""),message: String(format: NSLocalizedString("Change start time to %@.", comment: ""), type))
            }
        }
    }
    
    ///添加新项目
    func addNewProject(){
        //创建后返回不显示已完成项目
        isShowFinished = false
        selectTag = nil
        let addNewProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProject") as! EditProjectTableViewController
        addNewProjectViewController.title = NSLocalizedString("New Project", comment: "")
        addNewProjectViewController.tableState = .add
        addNewProjectViewController.delegate = self
        //设置view颜色
        addNewProjectViewController.view.backgroundColor = allBackground
        addNewProjectViewController.modalTransitionStyle = .coverVertical
        let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
        //状态栏和导航栏不透明
        navController.navigationBar.isTranslucent = false
        //设置导航栏颜色
        navController.navigationBar.barTintColor = otherNavigationBackground
        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage()
        // Creating shadow path for better performance

//        navController.navigationBar.layer.shadowColor = navigationShadowsColor.CGColor
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.present(navController, animated: true, completion: nil)
         //UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    ///单个项目页面
    func getMoreInfor(_ sender: UIButton){
        if let indexPath = self.projectTableView.indexPath(for: sender.superview as! ProjectTableViewCell){
            if projects[(indexPath as NSIndexPath).section].type != .noRecord {
                print("打开项目编号为\((indexPath as NSIndexPath).section)统计页面")
                let statisticsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Statistics") as! StatisticsViewController
                //设置view背景色
                statisticsViewController.view.backgroundColor = allBackground
                //设置每个cell的项目
                statisticsViewController.project = projects[(indexPath as NSIndexPath).section]

                
                //压入导航栏
                self.navigationController?.pushViewController(statisticsViewController, animated: true)
            }else{
                print("打开项目编号为\((indexPath as NSIndexPath).section)编辑页面")
                let addNewProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProject") as! EditProjectTableViewController
                addNewProjectViewController.title = projects[(indexPath as NSIndexPath).section].name
                addNewProjectViewController.tableState = .edit
                addNewProjectViewController.view.backgroundColor = allBackground
                addNewProjectViewController.modalTransitionStyle = .coverVertical
                let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
                //状态栏和导航栏不透明
                navController.navigationBar.isTranslucent = false
                //设置导航栏颜色
                navController.navigationBar.barTintColor = otherNavigationBackground

                navController.navigationBar.tintColor = navigationTintColor
                navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
                self.navigationController?.present(navController, animated: true, completion: nil)
                addNewProjectViewController.project = projects[(indexPath as NSIndexPath).section]
            }

        }
    }


    
    // MARK: - UITableViewDataSource
    ///确认节数
    func numberOfSections(in tableView: UITableView) -> Int {
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
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
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) ->
        UITableViewCell {
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
            cell.textLabel?.textColor = navigationFontColor
            cell.textLabel?.font = muneTableFont
            if (indexPath as NSIndexPath).row == 0{
                let isShowAllSwitch = UISwitch(frame: CGRect(x: self.view.bounds.width - 65, y: 14, width: 40, height: MenuTableViewHeight))
                isShowAllSwitch.onTintColor = switchColor
                isShowAllSwitch.isOn = !isShowNotBegin
                isShowAllSwitch.addTarget(self, action: #selector(ProjectViewController.showNotBegin), for: .valueChanged)
                cell.addSubview(isShowAllSwitch)
            }
            if (indexPath as NSIndexPath).row == 1{
                cell.accessoryType = .disclosureIndicator
                if isShowFinished {
                    cell.textLabel?.text = NSLocalizedString("In Progress", comment: "")
                }
            }
            return cell
            
            //项目表格
        case tableViewTag.ProjectsTable:
                let cell = projectTableView.dequeueReusableCell(withIdentifier: Storyboard.CellReusIdentifier, for: indexPath) as! ProjectTableViewCell
                
                //复用清除之前的按钮
                for subView in cell.subviews{
                    if subView.tag == addProcessButtonTag {
                        subView.removeFromSuperview()
                    }
                }
                
                //配置cell
                cell.project = projects[(indexPath as NSIndexPath).section]
                cell.roundBackgroundColor = allBackground
                cell.needPercent = true
                cell.percent = projects[(indexPath as NSIndexPath).section].percent
                cell.isShowState = false
                
                //if projects[indexPath.section].isFinished == .NotFinished{
                //新增进度按钮
                let addProcessFrame = CGRect(x: cell.frame.width - cell.frame.height - self.cellMargin , y: 0, width: cell.frame.height , height: cell.frame.height)
                let addProcessButton = UIButton(frame: addProcessFrame)
                
                
                //根据不同任务类型使用不同的图标
                var imageString = ""
                var selectString = ""
                switch(projects[(indexPath as NSIndexPath).section].type){
                case .noRecord:
                    if projects[(indexPath as NSIndexPath).section].isFinished == .notBegined{
                        imageString = "norecordno"
                        selectString = "norecordno"
                    }else{
                        imageString = "norecord"
                        selectString = "norecordclick"
                    }
                case .punch:
                    if projects[(indexPath as NSIndexPath).section].isFinished == .notBegined{
                        imageString = "punchno"
                        selectString = "punchno"
                    }else{
                        imageString = "punch"
                        selectString = "punchclick"
                    }
                case .normal:
                    if projects[(indexPath as NSIndexPath).section].isFinished == .notBegined{
                        imageString = "recordno"
                        selectString = "recordno"
                    }else{
                        imageString = "record"
                        selectString = "recordclick"
                    }
                default:break
                }
                
                if projects[(indexPath as NSIndexPath).section].isFinished == .finished{
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
                addProcessButton.setImage(buttonImage, for: UIControlState())
                addProcessButton.setImage(buttonSelectedIamge, for: .highlighted)
                addProcessButton.addTarget(self, action: #selector(ProjectViewController.addProcess(_:)), for: .touchUpInside)
                addProcessButton.tag = addProcessButtonTag
                //添加按钮
                cell.addSubview(addProcessButton)
                //}                

                return cell
            //标签表格
        case tableViewTag.TagsTable:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
            
            return cell
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            return cell
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //表格类型
        switch tableView.tag {
            //菜单表格
        case tableViewTag.MuneTable:
            if (indexPath as NSIndexPath).row == 1 {
                isShowFinished = !isShowFinished
                selectTag = nil
                updateTable()
            }else if (indexPath as NSIndexPath).row == 2{
                handleCallOptions()
            }
            popover.dismiss()
            //项目表格
        case tableViewTag.ProjectsTable:
                if projects[(indexPath as NSIndexPath).section].type != .noRecord {
                    print("打开项目编号为\((indexPath as NSIndexPath).section)统计页面")
                    let statisticsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Statistics") as! StatisticsViewController
                    //设置view背景色
                    statisticsViewController.view.backgroundColor = allBackground
                    //设置每个cell的项目
                    statisticsViewController.project = projects[(indexPath as NSIndexPath).section]
                    
                    
                    //压入导航栏
                    self.navigationController?.pushViewController(statisticsViewController, animated: true)
                }else{
                    print("打开项目编号为\((indexPath as NSIndexPath).section)编辑页面")
                    let addNewProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProject") as! EditProjectTableViewController
                    addNewProjectViewController.title = projects[(indexPath as NSIndexPath).section].name
                    addNewProjectViewController.tableState = .edit
                    addNewProjectViewController.delegate = self
                    addNewProjectViewController.view.backgroundColor = allBackground
                    addNewProjectViewController.modalTransitionStyle = .coverVertical
                    let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
                    //状态栏和导航栏不透明
                    navController.navigationBar.isTranslucent = false
                    //设置导航栏颜色
                    navController.navigationBar.barTintColor = otherNavigationBackground

                    navController.navigationBar.tintColor = navigationTintColor
                    navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
                    self.navigationController?.present(navController, animated: true, completion: nil)
                    addNewProjectViewController.project = projects[(indexPath as NSIndexPath).section]
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ivc = segue.destination as? EditProjectTableViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "addProject":
                    ivc.title = NSLocalizedString("New Project", comment: "")
                    ivc.tableState = .add
                default: break
                }
            }
        }else if let ivc = segue.destination as? TagsViewController {
            if let identifier = segue.identifier{
                switch identifier{
                case "showTags":
                    ivc.title = NSLocalizedString("Tags", comment: "")
                    ivc.delegate = self
                  default: break
                }
            }
        }
    }
    // MARK: - Popover presentation delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        print("Will reposition popover")
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("Did Dismiss popover")
    }
    
    func opoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("Should Dismiss popover")
        print(popoverPresentationController.popoverBackgroundViewClass)
        return true
    }
        
    // MARK: - TagsView delegate
    func passSelectedTag(_ selectedTag: Tag?){
        selectTag = selectedTag
        return
    }
    
    // MARK: - addProcess delegate
    func addProcessTableViewAct(_ old: Double, new: Double, name: String){
        showProcessChange(old, newPercent: new, name: name)
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //scrollView已经有拖拽手势，直接拿到scrollView的拖拽手势
        let pan = scrollView.panGestureRecognizer
        //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
        let velocity = pan.velocity(in: scrollView).y
        
        if velocity < -5 {
            //向上拖动，隐藏导航栏
            setNavBarHidden()
        }
        else if velocity > 5 {
            //向下拖动，显示导航栏
            setNavBarShown()
        }
        else if velocity == 0{
            
            //停止拖拽
        }
    }

    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count >= 2 {
            return true
        }
        return false
    }
    // MARK: - EditProjectTableViewDelegate
    func goBackAct(_ state: EditProjectBackState){
        switch state{
        case .addSuccess:
            callAlertSuccess(NSLocalizedString("Done", comment: "创建成功"))
//        case .DeleteSucceess:
//            callAlertSuccess("删除成功!")
        case .editSucceess:
            callAlertSuccess(NSLocalizedString("Done!", comment: "编辑成功"))
        default: break
        }
    }
}



extension Array {
    var decompose : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}
