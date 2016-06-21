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
    
    @IBOutlet weak var doneTextField: UITextField!
    @IBOutlet weak var currentProcessTextField: UITextField!
    @IBOutlet weak var remarkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarButton = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: "finishEdit")
        self.navigationItem.rightBarButtonItem = addBarButton

        let cancelBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancelBarButton
    }
    
    func finishEdit(){
        
    }
    
    func cancel(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}
	