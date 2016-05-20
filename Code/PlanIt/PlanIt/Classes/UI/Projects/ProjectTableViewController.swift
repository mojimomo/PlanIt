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
        //不显示分割线
        self.tableView.separatorStyle = .None
        self.tableView.sectionFooterHeight = 5
        self.tableView.sectionHeaderHeight = 5
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //读取数据按照id顺序排序
        projects = Project().loadAllData()
        self.tableView.backgroundColor = tableViewBackgroundColor
        self.tableView.reloadData()
        //设置naviagtioncontroller的空间颜色为白色
        self.navigationController?.view.tintColor = UIColor.whiteColor()
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
        
//        cell.backgroundColor = UIColor.whiteColor()
        //配置cell
        cell.project = projects[indexPath.section]
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
