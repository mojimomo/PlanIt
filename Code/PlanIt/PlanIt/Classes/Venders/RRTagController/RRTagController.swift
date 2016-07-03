//
//  RRTagController.swift
//  RRTagController
//
//  Created by Remi Robert on 20/02/15.
//  Copyright (c) 2015 Remi Robert. All rights reserved.
//

import UIKit

let colorUnselectedTag = UIColor ( red: 0.9451, green: 0.9412, blue: 0.9294, alpha: 1.0 )
let colorSelectedTag = UIColor(red:0.8784, green:0.8667, blue:0.8549, alpha:1.0)

let colorTextUnSelectedTag = UIColor(red:0.2549, green:0.2667, blue:0.2784, alpha:1.0)
let colorTextSelectedTag = UIColor(red:0.2549, green:0.2667, blue:0.2784, alpha:1.0)

class RRTagController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var tags: Array<Tag>!
    private var navigationBarItem: UINavigationItem!
    private var leftButton: UIBarButtonItem!
    private var rigthButton: UIBarButtonItem!
    private var _totalTagsSelected = 0
    private let addTagView = RRAddTagView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
    private var heightKeyboard: CGFloat = 0
    
    var blockFinih: ((selectedTags: Array<Tag>, unSelectedTags: Array<Tag>) -> ())!
    var blockCancel: (() -> ())!
    var isEditMod = false{
        didSet{
            if isEditMod {
                self.navigationBarItem.title = "编辑标签"
            }else{
                self.navigationBarItem.title = "选择标签"
            }
        }
    }
    var editTags = [Tag]()
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
//            self.navigationBarItem = UINavigationItem(title: "选择标签")
//            self.navigationBarItem.leftBarButtonItem = self.leftButton
//            if (self._totalTagsSelected == 0) {
//                self.navigationBarItem.rightBarButtonItem = nil
//            }
//            else {
//           self.navigationBarItem.rightBarButtonItem = self.rigthButton
//            }
//            self.navigationBar.pushNavigationItem(self.navigationBarItem, animated: false)
        }
    }
    
    lazy var collectionTag: UICollectionView = {
        let layoutCollectionView = UICollectionViewFlowLayout()
        layoutCollectionView.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layoutCollectionView.itemSize = CGSizeMake(90, 20)
        layoutCollectionView.minimumLineSpacing = 10
        layoutCollectionView.minimumInteritemSpacing = 5
        let collectionTag = UICollectionView(frame: self.view.frame, collectionViewLayout: layoutCollectionView)
        collectionTag.contentInset = UIEdgeInsets(top: 84, left: 0, bottom: 20, right: 0)
        collectionTag.delegate = self
        collectionTag.dataSource = self
        collectionTag.backgroundColor = UIColor.whiteColor()
        collectionTag.registerClass(RRTagCollectionViewCell.self, forCellWithReuseIdentifier: RRTagCollectionViewCellIdentifier)
        return collectionTag
    }()
    
    lazy var addNewTagCell: RRTagCollectionViewCell = {
        let addNewTagCell = RRTagCollectionViewCell()
        addNewTagCell.contentView.addSubview(addNewTagCell.textContent)
        addNewTagCell.textContent.text = "+"
        addNewTagCell.frame.size = CGSizeMake(40, 40)
        addNewTagCell.backgroundColor = UIColor ( red: 0.949, green: 0.9451, blue: 0.9373, alpha: 1.0 )
        return addNewTagCell
    }()
    
    lazy var controlPanelEdition: UIView = {
        let controlPanel = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height + 50, UIScreen.mainScreen().bounds.size.width, 50))
        controlPanel.backgroundColor = UIColor.whiteColor()
        
        let buttonCancel = UIButton(frame: CGRectMake(10, 10, 100, 30))
        buttonCancel.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).CGColor
        buttonCancel.layer.borderWidth = 2
        buttonCancel.backgroundColor = UIColor.whiteColor()
        buttonCancel.setTitle("取消", forState: UIControlState.Normal)
        buttonCancel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        buttonCancel.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        buttonCancel.layer.cornerRadius = 15
        buttonCancel.addTarget(self, action: "cancelEditTag", forControlEvents: UIControlEvents.TouchUpInside)

        let buttonAccept = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - 110, 10, 100, 30))
        buttonAccept.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).CGColor
        buttonAccept.layer.borderWidth = 2
        buttonAccept.backgroundColor = UIColor.whiteColor()
        buttonAccept.setTitle("创建", forState: UIControlState.Normal)
        buttonAccept.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        buttonAccept.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        buttonAccept.layer.cornerRadius = 15
        buttonAccept.addTarget(self, action: "createNewTag", forControlEvents: UIControlEvents.TouchUpInside)
        
        controlPanel.addSubview(buttonCancel)
        controlPanel.addSubview(buttonAccept)
        return controlPanel
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        
        self.navigationBarItem = UINavigationItem(title: "选择标签")
        self.navigationBarItem.leftBarButtonItem = self.leftButton
        
        navigationBar.pushNavigationItem(self.navigationBarItem, animated: true)
        navigationBar.tintColor = navigationTintColor
        navigationBar.barTintColor = otherNavigationBackground
        return navigationBar
    }()
    
    func cancelTagController() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.blockCancel()
        })
    }
    
    func finishTagController() {
        var selected: Array<Tag> = Array()
        var unSelected: Array<Tag> = Array()
        
        for currentTag in tags {
            if currentTag.isSelected {
                selected.append(currentTag)
            }
            else {
                unSelected.append(currentTag)
            }
        }
        
        if selected.count > 2{
            callAlert("提交错误", message: "所选标签不能超过2个")
            return
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.blockFinih(selectedTags: selected, unSelectedTags: unSelected)
        })
    }
    
    func cancelEditTag() {
        self.view.endEditing(true)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.addTagView.frame.origin.y = 0
            self.controlPanelEdition.frame.origin.y = UIScreen.mainScreen().bounds.size.height
            self.collectionTag.alpha = 1
            }) { (anim:Bool) -> Void in
            
        }
    }
    
    func createNewTag() {
        let spaceSet = NSCharacterSet.whitespaceCharacterSet()
        let contentTag = addTagView.textEdit.text.stringByTrimmingCharactersInSet(spaceSet)
        if strlen(contentTag) > 0 {
            let newTag = Tag(name: contentTag)
            tags.insert(newTag, atIndex: tags.count)
            newTag.insertTag()
            collectionTag.reloadData()            
        }
        cancelEditTag()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEditMod{
            return editTags.count
        }else{
            return tags.count + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            if isEditMod{
                return RRTagCollectionViewCell.contentHeight(editTags[indexPath.row].textContent)
            }else{
                if indexPath.row < tags.count {
                    return RRTagCollectionViewCell.contentHeight(tags[indexPath.row].textContent)
                }
                return CGSizeMake(40, 40)
            }

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: RRTagCollectionViewCell? = collectionView.cellForItemAtIndexPath(indexPath) as? RRTagCollectionViewCell
        if isEditMod{
            if editTags[indexPath.row].isSelected == false {
                editTags[indexPath.row].isSelected = true
                selectedCell?.animateSelection(editTags[indexPath.row].isSelected)
            }
            else {
                editTags[indexPath.row].isSelected = false
                selectedCell?.animateSelection(editTags[indexPath.row].isSelected)
            }
        }else{
            if indexPath.row < tags.count {
                _ = tags[indexPath.row]
                if tags[indexPath.row].isSelected == false {
                    tags[indexPath.row].isSelected = true
                    selectedCell?.animateSelection(tags[indexPath.row].isSelected)
                    totalTagsSelected = 1
                }
                else {
                    tags[indexPath.row].isSelected = false
                    selectedCell?.animateSelection(tags[indexPath.row].isSelected)
                    totalTagsSelected = -1
                }
            }
            else {
//                            addTagView.textEdit.text = nil
//                            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4,
//                                options: UIViewAnimationOptions(), animations: { () -> Void in
//                                self.collectionTag.alpha = 0.3
//                                self.addTagView.frame.origin.y = 64
//                                }, completion: { (anim: Bool) -> Void in
//                                    self.addTagView.textEdit.becomeFirstResponder()
//                                    print("")
//                            })
                let alerController = UIAlertController(title: "创建标签", message: "请输入新的标签", preferredStyle: .Alert)
                
                //创建TextField
                alerController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.textAlignment = .Center
                    textField.placeholder = "例如: 编程, 健身"
                })
                
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: "确定", style: .Destructive, handler: { (UIAlertAction) -> Void in
                    if alerController.textFields?.count > 0 {
                        if let textField = (alerController.textFields?.first)! as? UITextField{
                            if textField.text != "" && textField.text?.characters.count < 9{
                                let spaceSet = NSCharacterSet.whitespaceCharacterSet()
                                let contentTag = textField.text!.stringByTrimmingCharactersInSet(spaceSet)
                                if strlen(contentTag) > 0 {
                                    if (Tag.loadDataFromName(contentTag) == nil){
                                        let newTag = Tag(name: contentTag)
                                        newTag.insertTag()
                                        if let tag = Tag.loadDataFromName(contentTag){
                                            self.tags.insert(tag, atIndex: self.tags.count)
                                            self.collectionTag.reloadData()
                                        }
                                    }else{
                                        self.callAlert("创建失败", message: "该标签已存在！")
                                    }
                                }
                            }else{
                                self.callAlert("创建失败", message: "标签不能为空且不能超过8个字符！")
                            }
                        }
                    }
                })
                
                //创建UIAlertAction 取消按钮
                let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: nil)

                //添加动作
                alerController.addAction(alerActionOK)
                alerController.addAction(alerActionCancel)
                
                //解决collectlayout错误
                alerController.view.setNeedsLayout()
                //显示alert
                self.presentViewController(alerController, animated: true, completion: nil)
            }
        }
     }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if isEditMod{
            let cell: RRTagCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(RRTagCollectionViewCellIdentifier, forIndexPath: indexPath) as? RRTagCollectionViewCell

            let currentTag = editTags[indexPath.row]
                cell?.initContent(currentTag)

            return cell!
            
        }else{
            let cell: RRTagCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(RRTagCollectionViewCellIdentifier, forIndexPath: indexPath) as? RRTagCollectionViewCell
            
            if indexPath.row < tags.count {
                let currentTag = tags[indexPath.row]
                cell?.initContent(currentTag)
            }
            else {
                cell?.initAddButtonContent()
            }
            return cell!
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // TODO: change value
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                heightKeyboard = keyboardSize.height
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4,
                    options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.controlPanelEdition.frame.origin.y = self.view.frame.size.height - self.heightKeyboard - 50
                }, completion: nil)
            }
        }
        else {
            heightKeyboard = 0
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        heightKeyboard = 0
    }
    
    func handleCancelEditMod(){
        isEditMod = false
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.Done, target: self, action: "cancelTagController")
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ok"), style: UIBarButtonItemStyle.Done, target: self, action: "finishTagController")
        tags = Tag().loadAllData()
        collectionTag.reloadData()
    }
    
    func handleDelete(){
        if isEditMod{
            let alerController = UIAlertController(title: "是否确定删除所选标签？", message: nil, preferredStyle: .ActionSheet)
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: "确定", style: .Destructive, handler: { (UIAlertAction) -> Void in
                for tag in self.editTags{
                    if tag.isSelected == true{
                        tag.deleteTag()
                    }
                }
                self.handleCancelEditMod()
            })
            //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: { (UIAlertAction) -> Void in
            })
            //添加动作
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            //显示alert
            self.presentViewController(alerController, animated: true, completion: { () -> Void in
                
            })

        }
    }
    
    func handleLongPress(){
        isEditMod = true
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.Done, target: self, action: "handleCancelEditMod")
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: UIBarButtonItemStyle.Done, target: self, action: "handleDelete")
        editTags = Tag().loadAllData()
        collectionTag.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalTagsSelected = 0
        self.view.addSubview(collectionTag)
        self.view.addSubview(navigationBar)
        
        //创建长按选项
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress")
        longPressGestureRecognizer.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGestureRecognizer)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Done, target: self, action: "cancelTagController")
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ok"), style: .Done, target: self, action: "finishTagController")
    }
    
    class func displayTagController(parentController parentController: UIViewController, tagsString: [String]?,
        blockFinish: (selectedTags: Array<Tag>, unSelectedTags: Array<Tag>)->(), blockCancel: ()->()) {
        let tagController = RRTagController()
            tagController.tags = Array()
            if tagsString != nil {
                for currentTag in tagsString! {
                    tagController.tags.append(Tag(name:currentTag))
                }
            }
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.presentViewController(tagController, animated: true, completion: nil)
    }

    class func displayTagController(parentController parentController: UIViewController, tags: [Tag]?,
        blockFinish: (selectedTags: Array<Tag>, unSelectedTags: Array<Tag>)->(), blockCancel: ()->()) {
            let tagController = RRTagController()
            tagController.tags = tags
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.presentViewController(tagController, animated: true, completion: nil)
    }
}
