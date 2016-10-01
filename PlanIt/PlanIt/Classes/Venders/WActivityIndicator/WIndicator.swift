//
//  WIndicator.swift
//  indicatorDemo
//
//  Created by wangshouye on 14/11/8.
//  Copyright (c) 2014年 wangshouye. All rights reserved.
//

import UIKit

class WIndicator:UIView {
    
    class func showIndicatorAddedTo(_ view:UIView, animation:Bool) -> WActivityIndicator {
        
        if let tmpView = view.viewWithTag(TagWIndicatorText) {
            
            tmpView.alpha = 0.0
            
            tmpView.removeFromSuperview()
        }
        
        removeIndicatorFrom(view, animation: false)
        
        let resultView = WActivityIndicator(view: view)
        view.addSubview(resultView)
        
        resultView.show(animation)
        
        return resultView
    }
    
    class func removeIndicatorFrom(_ view:UIView, animation:Bool) {
        
        var indicatorView: WActivityIndicator?
        
        for tempView in view.subviews {
            if tempView is WActivityIndicator {
                indicatorView = (tempView as! WActivityIndicator)
                break
            }
        }
        
        if let view = indicatorView {
            view.hideAndRemove(true)
            view.removeFromSuperview()
        }
    }
    
    class func showMsgInView(_ view: UIView, text:String, timeOut interval:TimeInterval) -> WIndicatorText {
        
        if let tmpView = view.viewWithTag(TagWIndicatorText) {
            
            tmpView.alpha = 0.0
            
            tmpView.removeFromSuperview()
        }
        
        removeIndicatorFrom(view, animation: false)
        
        
        let indicatorTextView = WIndicatorText(view: view, text: text, timeOut: interval)
        view.addSubview(indicatorTextView)
        
        return indicatorTextView
    }
    
}









