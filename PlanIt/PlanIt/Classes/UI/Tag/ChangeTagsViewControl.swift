//
//  ChangeTagsViewControl.swift
//  PlanIt
//
//  Created by Ken on 16/6/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
class ChangeTagsViewControl: UIViewController, TagListViewDelegate{
//    @IBOutlet weak var tagListView: TagListView!{
//        didSet{
//            tagListView.delegate = self
//            tagListView.textFont = UIFont.systemFontOfSize(15)
//            tagListView.shadowRadius = 2
//            tagListView.shadowOpacity = 0.4
//            tagListView.shadowColor = UIColor.blackColor()
//            tagListView.shadowOffset = CGSizeMake(1, 1)
//            tagListView.alignment = .Left
//        }
//    }
    
    var blockFinih: ((_ selectedTags: Array<Tag>, _ unSelectedTags: Array<Tag>) -> ())!
    var blockCancel: (() -> ())!
    
    fileprivate var tags: Array<Tag>!
    fileprivate var navigationBarItem: UINavigationItem!
    fileprivate var leftButton: UIBarButtonItem!
    fileprivate var rigthButton: UIBarButtonItem!
    fileprivate var _totalTagsSelected = 0
    
    var totalTagsSelected: Int {
        get {
            return self._totalTagsSelected
        }
        set {
            if newValue == 0 {
                self._totalTagsSelected = 0
                return
            }
            self._totalTagsSelected += newValue
            self._totalTagsSelected = (self._totalTagsSelected < 0) ? 0 : self._totalTagsSelected
            self.navigationBarItem = UINavigationItem(title: "选择标签")
            self.navigationBarItem.leftBarButtonItem = self.leftButton
            self.navigationBar.pushItem(self.navigationBarItem, animated: false)
        }
    }
    
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
        
        self.navigationBarItem = UINavigationItem(title: "选择标签")
        self.navigationBarItem.leftBarButtonItem = self.leftButton
        
        navigationBar.pushItem(self.navigationBarItem, animated: true)
        navigationBar.tintColor = navigationTintColor
        navigationBar.backgroundColor = navigationBackground
        return navigationBar
    }()

    func cancelTagController() {
        self.dismiss(animated: true, completion: { () -> Void in
            self.blockCancel()
        })
    }
    
    // MARK: TagListView Delegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }
    
    class func displayTagController(parentController: UIViewController, tags: [Tag]?,
        blockFinish: @escaping (_ selectedTags: Array<Tag>, _ unSelectedTags: Array<Tag>)->(), blockCancel: @escaping ()->()) {
            let tagController = ChangeTagsViewControl()
            tagController.tags = tags
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.present(tagController, animated: true, completion: nil)
    }
}
