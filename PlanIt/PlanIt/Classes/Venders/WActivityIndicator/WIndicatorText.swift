//
//  WIndicatorText.swift
//  indicatorDemo
//
//  Created by wangshouye on 14/11/12.
//  Copyright (c) 2014年 wangshouye. All rights reserved.
//

import UIKit

let TagWIndicatorText       = 99999


class WIndicatorText: UIView {
    
    private let margin:CGFloat                  = 20.0
    private let maxWidth:CGFloat                = UIScreen.mainScreen().bounds.size.width - 2 * 20

    private let labelFontSize:CGFloat           = 16.0
    
    private var bgView                          = UIView()
    private var label                           = UILabel()
    
    private var labelText: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(view:UIView, text:String, timeOut interval:NSTimeInterval) {
        
        self.init(frame: view.bounds)
        self.backgroundColor = UIColor.clearColor()

        self.labelText = text
        self.tag = TagWIndicatorText
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:{notification in
            
            self.frame = self.superview!.bounds
            self.setNeedsDisplay()
        })
        

        let time = UInt64(interval) * NSEC_PER_SEC
        let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(time));

        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            
            UIView.animateWithDuration(interval, animations: { () -> Void in
                self.alpha = 0.0
            }, completion: { (isFinish ) -> Void in
                self.removeFromSuperview()
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor      = UIColor.blackColor()
        bgView.layer.cornerRadius   = 10.0
        bgView.layer.masksToBounds  = true
        
        self.addSubview(bgView)
        
        label.font                      = UIFont.systemFontOfSize(labelFontSize)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment             = .Center
        label.opaque                    = false
        label.backgroundColor           = UIColor.clearColor()
        label.textColor                 = UIColor.whiteColor()
        label.numberOfLines             = 0
        
        bgView.addSubview(label)
    }
    
    override func layoutSubviews () {
        
        let frame = self.bounds
        let tempString = NSString(string: self.labelText)

        let maxLabelSize = CGSize(width: 200, height: Int.max)

        let rect:CGRect = tempString.boundingRectWithSize(maxLabelSize,
                                                          options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                          attributes: [NSFontAttributeName:UIFont.systemFontOfSize(labelFontSize)],
                                                          context: nil)

        let stringWidth     = rect.size.width
        let stringHeight    = rect.size.height

        let bgViewWidth     = stringWidth + 2 * margin
        let bgViewHeight    = stringHeight + 2 * margin
        let bgViewX         = (frame.size.width - bgViewWidth ) / 2
        let bgViewY         = (frame.size.height - bgViewHeight ) / 2
        
        let labelX          = (bgViewWidth - stringWidth)/2
        let labelY          = (bgViewHeight - stringHeight)/2

        bgView.frame        = CGRect(x: bgViewX, y: bgViewY, width: bgViewWidth, height: bgViewHeight)
        label.frame         = CGRect(x: labelX, y: labelY, width: stringWidth, height: stringHeight)
        
        label.text          = labelText
    }
}


















