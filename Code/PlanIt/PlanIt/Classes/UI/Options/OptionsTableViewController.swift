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
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet var isNeedLocalNotifiicationSwitch: UISwitch!
    var isNeedLocalNotifiication = false
    //几天后推送
    var day : Int{
        get{
            if NSUserDefaults.standardUserDefaults().integerForKey("daysLocalNotifiication") as Int! == 0{
                NSUserDefaults.standardUserDefaults().setInteger( 3 , forKey: "daysLocalNotifiication")
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

    var labels = ["1天", "2天", "3天", "4天", "5天", "6天", "7天"]
    var days = [1, 2, 3, 4, 5, 6, 7]
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            if IS_IOS8{
                //创建datepicker控件
                let numberPicker = UIPickerView()
                numberPicker.dataSource = self
                numberPicker.delegate = self
                
                //创建UIAlertController
                let alerController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
                alerController.view.addSubview(numberPicker)
                
                //创建UIAlertAction 确定按钮
                let alerActionOK = UIAlertAction(title: "确定", style: .Default, handler: { (UIAlertAction) -> Void in
                    self.daysLabel.text = self.labels[numberPicker.selectedRowInComponent(0)]
                    self.day = self.days[numberPicker.selectedRowInComponent(0)]
                    
                    if self.isNeedLocalNotifiicationSwitch.on{
                        //删除所有推送
                        Project.deleteAllNotificication()
                        //创建所有推送
                        let projects = Project().loadAllData()
                        for project in projects{
                            project.addNotification()
                        }
                        
                    }
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
            let url = "itms-apps://itunes.apple.com/app/id000000000"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            print("推荐应用")
            //APP介绍页面
            let link = NSURL(string: "http://zoomyale.com")
            let shareVC = UIActivityViewController(activityItems: ["我正在使用PlanIt，一款简洁好用的个人项目进度管理应用。快来下载试试：","http://zoomyale.com",link!,UIImage(named: "about")!], applicationActivities: nil)
            self.presentViewController(shareVC, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            print("赞赏我们")
            //支付宝转账 url scheme
            let alipay = "alipayqr://platformapi/startapp?saId=10000007&qrcode=https://qr.alipay.com/apmiym1v5ya1dynlb5"
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: alipay)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: alipay)!)
            }
            else {
                self.showNotFoundAlipayAlert()
            }
        }
        
    }
    
    //设置意见反馈的邮箱控件
    func configuredMailComposeViewController() -> MFMailComposeViewController {
    
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        //设置反馈邮件地址、主题及内容
        mailComposeVC.setToRecipients(["yale.ling.chn@gmail.com"])
        mailComposeVC.setSubject("PlanIt - 意见反馈")
        mailComposeVC.setMessageBody("\n\n\n\n\n\n\n\n\n系统版本：\(systemVersion)\n设备型号：\(deviceModel)", isHTML: false)
        
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
    let deviceModel = UIDevice.currentDevice().model
    
    //获取系统版本
    let systemVersion = UIDevice.currentDevice().systemVersion
    
    func dismiss(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - ViewLife
    override func viewDidLoad() {
        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: "dismiss")
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
        
        self.daysLabel.text = "\(day)天"
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
