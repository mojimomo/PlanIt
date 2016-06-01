//
//  AddProcess.swift
//  PlanIt
//
//  Created by Ken on 16/5/30.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
class AddProcessView: JKBlurPopup {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 自定义宽高
        //setWidthHeight(400, 300)
        // 自定义圆角大小
        //setJKCorner(15)
        // 自定义背景模糊效果
        //setJKBlurEffect(.Light)
        
        let close = UIButton(type: .Custom)
        close.setTitle("点我关闭", forState: .Normal)
        close.setTitleColor(UIColor.greenColor(), forState: .Normal)
        close.frame = CGRectMake(0, 185, 300, 30)
        close.addTarget(self, action: "btnClose:", forControlEvents: .TouchUpInside)
        contentView.addSubview(close)
        
        
        print(contentView.frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func btnClose(sender:UIButton!) {
        dismiss()
    }
}