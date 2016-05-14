//
//  ProjectViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    @IBOutlet var projectTableView: UITableView!
    @IBOutlet weak var projectName: UILabel!
    
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
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //读取数据按照id顺序排序
        projects = Project().allRows("id ASC")
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    //确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = projects.count
        return cnt
    }
    
    //配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProjectTableViewCell
        
        //配置cell
        cell.project = projects[indexPath.row]
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
