//
//  UIImage+mojiImage.swift
//  PlanIt
//
//  Created by Ken on 16/7/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

extension UIImage{
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage{
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context,color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}