//
//  UIViewController+mojiView.swift
//  PlanIt
//
//  Created by Ken on 16/7/2.
//  Copyright © 2016年 Ken. All rights reserved.
//
import UIKit
import Popover
extension UIViewController{
    ///发起提示
    func callAlertHUD(_ title:String, message: String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.label.text = title
        hud.detailsLabel.text = message
        //延迟隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
    
    ///发起成功提示
    func callAlertSuccess(_ title:String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
        hud.mode = MBProgressHUDMode.customView
        hud.customView = UIImageView(image: UIImage(named: "Checkmark")!)
        hud.label.text = title
        hud.bezelView.color = UIColor.colorFromHex("#CACACA")
        //延迟隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
    
    ///发起失败提示
    func callAlertFailed(_ title:String){
        var showView = self.view
        if self.navigationController != nil{
            showView = self.navigationController?.view
        }
        let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
        hud.mode = MBProgressHUDMode.customView
        hud.customView = UIImageView(image: UIImage(named: "Checkmark")!)
        hud.label.text = title
        //延迟隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
    
    ///发起系统提示
    func callAlert(_ title:String, message: String, completion: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default,
                    handler: nil)
        alertController.addAction(okAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect =  CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        
        self.present(alertController, animated: true, completion: completion)
    }
    
    ///发起询问提示
    func callAlertAsk(_ title:String, okHandler: ((UIAlertAction) -> Void)?, cancelandler: ((UIAlertAction) -> Void)?, completion: (() -> Void)?){
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .destructive, handler: okHandler)
            //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: "取消", style: .default, handler: cancelandler)
            //添加动作
            alertController.addAction(alerActionOK)
            alertController.addAction(alerActionCancel)
        
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect =  CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            }
        
            //显示alert
            self.present(alertController, animated: true, completion: completion)
    }
    
    ///用户引导页面
    func callFirstRemain(_ title:String, view: UIView, type:PopoverType = .down,showHandler: (() -> ())? = nil, dismissHandler: (() -> ())? = nil){
        //创建label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
        //自适应大小
        titleLabel.sizeToFit()
        
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.bounds.width + 30 , height: titleLabel.bounds.height + 20 ))
        titleLabel.center = aView.center
        aView.addSubview(titleLabel)
        
        ///提示弹窗参数
        let popoverOptions: [PopoverOption] = [
            .type(type),
            .cornerRadius(6.0),
            .animation(.none)
        ]
        let popover = Popover(options: popoverOptions, showHandler: showHandler, dismissHandler: dismissHandler)
        popover.showAlpha = 0.1
        popover.popoverColor = UIColor(red:0.35, green:0.64, blue:1.00, alpha:1.00)
        popover.show(aView, fromView: view)
    }

    ///用户引导页面
    func callFirstRemainMultiLine(_ title:String, view: UIView, type:PopoverType = .down,showHandler: (() -> ())? = nil, dismissHandler: (() -> ())? = nil){
        //创建label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        // 调整行间距
        let attributedString = NSMutableAttributedString(string: titleLabel.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        attributedString.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSMakeRange(0, titleLabel.text!.characters.count))
        titleLabel.attributedText = attributedString
        //自适应大小
        titleLabel.sizeToFit()
        
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.bounds.width + 30 , height: titleLabel.bounds.height + 20 ))
        titleLabel.center = aView.center
        aView.addSubview(titleLabel)
        
        ///提示弹窗参数
        let popoverOptions: [PopoverOption] = [
            .type(type),
            .cornerRadius(6.0),
            .animation(.none)
        ]
        let popover = Popover(options: popoverOptions, showHandler: showHandler, dismissHandler: dismissHandler)
        popover.showAlpha = 0.1
        popover.popoverColor = UIColor(red:0.35, green:0.64, blue:1.00, alpha:1.00)
        popover.show(aView, fromView: view)
    }
    
    ///用户引导页面
    func callFirstRemain(_ title:String, startPoint: CGPoint, type:PopoverType = .down,showHandler: (() -> ())? = nil, dismissHandler: (() -> ())? = nil){
        //创建label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
        //自适应大小
        titleLabel.sizeToFit()
        
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.bounds.width + 30 , height: titleLabel.bounds.height + 20 ))
        titleLabel.center = aView.center
        aView.addSubview(titleLabel)
        
        ///提示弹窗参数
        let popoverOptions: [PopoverOption] = [
            .type(type),
            .cornerRadius(6.0),
            .animation(.none)
        ]
        let popover = Popover(options: popoverOptions, showHandler: showHandler, dismissHandler: dismissHandler)
        popover.showAlpha = 0.1
        popover.popoverColor = UIColor(red:0.35, green:0.64, blue:1.00, alpha:1.00)
        popover.show(aView, point: startPoint)
    }
}

extension UIView{
    func pointInView(_ point: CGPoint) -> Bool{
        if point.x > bounds.width || point.x < 0 || point.y > bounds.height || point.y < 0 {
            return false
        }else{
            return true
        }
    }
}
