//
//  AddProcess.swift
//  PlanIt
//
//  Created by Ken on 16/5/30.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
class AddProcessView: JKBlurPopup {

    var doneLabel: UILabel?
    var doneTextField: UITextField?
    var acceptButton: UIButton?
    var closeButton: UIButton?
    
    var margin: CGFloat = 10
    var viewConstraints = [NSLayoutConstraint]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 自定义宽高
        //setWidthHeight(400, 300)
        // 自定义圆角大小
        //setJKCorner(15)
        // 自定义背景模糊效果
        //setJKBlurEffect(.Light)
        doneLabel = UILabel(frame: CGRectMake(0 + margin, 0 + margin, 300, 30))
        doneLabel?.text = "完成量"
        doneLabel?.textColor = UIColor.greenColor()
        
        contentView.addSubview(doneLabel!)
        
        closeButton = UIButton(frame: CGRectMake(0, 185, 300, 30))
        closeButton?.setTitle("点我关闭", forState: .Normal)
        closeButton?.setTitleColor(UIColor.greenColor(), forState: .Normal)
        closeButton?.addTarget(self, action: "btnClose:", forControlEvents: .TouchUpInside)
        contentView.addSubview(closeButton!)        
        
        print(contentView.frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func btnClose(sender:UIButton!) {
        dismiss()
    }
}