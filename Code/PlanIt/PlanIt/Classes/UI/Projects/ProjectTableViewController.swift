//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
@IBDesignable

class ProjectTableViewController: UITableViewController , UIPopoverPresentationControllerDelegate{
    @IBOutlet var projectTableView: UITableView!
    @IBOutlet weak var projectName: UILabel!

    //添加项目按钮也
    var addProjectButton: UIButton?
    //项目列表
    var projects = [Project]()
    //cell边距
    var cellMargin : CGFloat = 15.0
    //添加新项目底部边距
    var addProjectButtonMargin : CGFloat = 15.0
    //添加按钮尺寸
    var addProjectButtonSize : CGSize = CGSize(width: 0, height: 0)
    private struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    
    //点击点开抽屉菜单
    @IBAction func CallMenu(sender: AnyObject) {
        //获取此页面的抽屉菜单页
        if let drawer = self.navigationController?.parentViewController as? KYDrawerController{
            //设置菜单页状态
            drawer.setDrawerState( .Opened, animated: true)
        }
        
    }

    //点击创建新项目
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
        self.tableView.separatorStyle = .None
        //上下2个cell的边距
        self.tableView.sectionFooterHeight = 13
        self.tableView.sectionHeaderHeight = 13

        //设计背景色
        self.tableView.backgroundColor = allBackground
        
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
            self.view.addSubview(addProjectButton!)
            self.view.bringSubviewToFront(addProjectButton!)

        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //读取数据按照id顺序排序
        projects = Project().loadAllData()
        //更新表格
        self.tableView.reloadData()

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
    //新增进程
    func addProcess(sender: UIButton){
        print("添加项目编号为\(sender.tag)进度")
        //是否是未完成项目
        if projects[sender.tag].isFinished == ProjectIsFinished.NotFinished{
            //打卡项目
            if projects[sender.tag].type == ProjectType.Punch{
                let process = Process()
                process.projectID = projects[sender.tag].id
                let currentTime = NSDate()
                let dateFormat = NSDateFormatter()
                dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                process.recordTime = dateFormat.stringFromDate(currentTime)
                process.done = 1.0
                process.insertProcess()
                ProcessDate().chengeData(projects[sender.tag].id, timeDate: currentTime, changeValue: 1.0)
                projects[sender.tag].increaseDone(1.0)
            //记录进度项目
            }else if projects[sender.tag].type == ProjectType.Normal{
                let popup = AddProcessView()
                popup.showInView(self.view)
            }
        }
    }
    
    //单个项目页面
    func getMoreInfor(sender: UIButton){
        print("打开项目编号为\(sender.tag)统计页面")
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Statistics") as! StatisticsViewController
        //设置view背景色
        statisticsViewController.view.backgroundColor = allBackground
        //设置每个cell的项目
        statisticsViewController.project = projects[sender.tag]
        //压入导航栏
        self.navigationController?.pushViewController(statisticsViewController, animated: true)
        
    }

    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if projects.count != 0{
            return projects.count + 1
        }
        return 0
    }
    
    //确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 1
    }
    
    //配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
        //判断是否是最后一个统计行
        if ((projects.count != 0) && (indexPath.section == projects.count)){
            cell.projectName = ""
            cell.roundFrontColor = allBackground
            cell.selectedColor = allBackground
            
            //添加统计label
            let countLabel = UILabel(frame: .zero)
            countLabel.text = "\(projects.count)个项目"
            countLabel.font = UIFont(name: "System", size: 6)
            countLabel.textColor = UIColor.grayColor()
            countLabel.textAlignment = .Center
            
            countLabel.sizeToFit()
            countLabel.backgroundColor = UIColor.clearColor()
            countLabel.center = CGPointMake(cell.center.x, 20)
            cell.addSubview(countLabel)
        }else{
            //配置cell
            cell.project = projects[indexPath.section]
            cell.roundBackgroundColor = allBackground
            
            //if projects[indexPath.section].isFinished == ProjectIsFinished.NotFinished{
            //新增进度按钮
            let addProcessFrame = CGRectMake(cell.frame.width - cell.frame.height - self.cellMargin , 0, cell.frame.height , cell.frame.height)
            let addProcessButton = UIButton(frame: addProcessFrame)
            addProcessButton.tag = indexPath.section
            
            //根据不同任务类型使用不同的图标
            var imageString = ""
            switch(projects[indexPath.section].type){
            case ProjectType.NoRecord:
                imageString = "norecord"
            case ProjectType.Punch:
                imageString = "punch"
            case ProjectType.Normal:
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
            getMoreInfor.tag = indexPath.section
            getMoreInfor.setBackgroundImage(.None, forState: .Normal)
            getMoreInfor.setBackgroundImage(.None, forState: .Highlighted)
            getMoreInfor.addTarget(self, action: "getMoreInfor:", forControlEvents: .TouchUpInside)
            cell.addSubview(getMoreInfor)
        }
        
        

        
        
        //cell.bringSubviewToFront(addProcessButton)
//        cell.backgroundColor = UIColor.whiteColor()
//        //设置cell圆角
//        cell.layer.cornerRadius = 25
//        //阴影颜色
//        cell.layer.shadowColor = UIColor.blackColor().CGColor
//        //阴影透明度
//        cell.layer.shadowOpacity = 0.75
//        //阴影圆角
//        cell.layer.shadowRadius = 4.0
//        //阴影偏移量
//        cell.layer.shadowOffset = CGSizeMake(4,4)
//        //阴影路径
//        let shadowFrame = cell.layer.bounds;
//        let shadowPath = UIBezierPath(rect: shadowFrame)
//        cell.layer.shadowPath = shadowPath.CGPath
        
//        cell.backgroundColor = UIColor.clearColor()
//        cell.layer.masksToBounds = false
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 3.0).CGPath
//        cell.layer.shadowOffset = CGSizeMake(0.5, 0.5)
//        cell.layer.shadowColor = UIColor.lightGrayColor().CGColor
//        cell.layer.shadowOpacity = 0.7
//        cell.layer.shadowRadius = 4
        
        return cell
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
