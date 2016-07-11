//
//  UIViewController+mojiView.swift
//  PlanIt
//
//  Created by Ken on 16/7/2.
//  Copyright © 2016年 Ken. All rights reserved.
//
import UIKit

extension UIViewController{
    ///发起提示
    func callAlert(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "好的", style: .Default,
            handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    ///发起提示确定返回
    func callAlertAndBack(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "好的", style: .Default,
            handler: {(UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true) { () -> Void in
                    
                }
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
