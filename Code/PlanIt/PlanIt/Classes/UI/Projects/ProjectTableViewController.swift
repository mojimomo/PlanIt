//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
@IBDesignable

class ProjectTableViewController: UITableViewController {
    @IBOutlet var projectTableView: UITableView!
    @IBOutlet weak var projectName: UILabel!
    var tableViewBackgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1) {
        didSet {
        }
    }
    var projects = [Project]()
    var cellMargin : CGFloat = 10.0
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

    
    //MARK: - View Controller Lifecle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //不显示分割线
        self.tableView.separatorStyle = .None
        self.tableView.sectionFooterHeight = 10
        self.tableView.sectionHeaderHeight = 10
        //设置naviagtioncontroller的空间颜色为白色
        self.navigationController?.view.tintColor = UIColor.whiteColor()
        self.tableView.backgroundColor = tableViewBackgroundColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //读取数据按照id顺序排序
        projects = Project().loadAllData()
        //更新表格
        self.tableView.reloadData()

    }
    
    // MARK: - 跳转动作
    //新增进程
    func addProcess(sender: UIButton){
        print("addProcess tag = \(sender.tag)")
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
        }else{
            let popup = AddProcessView()
            popup.showInView(self.view)

        }
    }
    
    //单个项目页面
    func getMoreInfor(sender: UIButton){
        print("getMoreInfor tag = \(sender.tag)")
        let statisticsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Statistics") as! StatisticsViewController
        statisticsViewController.view.backgroundColor = tableViewBackgroundColor
        statisticsViewController.project = projects[sender.tag]
        self.navigationController?.pushViewController(statisticsViewController, animated: true)
        
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return projects.count
    }
    
    //确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 1
    }
    
    //配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell

        //配置cell
        cell.project = projects[indexPath.section]
        
        if projects[indexPath.section].isFinished == ProjectIsFinished.NotFinished{
            //新增进度按钮
            let addProcessButton = UIButton(frame: CGRectMake(cell.frame.width - cell.frame.height - self.cellMargin , 0, cell.frame.height , cell.frame.height))
            addProcessButton.tag = indexPath.section
            addProcessButton.setImage(UIImage(named:"checked"), forState: .Normal)
            addProcessButton.addTarget(self, action: "addProcess:", forControlEvents: .TouchUpInside)
            cell.addSubview(addProcessButton)
        }
        
        //单个项目页面按钮
        let getMoreInfor = UIButton(frame: CGRectMake(0, 0, cell.frame.width - cell.frame.height - self.cellMargin, cell.frame.height))
        getMoreInfor.tag = indexPath.section
        getMoreInfor.setBackgroundImage(.None, forState: .Normal)
        getMoreInfor.setBackgroundImage(.None, forState: .Highlighted)
        getMoreInfor.addTarget(self, action: "getMoreInfor:", forControlEvents: .TouchUpInside)
        cell.addSubview(getMoreInfor)
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
}
