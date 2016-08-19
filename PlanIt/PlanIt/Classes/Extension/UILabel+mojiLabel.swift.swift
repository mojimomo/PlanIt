//
//  UILabel+mojiLabel.swift
//  PlanIt
//
//  Created by Ken on 16/7/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(fontSize:CGFloat,fontColor:UIColor) {
        self.init()
        
        textColor = fontColor
        font = UIFont.systemFontOfSize(fontSize)
  
    }
    
    func changeTextAttributeByString(needChangeString: String, font: UIFont, color: UIColor){
        let noteString = NSMutableAttributedString(string: self.text!)
        if let index = noteString.string.rangeOfString(needChangeString){
            let range = NSMakeRange(Int(String(index.startIndex))!, needChangeString.characters.count)
            noteString.addAttributes([NSForegroundColorAttributeName : color], range: range)
            noteString.addAttributes([NSFontAttributeName : font], range: range)
            self.attributedText = noteString
        }
    }
    
    func changeTextAttributeByRange(range: NSRange, font: UIFont, color: UIColor){
        let noteString = NSMutableAttributedString(string: self.text!)
        noteString.addAttributes([NSForegroundColorAttributeName : color], range: range)
        noteString.addAttributes([NSFontAttributeName : font], range: range)
        self.attributedText = noteString
    }
}

