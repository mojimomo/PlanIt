//
//  RRTagController.swift
//  RRTagController
//
//  Created by Remi Robert on 20/02/15.
//  Copyright (c) 2015 Remi Robert. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let colorUnselectedTag = UIColor ( red: 0.9451, green: 0.9412, blue: 0.9294, alpha: 1.0 )
let colorSelectedTag = UIColor.colorFromHex("#B4B2B0")

let colorTextUnSelectedTag = UIColor(red:0.2549, green:0.2667, blue:0.2784, alpha:1.0)
let colorTextSelectedTag = UIColor(red:0.2549, green:0.2667, blue:0.2784, alpha:1.0)

enum RRTagType{
    case normal
    case manage
}

class RRTagController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    fileprivate var tags: Array<Tag>!
    fileprivate var navigationBarItem: UINavigationItem!
    fileprivate var leftButton: UIBarButtonItem!
    fileprivate var rigthButton: UIBarButtonItem!
    fileprivate var _totalTagsSelected = 0
    fileprivate let addTagView = RRAddTagView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
    fileprivate var heightKeyboard: CGFloat = 0
    var type : RRTagType = .normal{
        didSet{
            if type == .normal{
                self.navigationBarItem.title = NSLocalizedString("Select Tags", comment: "选择标签")
            }else{
                self.navigationBarItem.title = NSLocalizedString("Manage Tags", comment: "")
            }
        }
    }
    var blockFinih: (( Array<Tag>,  Array<Tag>) -> ())!
    var blockCancel: (() -> ())!
    var isEditMod = false{
        didSet{
            if isEditMod {
                self.navigationBarItem.title = NSLocalizedString("Edit Tags", comment: "")
            }else{
                if type == .normal{
                    self.navigationBarItem.title = NSLocalizedString("Select Tags", comment: "选择标签")
                }else{
                    self.navigationBarItem.title = NSLocalizedString("Manage Tags", comment: "")
                }

            }
        }
    }
    var editTags = [Tag]()
    var totalTagsSelected: Int = 0
    lazy var collectionTag: UICollectionView = {
        //let layoutCollectionView = UICollectionViewFlowLayout()
        let layoutCollectionView =  UICollectionViewLeftAlignedLayout()
        layoutCollectionView.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layoutCollectionView.itemSize = CGSize(width: 90, height: 20)
        layoutCollectionView.minimumLineSpacing = 10
        layoutCollectionView.minimumInteritemSpacing = 5
        let collectionTag = UICollectionView(frame: self.view.frame, collectionViewLayout: layoutCollectionView )
        collectionTag.contentInset = UIEdgeInsets(top: 84, left: 0, bottom: 20, right: 0)
        collectionTag.delegate = self
        collectionTag.dataSource = self
        collectionTag.backgroundColor = UIColor.white
        collectionTag.register(RRTagCollectionViewCell.self, forCellWithReuseIdentifier: RRTagCollectionViewCellIdentifier)
        return collectionTag
    }()
    
    lazy var addNewTagCell: RRTagCollectionViewCell = {
        let addNewTagCell = RRTagCollectionViewCell()
        addNewTagCell.contentView.addSubview(addNewTagCell.textContent)
        addNewTagCell.textContent.text = "+"
        addNewTagCell.frame.size = CGSize(width: 40, height: 40)
        addNewTagCell.backgroundColor = UIColor ( red: 0.949, green: 0.9451, blue: 0.9373, alpha: 1.0 )
        return addNewTagCell
    }()
    
    lazy var controlPanelEdition: UIView = {
        let controlPanel = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height + 50, width: UIScreen.main.bounds.size.width, height: 50))
        controlPanel.backgroundColor = UIColor.white
        
        let buttonCancel = UIButton(frame: CGRect(x: 10, y: 10, width: 100, height: 30))
        buttonCancel.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).cgColor
        buttonCancel.layer.borderWidth = 2
        buttonCancel.backgroundColor = UIColor.white
        buttonCancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState())
        buttonCancel.setTitleColor(UIColor.black, for: UIControlState())
        buttonCancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        buttonCancel.layer.cornerRadius = 15
        buttonCancel.addTarget(self, action: #selector(RRTagController.cancelEditTag), for: UIControlEvents.touchUpInside)

        let buttonAccept = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 110, y: 10, width: 100, height: 30))
        buttonAccept.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).cgColor
        buttonAccept.layer.borderWidth = 2
        buttonAccept.backgroundColor = UIColor.white
        buttonAccept.setTitle(NSLocalizedString("Create", comment: ""), for: UIControlState())
        buttonAccept.setTitleColor(UIColor.black, for: UIControlState())
        buttonAccept.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        buttonAccept.layer.cornerRadius = 15
        buttonAccept.addTarget(self, action: #selector(RRTagController.createNewTag), for: UIControlEvents.touchUpInside)
        
        controlPanel.addSubview(buttonCancel)
        controlPanel.addSubview(buttonAccept)
        return controlPanel
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
        
        self.navigationBarItem = UINavigationItem(title: NSLocalizedString("Select Tags", comment: "选择标签"))
        self.navigationBarItem.leftBarButtonItem = self.leftButton
        
        navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        navigationBar.pushItem(self.navigationBarItem, animated: true)
        navigationBar.tintColor = navigationTintColor
        navigationBar.barTintColor = otherNavigationBackground
        return navigationBar
    }()
    
    func cancelTagController() {
        self.dismiss(animated: true, completion: { () -> Void in
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
        
        if selected.count > 3{
            callAlert(NSLocalizedString("Too Many Tags", comment: ""), message: NSLocalizedString("The number of Tags should less than 3.", comment: ""))
            return
        }
        
        self.dismiss(animated: true, completion: { () -> Void in
            self.blockFinih(selected,  unSelected)
        })
    }
    
    func cancelEditTag() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.addTagView.frame.origin.y = 0
            self.controlPanelEdition.frame.origin.y = UIScreen.main.bounds.size.height
            self.collectionTag.alpha = 1
            }) { (anim:Bool) -> Void in
            
        }
    }
    
    func createNewTag() {
        let spaceSet = CharacterSet.whitespaces
        let contentTag = addTagView.textEdit.text.trimmingCharacters(in: spaceSet)
        if strlen(contentTag) > 0 {
            let newTag = Tag(name: contentTag)
            tags.insert(newTag, at: tags.count)
            newTag.insertTag()
            collectionTag.reloadData()            
        }
        cancelEditTag()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEditMod{
            return editTags.count
        }else{
            return tags.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            if isEditMod{
                return RRTagCollectionViewCell.contentHeight(editTags[(indexPath as NSIndexPath).row].textContent)
            }else{
                if (indexPath as NSIndexPath).row < tags.count {
                    return RRTagCollectionViewCell.contentHeight(tags[(indexPath as NSIndexPath).row].textContent)
                }
                return CGSize(width: 40, height: 40)
            }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell: RRTagCollectionViewCell? = collectionView.cellForItem(at: indexPath) as? RRTagCollectionViewCell
        if isEditMod{
            if editTags[(indexPath as NSIndexPath).row].isSelected == false {
                editTags[(indexPath as NSIndexPath).row].isSelected = true
                selectedCell?.animateSelection(editTags[(indexPath as NSIndexPath).row].isSelected)
            }
            else {
                editTags[(indexPath as NSIndexPath).row].isSelected = false
                selectedCell?.animateSelection(editTags[(indexPath as NSIndexPath).row].isSelected)
            }
        }else{
            if (indexPath as NSIndexPath).row < tags.count {
                if tags[(indexPath as NSIndexPath).row].isSelected == false && totalTagsSelected >= 3{
                    return
                }
                
                if type != .manage {
                    _ = tags[(indexPath as NSIndexPath).row]
                    if tags[(indexPath as NSIndexPath).row].isSelected == false {
                        tags[(indexPath as NSIndexPath).row].isSelected = true
                        selectedCell?.animateSelection(tags[(indexPath as NSIndexPath).row].isSelected)
                        totalTagsSelected += 1
                    }
                    else {
                        tags[(indexPath as NSIndexPath).row].isSelected = false
                        selectedCell?.animateSelection(tags[(indexPath as NSIndexPath).row].isSelected)
                        totalTagsSelected -= 1
                    }
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
                let alerController = UIAlertController(title: NSLocalizedString("New Tag", comment: ""), message: "", preferredStyle: .alert)
                
                //创建TextField
                alerController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.textAlignment = .center
                    textField.placeholder = NSLocalizedString("E.g. Coding, Reading...", comment: "")
                })
                
                //添加lebel观察者
                NotificationCenter.default.addObserver(self,selector:  #selector(RRTagController.textFiledEditChanged(_:)),name: NSNotification.Name.UITextFieldTextDidChange ,object: (alerController.textFields?.first)!)
                
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: { (UIAlertAction) -> Void in
                    if alerController.textFields?.count > 0 {
                        if let textField = (alerController.textFields?.first)! ?? nil{
                            if textField.text != "" && textField.text?.characters.count < 9{
                                let spaceSet = CharacterSet.whitespaces
                                let contentTag = textField.text!.trimmingCharacters(in: spaceSet)
                                if strlen(contentTag) > 0 {
                                    if (Tag.loadDataFromName(contentTag) == nil){
                                        let newTag = Tag(name: contentTag)
                                        newTag.insertTag()
                                        if let tag = Tag.loadDataFromName(contentTag){
                                            self.tags.insert(tag, at: self.tags.count)
                                            self.collectionTag.reloadData()
                                            //删除观察者
                                            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: (alerController.textFields?.first)!)
                                        }
                                    }else{
                                        self.callAlert(NSLocalizedString("Created Failed", comment: ""), message: NSLocalizedString("Tag already exists.", comment: ""))
                                    }
                                }
                            }else{
                                self.callAlert(NSLocalizedString("Created Failed", comment: ""), message: NSLocalizedString("Tag cannot be empty or have >8 characters", comment: ""))
                            }
                        }
                    }

                })
                
                //创建UIAlertAction 取消按钮
                let alerActionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler:{(UIAlertAction) -> Void in
                    //删除观察者
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: (alerController.textFields?.first)!)
                    })

                //添加动作
                alerController.addAction(alerActionCancel)
                alerController.addAction(alerActionOK)
                
                //解决collectlayout错误
                alerController.view.setNeedsLayout()
                //显示alert
                self.present(alerController, animated: true, completion: nil)
            }
        }
     }
    
    ///观察是否超出字符
    func textFiledEditChanged(_ sender: Notification){
        let textField = sender.object as! UITextField
        let kMaxLength = 8
        let toBeString = textField.text!
        //获取高亮部分
        let selectedRange = textField.markedTextRange
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if selectedRange == nil {
            if (toBeString.characters.count > kMaxLength){
                let rangeIndex = (toBeString as NSString).rangeOfComposedCharacterSequence(at: kMaxLength)
                if rangeIndex.length == 1
                {
                    textField.text = (toBeString as NSString).substring(to: kMaxLength)
                }
                else
                {
                    let rangeRange = (toBeString as NSString).rangeOfComposedCharacterSequences(for: NSMakeRange(0, kMaxLength))
                    textField.text = (toBeString as NSString).substring(to: rangeRange.length)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isEditMod{
            let cell: RRTagCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: RRTagCollectionViewCellIdentifier, for: indexPath) as? RRTagCollectionViewCell

            let currentTag = editTags[(indexPath as NSIndexPath).row]
                cell?.initContent(currentTag)

            return cell!
            
        }else{
            let cell: RRTagCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: RRTagCollectionViewCellIdentifier, for: indexPath) as? RRTagCollectionViewCell
            
            if (indexPath as NSIndexPath).row < tags.count {
                let currentTag = tags[(indexPath as NSIndexPath).row]
                cell?.initContent(currentTag)
            }
            else {
                cell?.initAddButtonContent()
            }
            return cell!
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        // TODO: change value
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                heightKeyboard = keyboardSize.height
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4,
                    options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.controlPanelEdition.frame.origin.y = self.view.frame.size.height - self.heightKeyboard - 50
                }, completion: nil)
            }
        }
        else {
            heightKeyboard = 0
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        heightKeyboard = 0
    }
    
    func handleCancelEditMod(){
        isEditMod = false
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RRTagController.cancelTagController))
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ok"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RRTagController.finishTagController))
        tags = Tag().loadAllData()
        collectionTag.reloadData()
    }
    
    func handleDelete(){
        if isEditMod{
            let alerController = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: nil, preferredStyle: .actionSheet)
            //创建UIAlertAction 确定按钮
            let alerActionOK = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (UIAlertAction) -> Void in
                for tag in self.editTags{
                    if tag.isSelected == true{
                        tag.deleteTag()
                    }
                }
                self.handleCancelEditMod()
            })
            //创建UIAlertAction 取消按钮
            let alerActionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (UIAlertAction) -> Void in
            })
            //添加动作
            alerController.addAction(alerActionOK)
            alerController.addAction(alerActionCancel)
            //显示alert
            self.present(alerController, animated: true, completion: { () -> Void in
                
            })

        }
    }
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state ==  .began{
            let point = gesture.location(in: self.collectionTag)
            if let indexPath = self.collectionTag.indexPathForItem(at: point){
                if (indexPath as NSIndexPath).row < tags.count{
                    isEditMod = true
                    self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RRTagController.handleCancelEditMod))
                    self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: UIBarButtonItemStyle.done, target: self, action: #selector(RRTagController.handleDelete))
                    editTags = Tag().loadAllData()
                    collectionTag.reloadData()
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalTagsSelected = 0
        self.view.addSubview(collectionTag)
        self.view.addSubview(navigationBar)
        
        //创建长按选项
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RRTagController.handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGestureRecognizer)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for tag in tags{
            if tag.isSelected == true{
                totalTagsSelected += 1
            }
        }
        self.view.backgroundColor = UIColor.white
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(RRTagController.cancelTagController))
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ok"), style: .done, target: self, action: #selector(RRTagController.finishTagController))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //判断是否第一次打开此页面
        if((UserDefaults.standard.bool(forKey: "IsFirstLaunchTagManagerView") as Bool!) == false){
            if tags.count > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                if let cell = collectionTag.cellForItem(at: indexPath){
                    print("第一次打开项目页面")
                    //设置为非第一次打开此页面
                    UserDefaults.standard.set(true, forKey: "IsFirstLaunchTagManagerView")
                    //设置引导弹窗
                    self.callFirstRemain(NSLocalizedString("Press to edit", comment: ""), view:  cell)
                }
            }
        }
    }
    
    class func displayTagController(parentController: UIViewController, tagsString: [String]?,
        blockFinish: @escaping (_ selectedTags: Array<Tag>, _ unSelectedTags: Array<Tag>)->(), blockCancel: @escaping ()->()) {
        let tagController = RRTagController()
            tagController.tags = Array()
            if tagsString != nil {
                for currentTag in tagsString! {
                    tagController.tags.append(Tag(name:currentTag))
                }
            }
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.present(tagController, animated: true, completion: nil)
    }

    class func displayTagController(parentController: UIViewController, tags: [Tag]?,
        blockFinish: @escaping (_ selectedTags: Array<Tag>, _ unSelectedTags: Array<Tag>)->(), blockCancel: @escaping ()->()) {
            let tagController = RRTagController()
            tagController.tags = tags
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.present(tagController, animated: true, completion: nil)
    }
    
    class func displayTagController(parentController: UIViewController, tags: [Tag]? , type: RRTagType,
        blockFinish: @escaping (_ selectedTags: Array<Tag>, _ unSelectedTags: Array<Tag>)->(), blockCancel: @escaping ()->()) {
            let tagController = RRTagController()
            tagController.tags = tags
            tagController.blockCancel = blockCancel
            tagController.blockFinih = blockFinish
            parentController.present(tagController, animated: true, completion: nil)
            tagController.type = .manage
    }
}
