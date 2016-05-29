//
//  processesTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/28.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProcessesTableViewController: UITableViewController {
    var project = Project(){
        didSet{
            processes = Process().loadData(project.id)
        }
    }
    var processes = [Process]()

    
    private struct Storyboard{
        static let CellReusIdentifier = "ProjectCell"
    }
    
    // MARK: - UITableViewDataSource
    //确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return processes.count
    }
    
    //配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProcessTableViewCell
        
        //配置cell
        cell.process = processes[indexPath.section]
        return cell
    }
}
