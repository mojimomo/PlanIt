//
//  ProcessesTableViewCell.swift
//  PlanIt
//
//  Created by Ken on 16/5/29.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class ProcessTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    
    var process = Process(){
        didSet{
            dateLabel?.text = process.recordTime
            let doneString = String(format: "0.1f", process.done)
            doneLabel?.text = doneString
            remarksLabel?.text = process.remark
        }
    }
}
