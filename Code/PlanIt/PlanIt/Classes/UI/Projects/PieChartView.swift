//
//  PieChartView.swift
//  PlanIt
//
//  Created by Ken on 16/5/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

protocol PieChartDataSource: class {
    func percentForPieChartView(sneder: PieChartView) -> Double?
}

class PieChartView: UIView {

    ///数据源
    weak var dataSource: PieChartDataSource?
    ///饼图宽
    var lineWidth: CGFloat = 18{
        didSet{
            setNeedsDisplay()
        }
    }
    ///饼图缩放尺寸
    var scale:CGFloat = 0.9{
        didSet{
            setNeedsDisplay()
        }
    }
    ///颜色
    var color: UIColor = UIColor ( red: 0.9804, green: 0.0, blue: 0.0, alpha: 1.0 )
    ///外圈颜色 默认灰色
    var outGroundColor: UIColor = UIColor(red: 202.4 / 255, green: 217.9 / 255, blue: 244.7 / 255, alpha: 1.0)
    ///饼图中心坐标
    var pieChartCenter: CGPoint{
        return convertPoint(center, fromView: superview)
    }
    ///饼图半径
    var pieChartRadius:CGFloat{
        return min(bounds.size.height, bounds.size.width)/2*scale
    }
    
    ///画图
    override func drawRect(rect: CGRect) {
        //清除所有空间
        for object in self.subviews{
            object.removeFromSuperview()
        }
        
        //百分比label
        let percentLabel = UILabel(frame: rect)
        let percent = dataSource?.percentForPieChartView(self) ?? 0.0
        percentLabel.text = "\(percent)%"
        percentLabel.textAlignment = .Center
        percentLabel.font = UIFont.boldSystemFontOfSize(24)
        self.addSubview(percentLabel)
        
        //画外圈园
        let pieChartPath = UIBezierPath(arcCenter: pieChartCenter, radius: pieChartRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        pieChartPath.lineWidth = lineWidth
        outGroundColor.set()
        pieChartPath.stroke()
        
        //百分比园
        let percentPath = UIBezierPath(arcCenter: pieChartCenter, radius: pieChartRadius, startAngle: CGFloat(2 * M_PI * 3 / 4), endAngle: CGFloat( 2 * M_PI * 3 / 4 + 2 * M_PI * percent / 100), clockwise: true)
        percentPath.lineWidth = lineWidth
        color.set()
        percentPath.stroke()
    }
}
