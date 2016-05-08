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
    
    //点击点开抽屉菜单
    @IBAction func CallMenu(sender: AnyObject) {
        //获取此页面的抽屉菜单页
        if let drawer = self.navigationController?.parentViewController as? KYDrawerController{
            //设置菜单页状态
            drawer.setDrawerState( .Opened, animated: true)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
