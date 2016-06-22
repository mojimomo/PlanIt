//
//  CellBackgroundView.swift
//  PlanIt
//
//  Created by Ken on 16/6/20.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
protocol BackgroundViewDataSource: class {
    func percentForCellBackgroundView(sender: CellBackgroundView) -> Double?
}

class CellBackgroundView: UIView {
    ///数据源
    weak var dataSource: BackgroundViewDataSource?
    ///颜色
    var color: UIColor = UIColor ( red: 0.7686, green: 0.7569, blue: 0.7216, alpha: 1.0 )
    
    ///画图
    override func drawRect(rect: CGRect) {
        backgroundColor = UIColor.whiteColor()
        //清除所有空间
        for object in self.subviews{
            object.removeFromSuperview()
        }
        
        //百分比label
        let percent = dataSource?.percentForCellBackgroundView(self) ?? 0.0
        
        //百分比画矩形
        let rectPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.size.width * CGFloat(percent / 100) , height: frame.size.height))
        color.set()
        rectPath.stroke()
        rectPath.fill()
    }
}
