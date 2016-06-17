//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
import Popover

@IBDesignable

class ProjectViewController: UIViewController , UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource{

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
    
    private var popover: Popover!
    
    private var texts = ["Edit", "Delete", "Report"]
    
    private var popoverOptions: [PopoverOption] = [
        .Type(.Down),
        .CornerRadius(0.0),
        .ArrowSize(CGSize(width: 0.0, height: 0.0)),
        .BlackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    ///添加项目按钮
    var addProjectButton: UIButton?
    ///项目列表
    var projects = [Project]()
    ///cell边距
    var cellMargin : CGFloat = 15.0
    ///添加新项目底部边距
    var addProjectButtonMargin : CGFloat = 20.0
    ///添加按钮尺寸
    var addProjectButtonSize : CGSize = CGSize(width: 0, height: 0)
    private struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    
    //呼出标签栏
    @IBAction func callTag(sender: UIBarButtonItem) {
        //获取静态栏的高度

        let startPoint = CGPoint(x: 0, y: 0)
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 135 + rectStatus.size.height))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatus.size.height))
        tableView.tag = tableViewTag.MuneTable
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = true
        tableView.separatorStyle = .None
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView,  point: startPoint)
    }
    
    ///点击点开抽屉菜单
    @IBAction func callMenu(sender: AnyObject) {
//        //获取此页面的抽屉菜单页
//        if let drawer = self.navigationController?.parentViewController as? KYDrawerController{
//            //设置菜单页状态
//            drawer.setDrawerState( .Opened, animated: true)
//        }
        let startPoint = CGPoint(x: self.view.frame.width, y: 0)
        let rectStatus = UIApplication.sharedApplication().statusBarFrame
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 135 + rectStatus.size.height))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: rectStatus.size.height))
        tableView.tag = tableViewTag.MuneTable
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = true
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

    //MARK: - View Controller Lifecle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //不显示分割线
        self.projectTableView.separatorStyle = .None
        //上下2个cell的边距
        self.projectTableView.sectionFooterHeight = 13
        self.projectTableView.sectionHeaderHeight = 13

        //设计背景色
        self.projectTableView.backgroundColor = allBackground
        
        //去除导航栏分栏线
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        
        if let addImage = UIImage(named: "add"){
            //获取导航栏高度
            let rectNav = self.navigationController?.navigationBar.frame
            //获取静态栏的高度
            let rectStatus = UIApplication.sharedApplication().statusBarFrame
            //添加按钮
            addProjectButtonSize = addImage.size
            addProjectButton = UIButton(frame: CGRectMake((self.view.bounds.size.width - addImage.size.width)/2 , self.view.bounds.size.height - addImage.size.height - rectNav!.size.height - rectStatus.size.height - addProjectButtonMargin, addImage.size.width, addImage.size.height))
            addProjectButton?.setImage(addImage, forState: .Normal)
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

        //读取数据按照id顺序排序
        projects = Project().loadAllData()
        //更新表格
        projectTableView.reloadData()
        
        //添加统计label
        let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: projectTableView.frame.width, height: 70))
        countLabel.text = "\(projects.count)个项目"
        countLabel.font = UIFont(name: "System", size: 6)
        countLabel.textColor = UIColor.grayColor()
        countLabel.textAlignment = .Center
        countLabel.backgroundColor = UIColor.clearColor()
        projectTableView.tableFooterView = countLabel
        

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
    ///新增进程
    func addProcess(sender: UIButton){
        if let indexPath = self.projectTableView.indexPathForCell(sender.superview as! ProjectTableViewCell){
            print("添加项目编号为\(indexPath.section)进度")
            //是否是未完成项目
            if projects[indexPath.section].isFinished == .NotFinished{
                //打卡项目
                if projects[indexPath.section].type == .Punch{
                    let process = Process()
                    process.projectID = projects[indexPath.section].id
                    let currentTime = NSDate()
                    let dateFormat = NSDateFormatter()
                    dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                    process.recordTime = dateFormat.stringFromDate(currentTime)
                    process.done = 1.0
                    process.insertProcess()
                    ProcessDate().chengeData(projects[indexPath.section].id, timeDate: currentTime, changeValue: 1.0)
                    projects[indexPath.section].increaseDone(1.0)
                    //记录进度项目
                }else if projects[indexPath.section].type == .Normal{
                    
                }
            }
        }

    }
    
    ///添加新项目
    func addNewProject(){
        let addNewProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
        addNewProjectViewController.title = "新增项目"
        addNewProjectViewController.tableState = .Add
        addNewProjectViewController.view.backgroundColor = allBackground
        addNewProjectViewController.modalTransitionStyle = .CoverVertical
        let navController = UINavigationController.init(rootViewController: addNewProjectViewController)
        //设计背景色
        navController.navigationBar.backgroundColor = allBackground
        //去除导航栏分栏线
        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = navigationTintColor
        let navigationTitleAttribute: NSDictionary = NSDictionary(object: navigationFontColor, forKey: NSForegroundColorAttributeName)
        navController.navigationBar.titleTextAttributes = navigationTitleAttribute as? [String : AnyObject]
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    ///单个项目页面
    func getMoreInfor(sender: UIButton){
        if let indexPath = self.projectTableView.indexPathForCell(sender.superview as! ProjectTableViewCell){
            print("打开项目编号为\(indexPath.section)统计页面")
            let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Statistics") as! StatisticsViewController
            //设置view背景色
            statisticsViewController.view.backgroundColor = allBackground
            //设置每个cell的项目
            statisticsViewController.project = projects[indexPath.section]
            //压入导航栏
            self.navigationController?.pushViewController(statisticsViewController, animated: true)
        }
    }

    // MARK: - UITableViewDataSource
    //确认节数
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
            return 44
            //项目表格
        case tableViewTag.ProjectsTable:
            return 44
            //标签表格
        case tableViewTag.TagsTable:
            return 44
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
            return cell
            
            //项目表格
        case tableViewTag.ProjectsTable:
                let cell = projectTableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
            
                //配置cell
                cell.project = projects[indexPath.section]
                cell.roundBackgroundColor = allBackground
                
                //if projects[indexPath.section].isFinished == .NotFinished{
                //新增进度按钮
                let addProcessFrame = CGRectMake(cell.frame.width - cell.frame.height - self.cellMargin , 0, cell.frame.height , cell.frame.height)
                let addProcessButton = UIButton(frame: addProcessFrame)
                
                
                //根据不同任务类型使用不同的图标
                var imageString = ""
                switch(projects[indexPath.section].type){
                case .NoRecord:
                    imageString = "norecord"
                case .Punch:
                    imageString = "punch"
                case .Normal:
                    imageString = "record"
                default:break
                }
                
                let processView = UIProgressView(frame: cell.frame)
                processView.setProgress(1.0 , animated: true)
                cell.addSubview(processView)
                cell.backgroundView = processView
                
                //读取图片
                let buttonImage = UIImage(named: imageString)
                //进行缩
                addProcessButton.setImage(buttonImage, forState: .Normal)
                addProcessButton.addTarget(self, action: "addProcess:", forControlEvents: .TouchUpInside)
                
                //添加按钮
                cell.addSubview(addProcessButton)
                //}
                
                //单个项目页面按钮
                let getMoreInfor = UIButton(frame: CGRectMake(0, 0, cell.frame.width - cell.frame.height - self.cellMargin, cell.frame.height))
                getMoreInfor.setBackgroundImage(.None, forState: .Normal)
                getMoreInfor.setBackgroundImage(.None, forState: .Highlighted)
                getMoreInfor.addTarget(self, action: "getMoreInfor:", forControlEvents: .TouchUpInside)
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
        }
    }
    
    // MARK: Popover presentation delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func popoverPresentationController(popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverToRect rect: UnsafeMutablePointer<CGRect>, inView view: AutoreleasingUnsafeMutablePointer<UIView?>) {
        print("Will reposition popover")
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        print("Did Dismiss popover")
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("Should Dismiss popover")
        print(popoverPresentationController.popoverBackgroundViewClass)
        return true
    }
}


extension UIImage{
    func scaleToSize(size: CGSize) -> UIImage{
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size)
        // 绘制改变大小的图片
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        // 从当前context中创建一个改变大小后的图片
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        // 使当前的context出堆栈
        UIGraphicsEndImageContext()
        return scaleImage
    }
}
