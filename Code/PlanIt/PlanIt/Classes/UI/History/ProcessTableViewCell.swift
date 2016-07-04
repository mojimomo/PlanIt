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
    var unit = ""
    var process = Process(){
        didSet{
            dateLabel?.text = process.day
            let doneString = String(format: "%.1f", process.done)
            doneLabel?.text = doneString + " " + unit
            if process.remark == ""{
                remarksLabel?.text = "--"
            }else{
                remarksLabel?.text = "备注: " + process.remark
            }
        }
    }
}
