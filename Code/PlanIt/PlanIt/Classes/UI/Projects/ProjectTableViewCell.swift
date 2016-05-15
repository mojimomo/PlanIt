//
//  ProjectTableViewCell.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var projectStatusLabel: UILabel!
    @IBOutlet weak var projectTagLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var tagImageView: UIImageView!
    
    var project: Project?{
        didSet{
            updateUI()
        }
    }

    var projectName: String{
        set{
            projectNameLabel?.text = newValue
        }
        get{
            return (projectNameLabel?.text)!
        }
    }
    
    var projectStatus: String{
        set{
            projectStatusLabel?.text = newValue
        }
        get{
            return (projectStatusLabel?.text)!
        }
    }
    
    var projectTag: String{
        set{
            projectTagLabel?.text = newValue
        }
        get{
            return (projectTagLabel?.text)!
        }
    }
    
    func updateUI(){
        projectName = ""
        projectStatus = ""
        projectTag = ""
        
        if let project = self.project{
            projectName = project.name
            projectStatus = "\(project.rest)"
        }
    }
}
