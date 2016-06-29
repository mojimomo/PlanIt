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
    var isEditingMod = false
    @IBOutlet var processTableView: UITableView!
    
    @IBAction func finishEdit(sender: AnyObject) {
        isEditingMod = !isEditingMod
        self.processTableView.setEditing(isEditingMod, animated: true)
    }
    
    private struct Storyboard{
        static let CellReusIdentifier = "ProcessCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editBarButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .Done, target: self, action: "finishEdit:")
        self.navigationItem.rightBarButtonItem = editBarButton
    }   

    
    // MARK: - UITableViewDataSource
    ///确定行数
    override func tableView(tv:UITableView, numberOfRowsInSection section:Int) -> Int {
        return processes.count
    }
    
    ///配置cell内容
    override func tableView(tv:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReusIdentifier, forIndexPath: indexPath) as! ProcessTableViewCell
        
        //配置cell
        cell.process = processes[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if isEditingMod == true{
            let process =  processes[indexPath.row]
            process.deleteProcess()
            project.increaseDone(-process.done)
            ProcessDate().chengeData(process.projectID, timeDate: process.recordTimeDate, changeValue: -process.done)
            processes.removeAtIndex(indexPath.row)
            processTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
    }
}
