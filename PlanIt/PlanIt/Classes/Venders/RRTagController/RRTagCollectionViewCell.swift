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
        let textContent = UILabel(frame: CGRect.zero)
        textContent.layer.masksToBounds = true
        textContent.layer.cornerRadius = 4
        textContent.layer.borderWidth = 1
        textContent.layer.borderColor = UIColor(red:0.8549, green:0.851, blue:0.8353, alpha:1.0).cgColor
        textContent.font = UIFont.boldSystemFont(ofSize: 17)
        textContent.textAlignment = NSTextAlignment.center
        return textContent
    }()
    
    func initContent(_ tag: Tag) {
        self.contentView.addSubview(textContent)
        textContent.text = tag.textContent
        textContent.sizeToFit()
        textContent.frame.size.width = textContent.frame.size.width + 30
        textContent.frame.size.height = textContent.frame.size.height + 20
        isSelect = tag.isSelected
        textContent.backgroundColor = UIColor.clear
        self.textContent.layer.backgroundColor = (self.isSelect == true) ? colorSelectedTag.cgColor : colorUnselectedTag.cgColor
        self.textContent.textColor = (self.isSelect == true) ? colorTextSelectedTag : colorTextUnSelectedTag
        self.textContent.font = tagFont
    }
    
    func initAddButtonContent() {
        self.contentView.addSubview(textContent)
        textContent.text = "+"
        textContent.sizeToFit()
        textContent.frame.size = CGSize(width: 40, height: 40)
        textContent.backgroundColor = UIColor.clear
        self.textContent.layer.backgroundColor = UIColor ( red: 0.949, green: 0.9451, blue: 0.9373, alpha: 1.0 ).cgColor
        self.textContent.textColor = UIColor ( red: 0.902, green: 0.1765, blue: 0.2196, alpha: 1.0 )
    }
    
    func animateSelection(_ selection: Bool) {
        isSelect = selection
    
        self.textContent.frame.size = CGSize(width: self.textContent.frame.size.width - 20, height: self.textContent.frame.size.height - 20)
        self.textContent.frame.origin = CGPoint(x: self.textContent.frame.origin.x + 10, y: self.textContent.frame.origin.y + 10)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.textContent.layer.backgroundColor = (self.isSelect == true) ? colorSelectedTag.cgColor : colorUnselectedTag.cgColor
            self.textContent.textColor = (self.isSelect == true) ? colorTextSelectedTag : colorTextUnSelectedTag
            self.textContent.font = tagFont
            self.textContent.frame.size = CGSize(width: self.textContent.frame.size.width + 20, height: self.textContent.frame.size.height + 20)
            self.textContent.center = CGPoint(x: self.contentView.frame.size.width / 2, y: self.contentView.frame.size.height / 2)
        }, completion: nil)
    }
    
    class func contentHeight(_ content: String) -> CGSize {
        let styleText = NSMutableParagraphStyle()
        styleText.alignment = NSTextAlignment.center
        let attributs = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 17)]
        let sizeBoundsContent = (content as NSString).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributs, context: nil)
        return CGSize(width: sizeBoundsContent.width + 30, height: sizeBoundsContent.height + 20)
    }
}

