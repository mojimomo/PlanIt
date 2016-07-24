//
//  WActivityIndicator.swift
//  indicatorDemo
//
//  Created by wangshouye on 14/11/13.
//  Copyright (c) 2014年 wangshouye. All rights reserved.
//

import UIKit

class WActivityIndicator: UIView {

    private var indicator               = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    private var contentView             = UIView()
    private var bgView                  = UIView()
    
    private var label : UILabel         = UILabel()
    
    private let margin:CGFloat          = 20.0
    private let padding:CGFloat         = 4.0
    
    private let labelFontSize:CGFloat   = 16.0
    private var width : CGFloat         = 0.0
    private var height : CGFloat        = 0.0
    
    private var text                    = ""
    
    // ----------------------------------------------------------
    var title: String? {
        set{
            if newValue != nil {
                text = newValue!
            } else {
                text = ""
            }
            
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
        
        get {
            return text
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
     
        super.init(coder: aDecoder)
    }
    
    convenience init(view:UIView) {
        
        self.init(frame: view.bounds)
        self.backgroundColor = UIColor.clearColor()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object:nil, queue:NSOperationQueue.mainQueue(), usingBlock:{notification in
            
            if let superview  = self.superview {
                self.frame = superview.bounds
            }
//            self.frame =  self.superview!.bounds
            self.setNeedsDisplay()
        })
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor = UIColor.clearColor()
        bgView.alpha = 0.0
        bgView.layer.cornerRadius = 10.0
        bgView.layer.masksToBounds = true
        self.addSubview(bgView)
        
        contentView.backgroundColor = UIColor.clearColor()
        contentView.alpha = 0.0
        self.addSubview(contentView)
        
        indicator.startAnimating()
        contentView.addSubview(indicator)
        
        label.font = UIFont.systemFontOfSize(labelFontSize)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = NSTextAlignment.Center
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        
        contentView.addSubview(label)
    }
    
    override func layoutSubviews () {
        
        let frame               = self.bounds
        var indicatorFrame      = self.indicator.bounds
        var contentViewFrame    = self.contentView.bounds
        
        self.width              = indicatorFrame.size.width + (2.0 * margin)
        self.height             = indicatorFrame.size.height + (2.0 * margin)
        
        var contentViewFrameX   = floor((frame.size.width - self.width) / 2 )
        let contentViewFrameY   = floor((frame.size.height - self.height) / 2 )
        
        contentViewFrame        = CGRect(x: contentViewFrameX,
                                         y: contentViewFrameY,
                                         width: self.width,
                                         height: self.height)
        
        indicatorFrame.origin.x = floor(( contentViewFrame.size.width - indicatorFrame.size.width ) / 2)
        indicatorFrame.origin.y = floor(( contentViewFrame.size.height - indicatorFrame.size.height ) / 2)
        
        if text.characters.count != 0 {
            
            label.text = self.text;
            
            let tempString = NSString(string: self.text)
            
            let dict = [NSFontAttributeName:UIFont.systemFontOfSize(labelFontSize)]
            
            let size:CGSize = tempString.sizeWithAttributes(dict)
            
            let stringHeight = size.height
            
            var stringWidth = size.width
            
            if stringWidth > frame.size.width - 2 * margin {
                stringWidth =  frame.size.width - 4 * margin;
            }
            
            // 设置装空间view 位置
            if stringWidth > self.width {
                self.width = stringWidth
                contentViewFrameX = floor((frame.size.width - self.width) / 2 )
                contentViewFrame.origin.x = contentViewFrameX
                contentViewFrame.size.width = self.width
            }
            
            // 设置 菊花位置
            indicatorFrame.origin.x = floor(( contentViewFrame.size.width - indicatorFrame.size.width ) / 2)
            indicatorFrame.origin.y = floor(( contentViewFrame.size.height - indicatorFrame.size.height ) / 2) - 10
            
            // 设置 文字位置
            let labelX = floor((contentViewFrame.size.width - stringWidth) / 2)
            let labelY = floor(indicatorFrame.origin.y + indicatorFrame.size.height + padding * 2)
            
            let labelFrame = CGRect(x:labelX,
                                    y: labelY,
                                    width: stringWidth,
                                    height: stringHeight)
            
            label.frame = labelFrame;
        }
        
        contentView.frame = contentViewFrame
        indicator.frame = indicatorFrame
        
        let bgViewFrameX = contentViewFrame.origin.x - padding
        let bgViewFrameY = contentViewFrame.origin.y - padding
        let bgViewFrameWidth = contentViewFrame.size.width + padding * 2
        let bgViewFrameHeight = contentViewFrame.size.height + padding * 2
        
        bgView.frame = CGRect(x: bgViewFrameX,
                              y: bgViewFrameY,
                              width: bgViewFrameWidth,
                              height: bgViewFrameHeight)
    }
    
    func show (animation:Bool) {
        if animation == true {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.contentView.alpha = 1.0
                self.bgView.alpha = 0.8
            })
            
        } else {
            self.contentView.alpha = 1.0
            self.bgView.alpha = 0.8
        }
    }
    
    func hideAndRemove (animation:Bool) {
        if animation == true {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.contentView.alpha = 0.0
                self.bgView.alpha = 0.0
                }, completion: { (isFinish) -> Void in
                    self.contentView.removeFromSuperview()
                    self.bgView.removeFromSuperview()
            })
        } else {
            self.contentView.alpha = 0.0
            self.bgView.alpha = 0.0
            
            self.contentView.removeFromSuperview()
            self.bgView.removeFromSuperview()
        }
    }
    
    

}
