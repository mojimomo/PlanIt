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
    func callAlertHUD(title:String, message: String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showHUDAddedTo(showView, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.label.text = title
        hud.detailsLabel.text = message
        //延迟隐藏
        hud.hideAnimated(true, afterDelay: 1)
    }
    
    ///发起成功提示
    func callAlertSuccess(title:String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showHUDAddedTo(showView, animated: true)
        hud.mode = MBProgressHUDMode.CustomView
        hud.customView = UIImageView(image: UIImage(named: "Checkmark")!)
        hud.label.text = title
        //延迟隐藏
        hud.hideAnimated(true, afterDelay: 1)
    }
    
    ///发起失败提示
    func callAlertFailed(title:String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showHUDAddedTo(showView, animated: true)
        hud.mode = MBProgressHUDMode.CustomView
        hud.customView = UIImageView(image: UIImage(named: "Checkmark")!)
        hud.label.text = title
        //延迟隐藏
        hud.hideAnimated(true, afterDelay: 1)
    }
    
    ///发起系统提示
    func callAlert(title:String, message: String, completion: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "好的", style: .Default,
                    handler: nil)
        alertController.addAction(okAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect =  CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        }
        
        self.presentViewController(alertController, animated: true, completion: completion)
    }
    
    ///发起询问提示
    func callAlertAsk(title:String, okHandler: ((UIAlertAction) -> Void)?, cancelandler: ((UIAlertAction) -> Void)?, completion: (() -> Void)?){
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Destructive, handler: okHandler)
            //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: cancelandler)
            //添加动作
            alertController.addAction(alerActionOK)
            alertController.addAction(alerActionCancel)
        
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect =  CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
            }
        
            //显示alert
            self.presentViewController(alertController, animated: true, completion: completion)
    }
}
