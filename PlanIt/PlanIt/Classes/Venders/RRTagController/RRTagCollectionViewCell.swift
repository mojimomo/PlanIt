//
//  RRTagCollectionViewCell.swift
//  RRTagController
//
//  Created by Remi Robert on 20/02/15.
//  Copyright (c) 2015 Remi Robert. All rights reserved.
//

import UIKit

let RRTagCollectionViewCellIdentifier = "RRTagCollectionViewCellIdentifier"

class RRTagCollectionViewCell: UICollectionViewCell {
    
    var isSelect: Bool = false
    
    lazy var textContent: UILabel! = {
        let textContent = UILabel(frame: CGRectZero)
        textContent.layer.masksToBounds = true
        textContent.layer.cornerRadius = 4
        textContent.layer.borderWidth = 1
        textContent.layer.borderColor = UIColor(red:0.8549, green:0.851, blue:0.8353, alpha:1.0).CGColor
        textContent.font = UIFont.boldSystemFontOfSize(17)
        textContent.textAlignment = NSTextAlignment.Center
        return textContent
    }()
    
    func initContent(tag: Tag) {
        self.contentView.addSubview(textContent)
        textContent.text = tag.textContent
        textContent.sizeToFit()
        textContent.frame.size.width = textContent.frame.size.width + 30
        textContent.frame.size.height = textContent.frame.size.height + 20
        isSelect = tag.isSelected
        textContent.backgroundColor = UIColor.clearColor()
        self.textContent.layer.backgroundColor = (self.isSelect == true) ? colorSelectedTag.CGColor : colorUnselectedTag.CGColor
        self.textContent.textColor = (self.isSelect == true) ? colorTextSelectedTag : colorTextUnSelectedTag
        self.textContent.font = tagFont
    }
    
    func initAddButtonContent() {
        self.contentView.addSubview(textContent)
        textContent.text = "+"
        textContent.sizeToFit()
        textContent.frame.size = CGSizeMake(40, 40)
        textContent.backgroundColor = UIColor.clearColor()
        self.textContent.layer.backgroundColor = UIColor ( red: 0.949, green: 0.9451, blue: 0.9373, alpha: 1.0 ).CGColor
        self.textContent.textColor = UIColor ( red: 0.902, green: 0.1765, blue: 0.2196, alpha: 1.0 )
    }
    
    func animateSelection(selection: Bool) {
        isSelect = selection
    
        self.textContent.frame.size = CGSizeMake(self.textContent.frame.size.width - 20, self.textContent.frame.size.height - 20)
        self.textContent.frame.origin = CGPointMake(self.textContent.frame.origin.x + 10, self.textContent.frame.origin.y + 10)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.textContent.layer.backgroundColor = (self.isSelect == true) ? colorSelectedTag.CGColor : colorUnselectedTag.CGColor
            self.textContent.textColor = (self.isSelect == true) ? colorTextSelectedTag : colorTextUnSelectedTag
            self.textContent.font = tagFont
            self.textContent.frame.size = CGSizeMake(self.textContent.frame.size.width + 20, self.textContent.frame.size.height + 20)
            self.textContent.center = CGPointMake(self.contentView.frame.size.width / 2, self.contentView.frame.size.height / 2)
        }, completion: nil)
    }
    
    class func contentHeight(content: String) -> CGSize {
        let styleText = NSMutableParagraphStyle()
        styleText.alignment = NSTextAlignment.Center
        let attributs = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:UIFont.boldSystemFontOfSize(17)]
        let sizeBoundsContent = (content as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.size.width,
            UIScreen.mainScreen().bounds.size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributs, context: nil)
        return CGSizeMake(sizeBoundsContent.width + 30, sizeBoundsContent.height + 20)
    }
}

