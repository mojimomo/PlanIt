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
        font = UIFont.systemFont(ofSize: fontSize)
  
    }
    
    func changeTextAttributeByString(_ needChangeString: String, font: UIFont, color: UIColor){
        return
        let noteString = NSMutableAttributedString(string: self.text!)
        if let index = noteString.string.range(of: needChangeString){
            let range = NSMakeRange(Int(String(describing: index.lowerBound))!, needChangeString.characters.count)
            noteString.addAttributes([NSForegroundColorAttributeName : color], range: range)
            noteString.addAttributes([NSFontAttributeName : font], range: range)
            self.attributedText = noteString
        }
    }
    
    func changeTextAttributeByRange(_ range: NSRange, font: UIFont, color: UIColor){
        let noteString = NSMutableAttributedString(string: self.text!)
        noteString.addAttributes([NSForegroundColorAttributeName : color], range: range)
        noteString.addAttributes([NSFontAttributeName : font], range: range)
        self.attributedText = noteString
    }
}

