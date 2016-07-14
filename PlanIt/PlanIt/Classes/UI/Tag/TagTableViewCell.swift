//
//  TagTableViewCell.swift
//  PlanIt
//
//  Created by Ken on 16/7/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var tagCountsLabel: UILabel!
    var tagName = ""{
        didSet{
            tagNameLabel.text = tagName
        }
    }
    
    var tagCounts = 0{
        didSet{
            tagCountsLabel.text = "\(tagCounts)"
            tagCountsLabel.sizeToFit()
            //tagCountsLabel.backgroundColor = UIColor ( red: 0.7302, green: 0.7302, blue: 0.7302, alpha: 1.0 )
            //tagCountsLabel.layer.masksToBounds = true
            //tagCountsLabel.layer.cornerRadius = 4
        }
    }
}
