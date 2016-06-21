//
//  addProcessTableViewController.swift
//  PlanIt
//
//  Created by Ken on 16/6/19.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class AddProcessTableViewController: UITableViewController {
    var project = Project()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarButton = UIBarButtonItem(image: UIImage(named: "edit"), style: .Done, target: self, action: "finishEdit:")
        self.navigationItem.rightBarButtonItem = addBarButton
    }
}
