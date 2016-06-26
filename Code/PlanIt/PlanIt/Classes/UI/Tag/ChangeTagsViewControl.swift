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
    
    var blockFinih: ((selectedTags: Array<Tag>, unSelectedTags: Array<Tag>) -> ())!
    var blockCancel: (() -> ())!
    
    private var tags: Array<Tag>!
    private var navigationBarItem: UINavigationItem!
    private var leftButton: UIBarButtonItem!
    private var rigthButton: UIBarButtonItem!
    private var _totalTagsSelected = 0
    
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
            self.navigationBar.pushNavigationItem(self.navigationBarItem, animated: false)
        }
    }
    
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        
        self.navigationBarItem = UINavigationItem(title: "选择标签")
        self.navigationBarItem.leftBarButtonItem = self.leftButton
        
        navigationBar.pushNavigationItem(self.navigationBarItem, animated: true)
        navigationBar.tintColor = navigationTintColor
        navigationBar.backgroundColor = navigationBackground
        return navigationBar
    }()

    func cancelTagController() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.blockCancel()
        })
    }
    
    // MARK: TagListView Delegate
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.selected = !tagView.selected
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }
    
    class func displayTagController(parentController parentController: UIViewController, tags: [Tag]?,
        blockFinish: (selectedTags: Array<Tag>, unSelectedTags: Array<Tag>)->(), blockCancel: ()->()) {
            let tagController = ChangeTagsViewControl()
            tagController.tags = tags
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.presentViewController(tagController, animated: true, completion: nil)
    }
}
