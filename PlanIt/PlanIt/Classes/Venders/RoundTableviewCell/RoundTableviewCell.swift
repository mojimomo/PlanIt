//
//  RoundTableviewCell.swift
//  RoundTableviewCell
//
//  Created by ChenHao on 12/31/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

import UIKit
@IBDesignable
open class RoundTableviewCell: UITableViewCell {

    @IBInspectable open var cornerRadius: CGFloat = 22 {
        didSet {
        }
    }
    
    @IBInspectable open var roundBackgroundColor: UIColor = allBackground {
        didSet {
        }
    }
    
    @IBInspectable open var roundFrontColor: UIColor = UIColor.white {
        didSet {
        }
    }
    
    @IBInspectable open var selectedColor: UIColor = UIColor.white {
        didSet {
        }
    }
    
    @IBInspectable open var separatorLineInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0) {
        didSet {
        }
    }
    
    let Margin: CGFloat = 15
    let shapeLayer = CAShapeLayer()
    let lineLayer = CALayer()
    let roundContentView: UIView = UIView()
    var needShawdow = false
    var needPercent = false
    var percentColor = cellPercentColor
    var percent = 0.0
    var isReuse = false
    var isPercentLayer = false
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentView.addSubview(roundContentView)
        roundContentView.translatesAutoresizingMaskIntoConstraints = false
        // align roundContentView from the left and right
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[view]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": roundContentView]));
        
        // align roundContentView from the top and bottom
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": roundContentView]));
        self.contentView.backgroundColor = roundBackgroundColor
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setNeedsDisplay()
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setNeedsDisplay()
    }
    
    override open func didMoveToSuperview() {
        if let tableView = getTableview() {
            tableView.separatorStyle = .none
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        var pathRef: CGMutablePath = CGMutablePath()
        var addLine = false
        if let tableview = getTableview(),
            let indexPath = tableview.indexPath(for: self) {
                if (indexPath as NSIndexPath).row == 0 && tableview.numberOfRows(inSection: (indexPath as NSIndexPath).section) == 1 {
                    pathRef = CreateBothCornerPath()
                } else if (indexPath as NSIndexPath).row == 0 {
                    pathRef = CreateTopCornerPath()
                } else if (indexPath as NSIndexPath).row == tableview.numberOfRows(inSection: (indexPath as NSIndexPath).section) - 1 {
                    pathRef = CreateBottomCornerPath()
                    addLine = true
                } else {
                    pathRef = CreateNoneCornerPath()
                    addLine = true
                }
        }
        
        //重用释放图层
        if isReuse{
            self.contentView.layer.sublayers![0].removeFromSuperlayer()
            if isPercentLayer{
                self.contentView.layer.sublayers![0].removeFromSuperlayer()
                isPercentLayer = false
            }

        }
        
        shapeLayer.path = pathRef
        self.contentView.layer.insertSublayer(shapeLayer, at: 0)
        if isSelected || isHighlighted {
            shapeLayer.fillColor = selectedColor.cgColor
        } else {
            shapeLayer.fillColor = roundFrontColor.cgColor
        }
        
        //创建百分比图层
        if needPercent && percent != 0{
            var percentRef: CGMutablePath = CGMutablePath()
            if let tableview = getTableview(),
                let indexPath = tableview.indexPath(for: self){
                    if (indexPath as NSIndexPath).row == 0 && tableview.numberOfRows(inSection: (indexPath as NSIndexPath).section) == 1 {
                        percentRef = CreateBothCornerPathForPercent()
                    }
            }
            let percentLayer = CAShapeLayer()
            percentLayer.path = percentRef
            self.contentView.layer.insertSublayer(percentLayer, at: 1)
            if isSelected || isHighlighted {
                percentLayer.fillColor = percentColor.cgColor
            } else {
                percentLayer.fillColor = percentColor.cgColor
            }
            isPercentLayer = true
        }


        if needShawdow {
            self.layer.masksToBounds = false
            self.layer.shadowPath = pathRef
            self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            self.layer.shadowColor = UIColor.lightGray.cgColor
            self.layer.shadowOpacity = 0.7
            self.layer.shadowRadius = 4
            self.shapeLayer.masksToBounds = false
            self.shapeLayer.shadowPath = pathRef
            self.shapeLayer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            self.shapeLayer.shadowColor = UIColor.lightGray.cgColor
            self.shapeLayer.shadowOpacity = 0.7
            self.shapeLayer.shadowRadius = 4
        }

        
        if (addLine == true) {
            let lineHeight: CGFloat = (0.5 / UIScreen.main.scale)
            lineLayer.frame = CGRect(x: separatorLineInset.left, y: lineHeight, width: bounds.size.width - separatorLineInset.left - separatorLineInset.right - Margin, height: -lineHeight)
            lineLayer.backgroundColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1).cgColor
            self.layer.addSublayer(lineLayer)
        } else {
            lineLayer.removeFromSuperlayer()
        }
        
        isReuse = true
    }
    
    func getTableview() -> UITableView? {
        if let view = superview as? UITableView {
            return view
        } else {
            return superview?.superview as? UITableView
        }
    }

}

extension RoundTableviewCell {
    func CreateTopCornerPath() -> CGMutablePath {
        let pathRef: CGMutablePath = CGMutablePath()
        
        let height = self.frame.height
        let width = self.frame.width
        
        pathRef.move(to: CGPoint(x: Margin, y: height))
        pathRef.addLine(to: CGPoint(x: Margin, y: cornerRadius))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(3/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin - cornerRadius, y: 0))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(3/2 * M_PI), endAngle: CGFloat(2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin, y: height))
        pathRef.addLine(to: CGPoint(x: Margin, y: height))
        
//        CGPathMoveToPoint(pathRef, nil, Margin, height)
//        CGPathAddLineToPoint(pathRef, nil, Margin, cornerRadius)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, cornerRadius, cornerRadius, CGFloat(M_PI), CGFloat(3/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin - cornerRadius, 0)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius,cornerRadius, cornerRadius, CGFloat(3/2 * M_PI), CGFloat(2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, height)
//        CGPathAddLineToPoint(pathRef, nil, Margin, height)
        return pathRef
    }
    
    func CreateBottomCornerPath() -> CGMutablePath {
        let pathRef: CGMutablePath = CGMutablePath()
        
        let height = self.frame.height
        let width = self.frame.width
        
        pathRef.move(to: CGPoint(x: Margin, y: 0))
        pathRef.addLine(to: CGPoint(x: width - Margin, y: 0))
        pathRef.addLine(to: CGPoint(x: width - Margin, y: height - cornerRadius))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(1/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: Margin, y: height))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: CGFloat(1/2 * M_PI), endAngle: CGFloat(M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: Margin, y:  0))
        
//        CGPathMoveToPoint(pathRef, nil, Margin, 0)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, 0)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, height - cornerRadius)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius, height - cornerRadius, cornerRadius, 0, CGFloat(1/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, Margin, height)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, height - cornerRadius, cornerRadius, CGFloat(1/2 * M_PI), CGFloat(M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, Margin, 0)
        return pathRef
    }
    
    
    func CreateBothCornerPath() -> CGMutablePath {
        let pathRef: CGMutablePath = CGMutablePath()
        
        let height = self.frame.height
        let width = self.frame.width
        
        pathRef.move(to: CGPoint(x: Margin, y: height - cornerRadius))
        pathRef.addLine(to: CGPoint(x: Margin, y: cornerRadius))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(3/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin - cornerRadius, y: 0))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(3/2 * M_PI), endAngle: CGFloat(2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin, y: height - cornerRadius))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(1/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: Margin + cornerRadius, y: height))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: CGFloat(1/2 * M_PI), endAngle: CGFloat(M_PI), clockwise: false)
//        CGPathMoveToPoint(pathRef, nil, Margin, height - cornerRadius)
//        CGPathAddLineToPoint(pathRef, nil, Margin, cornerRadius)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, cornerRadius, cornerRadius, CGFloat(M_PI), CGFloat(3/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin - cornerRadius, 0)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius,cornerRadius, cornerRadius, CGFloat(3/2 * M_PI), CGFloat(2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, height - cornerRadius)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius, height - cornerRadius, cornerRadius, 0, CGFloat(1/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, Margin + cornerRadius, height)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, height - cornerRadius, cornerRadius, CGFloat(1/2 * M_PI), CGFloat(M_PI), false)
        return pathRef
    }
    
    func CreateNoneCornerPath() -> CGMutablePath {
        let pathRef: CGMutablePath = CGMutablePath()
        let height = self.frame.height
        let width = self.frame.width
//        CGPathMoveToPoint(pathRef, nil, Margin, 0)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, 0)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin, height)
//        CGPathAddLineToPoint(pathRef, nil, Margin, height)
//        CGPathAddLineToPoint(pathRef, nil, Margin, 0)
        return pathRef
    }
    
    
    func CreateBothCornerPathForPercent() -> CGMutablePath {
        let pathRef: CGMutablePath = CGMutablePath()
        
        let height = self.frame.height
        let width = self.frame.width
        let outWidth = (width - Margin * 2 - cornerRadius * 2) * CGFloat(1 - percent / 100)
        
        pathRef.move(to: CGPoint(x: Margin, y: height - cornerRadius))
        pathRef.addLine(to: CGPoint(x: Margin, y: cornerRadius))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(3/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin - cornerRadius - outWidth, y: 0))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius - outWidth, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(3/2 * M_PI), endAngle: CGFloat(2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: width - Margin - outWidth, y: height - cornerRadius))
        pathRef.addArc(center: CGPoint(x: width - Margin - cornerRadius - outWidth, y: height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(1/2.0 * M_PI), clockwise: false)
        pathRef.addLine(to: CGPoint(x: Margin + cornerRadius, y: height))
        pathRef.addArc(center: CGPoint(x: Margin + cornerRadius, y: height - cornerRadius), radius: cornerRadius, startAngle: CGFloat(1/2 * M_PI), endAngle: CGFloat(M_PI), clockwise: false)
        
//        CGPathMoveToPoint(pathRef, nil, Margin, height - cornerRadius)
//        CGPathAddLineToPoint(pathRef, nil, Margin, cornerRadius)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, cornerRadius, cornerRadius, CGFloat(M_PI), CGFloat(3/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin - cornerRadius - outWidth, 0)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius - outWidth,cornerRadius, cornerRadius, CGFloat(3/2 * M_PI), CGFloat(2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, width - Margin - outWidth, height - cornerRadius)
//        CGPathAddArc(pathRef, nil, width - Margin - cornerRadius - outWidth, height - cornerRadius, cornerRadius, 0, CGFloat(1/2.0 * M_PI), false)
//        CGPathAddLineToPoint(pathRef, nil, Margin + cornerRadius, height)
//        CGPathAddArc(pathRef, nil, Margin + cornerRadius, height - cornerRadius, cornerRadius, CGFloat(1/2 * M_PI), CGFloat(M_PI), false)
        return pathRef
    }
}
