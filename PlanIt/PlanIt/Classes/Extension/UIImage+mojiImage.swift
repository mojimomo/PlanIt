//
//  UIImage+mojiImage.swift
//  PlanIt
//
//  Created by Ken on 16/7/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

extension UIImage{
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
