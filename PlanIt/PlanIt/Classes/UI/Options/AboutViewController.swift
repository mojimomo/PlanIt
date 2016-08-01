//
//  AboutViewController.swift
//  PlanIt
//
//  Created by Yale on 16/7/26.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var memberIntro: UILabel!
    @IBOutlet var appVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //返回button
        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(AboutViewController.dismiss))
        self.navigationItem.leftBarButtonItem = backButtom
        
        //app版本label
        let ver = appVer!
        let buildVer = appBuildVer!
        appVersion.text = "版本 \(ver) (\(buildVer))"
        
        //设置介绍字体颜色大小
        let string = NSMutableAttributedString(string: memberIntro.text!)

        //也而（位置3长度2）颜色字体设置
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromHex("#949596"), range: NSMakeRange(3, 2))
        
        string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13), range: NSMakeRange(3, 2))
        
        //Steven（位置10长度6）颜色字体设置
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromHex("#949596"), range: NSMakeRange(10, 6))
        
        string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13), range: NSMakeRange(10, 6))
        
        //墨迹（位置为21长度2）颜色字体设置
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromHex("#949596"), range: NSMakeRange(21, 2))
        
        string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13), range: NSMakeRange(21, 2))
        
        //把修改好的string赋值给介绍label
        memberIntro.attributedText = string
    }
    
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


    
// MARK: 获取app版本号

let infoDic = NSBundle.mainBundle().infoDictionary

// 获取 App 的版本号
let appVer = infoDic?["CFBundleShortVersionString"]

// 获取 App 的 build 版本
let appBuildVer = infoDic?["CFBundleVersion"]
