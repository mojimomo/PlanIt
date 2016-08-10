//  OptionsTableViewController.swift
//  PlanItOptions
//
//  Created by Yale on 16/6/29.
//  Copyright © 2016年 Yale. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class OptionsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate ,UIPickerViewDataSource,UIPickerViewDelegate{

      
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
    @IBOutlet weak var localNotifiicationLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet var isNeedLocalNotifiicationSwitch: UISwitch!
    var isNeedLocalNotifiication = false
    //几天后推送
    var day : Int{
        get{
            if NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int! == 0{
                NSUserDefaults.standardUserDefaults().setInteger( 1 , forKey: "daysLocalNotifiication")
            }
            return NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int
        }
        set{
            NSUserDefaults.standardUserDefaults().setInteger( newValue , forKey: "daysLocalNotifiication")
        }
    }
    
    @IBAction func changeSwitchj(sender: UISwitch) {
        if sender.on{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isNeedLocalNotifiication")
            //删除所有推送
            Project.deleteAllNotificication()
            //创建所有推送
            let projects = Project().loadAllData()
            for project in projects{
                project.addNotification()
            }
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isNeedLocalNotifiication")
            //删除所有推送
            Project.deleteAllNotificication()
        }
    }

    var labels = ["当天", "1天", "2天", "3天", "4天", "5天", "6天"]
    var days = [1, 2, 3, 4, 5, 6, 7]
    
    //是否允许推送
    var isAllowedNotification: Bool {
        get{
            if IS_IOS8{
                let setting = UIApplication.sharedApplication().currentUserNotificationSettings()
                if setting!.hashValue != 0 {
                    return true
                }
            }
            return false
        }
        set{
        
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            print("跳转设置")
            //跳转设置g
            let url = UIApplicationOpenSettingsURLString
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: url)!){
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            if IS_IOS8{
                //创建UIAlertController
                let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
                
                //创建datepicker控件
                let numberPicker = UIPickerView()
                numberPicker.dataSource = self
                numberPicker.delegate = self
                //设置默认值
                numberPicker.selectRow(day - 1, inComponent: 0, animated: true)
                alerController.view.addSubview(numberPicker)
                
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: "确定", style: .Cancel, handler: { (UIAlertAction) -> Void in
                    self.daysLabel.text = self.labels[numberPicker.selectedRowInComponent(0)]
                    self.day = self.days[numberPicker.selectedRowInComponent(0)]
                    
                    //if self.isNeedLocalNotifiicationSwitch.on{
                        //删除所有推送
                        Project.deleteAllNotificication()
                        //创建所有推送
                        let projects = Project().loadAllData()
                        for project in projects{
                            project.addNotification()
                        }
                        
                    //}
                })
                
                //创建UIAlertAction 取消按钮
                //let alerActionCancel = UIAlertAction(title: "取消", style: .Default, handler: nil)
                
                //添加动作
                alerController.addAction(alerActionOK)
                //alerController.addAction(alerActionCancel)
                
                //let oldframe = numberPicker.frame

                
                
                if let popoverPresentationController = alerController.popoverPresentationController {
                    popoverPresentationController.sourceView = self.view
                    let rect = tableView.rectForRowAtIndexPath(indexPath)
                    popoverPresentationController.sourceRect = rect
                    
                    //配置位置
                    numberPicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height )
                    numberPicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                }else{
                    //配置位置
                    numberPicker.frame = CGRectMake(0, 0, alerController.view.bounds.width ,alerController.view.bounds.height - 50 )
                    numberPicker.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                }
                
                //显示alert
                self.presentViewController(alerController, animated: true, completion: nil)

            }
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            let tags = Tag().loadAllData()

            RRTagController.displayTagController(parentController: self, tags: tags,type: .Manage, blockFinish: { (selectedTags, unSelectedTags) -> () in
                }) { () -> () in
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            print("意见反馈")
            //邮件视窗
            
            if MFMailComposeViewController.canSendMail() {
                let mailComposeViewController = configuredMailComposeViewController()
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }else{
                self.showSendMailErrorAlert()
            }
            
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            print("给应用评分")
            //跳转appID应用
            let url = "itms-apps://itunes.apple.com/app/id1141710914"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            print("推荐应用")
            //APP介绍页面
            let link = NSURL(string: "http://www.markplan.info")
            let rect = tableView.rectForRowAtIndexPath(indexPath)
            let shareVC = UIActivityViewController(activityItems: ["我正在使用马克计划，一款简洁好用的个人项目进度管理应用。快来下载试试：","http://www.markplan.info",link!,UIImage(named: "SharePic")!], applicationActivities: nil)
            if let popoverPresentationController = shareVC.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = rect
            }
            self.presentViewController(shareVC, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            print("赞赏我们")
            //支付宝转账 url scheme
            let alipay = "alipayqr://platformapi/startapp?saId=10000007&qrcode=https://qr.alipay.com/apmiym1v5ya1dynlb5"
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "alipay://")!) {
                print("已安装支付宝")
                UIApplication.sharedApplication().openURL(NSURL(string: alipay)!)
            }
            else {
                self.showNotFoundAlipayAlert()
            }
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //设置意见反馈的邮箱控件
    func configuredMailComposeViewController() -> MFMailComposeViewController {
    
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        //app版本记录
        let ver = appVer!
        let buildVer = appBuildVer!
        
        //设置反馈邮件地址、主题及内容
        mailComposeVC.setToRecipients(["markplan@foxmail.com"])
        mailComposeVC.setSubject("马克计划 - 意见反馈")
        mailComposeVC.setMessageBody("\n\n\n\n\n\n\n\n系统版本：\(systemVersion)\n设备型号：\(modelName)\n应用版本：\(ver)(\(buildVer))", isHTML: false)
        
        return mailComposeVC
    
    }
    
    //未设置邮箱设备弹窗提示
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "无法发送邮件", message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。", preferredStyle: .Alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "好的", style: .Default) { _ in })
        self.presentViewController(sendMailErrorAlert, animated: true){}
    }
    
    //邮件反馈取消或发送后dismiss
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("取消发送")
        case MFMailComposeResultSent.rawValue:
            print("发送成功")
        default:
            break
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //未安装支付宝弹窗提示
    func showNotFoundAlipayAlert() {
        let notFoundAlipayAlert = UIAlertController(title: "未安装支付宝", message: "感谢您的赞赏!\n但目前我们仅支持支付宝打赏。", preferredStyle: .Alert)
        notFoundAlipayAlert.addAction(UIAlertAction(title: "好的", style: .Default) { _ in })
        self.presentViewController(notFoundAlipayAlert, animated: true){}
    }

    
    // MARK: - 设备信息（用于邮件反馈）
    
    //获取设备型号
    let modelName = UIDevice.currentDevice().modelName

    
    //获取系统版本
    let systemVersion = UIDevice.currentDevice().systemVersion
    
    let infoDic = NSBundle.mainBundle().infoDictionary
    
    func dismiss(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        self.tableView.showsVerticalScrollIndicator = false
        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(OptionsTableViewController.dismiss))
        self.navigationItem.leftBarButtonItem = backButtom
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 0, 25))
        self.tableView.sectionFooterHeight = 25
        self.tableView.sectionHeaderHeight = 0

    if((NSUserDefaults.standardUserDefaults().boolForKey("isNeedLocalNotifiication") as Bool!) == false){
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isNeedLocalNotifiication")
            isNeedLocalNotifiicationSwitch.setOn(false, animated: false)
        }else{
            isNeedLocalNotifiicationSwitch.setOn(true, animated: false)
        }
        
        self.daysLabel.text = "\(labels[day - 1])"
        //对back to app进行观察
        NSNotificationCenter.defaultCenter().addObserver(self,selector:  #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)),name: UIApplicationDidBecomeActiveNotification,object: nil)
    }
    
    //观察是否back to app进行刷新数据
    func applicationDidBecomeActive(notification: NSNotification){
        if isAllowedNotification{
            self.localNotifiicationLabel.text = "已开启"
        }else{
            self.localNotifiicationLabel.text = "已停用"
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //设置view背景色
        self.view.backgroundColor = allBackground
        
        //修改样式
        self.navigationController?.navigationBar.barTintColor = otherNavigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        if isAllowedNotification{
            self.localNotifiicationLabel.text = "已开启"
        }else{
            self.localNotifiicationLabel.text = "已停用"
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        //删除观察者
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int {
        return labels.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labels[row]
    }
    
    // UIPickerView行高
    func pickerView(pickerView: UIPickerView,rowHeightForComponent component: Int) -> CGFloat{
        return 35
    }


    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


//MARK: - UIDevice延展
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
