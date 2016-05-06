//
//  ProjectTableViewCell.swift
//  PlanIt
//
//  Created by Ken on 16/5/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    var project: Project?{
        didSet{
            updateUI()
        }
    }
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectStatus: UILabel!
    @IBOutlet weak var projectTag: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var tagImage: UIImageView!
    
    func updateUI(){        
        projectName?.text = nil
        projectStatus?.text = nil
        projectTag?.text = nil
        
        if let project = self.project{
            projectName?.text = project.name
            projectStatus?.text = "\(project.rest)"        }
    }
}
