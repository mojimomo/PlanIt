//
//  ProjectTableViewCell.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell , PieChartDataSource{
    @IBOutlet weak var pieChartView: PieChartView!{
        didSet{
            pieChartView.dataSource = self
        }
    }
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectStatusLabel: UILabel!
    @IBOutlet weak var projectTagLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var tagImageView: UIImageView!
    //当前项目
    var project: Project?{
        didSet{
            updateUI()
        }
    }
    //当前项目名称
    var projectName: String{
        set{
            projectNameLabel?.text = newValue
        }
        get{
            return (projectNameLabel?.text)!
        }
    }
    //当前项目状态
    var projectStatus: String{
        set{	
            projectStatusLabel?.text = newValue
        }
        get{
            return (projectStatusLabel?.text)!
        }
    }
    //当前项目tag
    var projectTag: String{
        set{
            projectTagLabel?.text = newValue
        }
        get{
            return (projectTagLabel?.text)!
        }
    }
    //项目完成百分比
    var projectPercent = 0.0
    
    //更新界面
    func updateUI(){
        projectName = ""
        projectStatus = ""
        projectTag = ""
        projectPercent = 0.0
        
        if let project = self.project{
            projectName = project.name
            projectStatus = "\(project.rest)"
            projectTag = project.tagString
            projectPercent = project.percent
        }
    }
    
    func percentForPieChartView(sneder: PieChartView) -> Double? {
        return projectPercent
    }
}
