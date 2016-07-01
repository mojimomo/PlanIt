//
//  Global.swift
//  PlanIt
//
//  Created by Ken on 16/6/11.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

///判断系统是否iOS8.0以上
let IS_IOS8 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0
///导航栏背景色
let navigationBackground = UIColor.colorFromHex("#F5F4F2")
///其他导航栏背景色
let otherNavigationBackground = UIColor.whiteColor()
///导航栏控件颜色
let navigationTintColor = UIColor ( red: 0.898, green: 0.1961, blue: 0.251, alpha: 1.0 )
///导航栏字体颜色
let navigationFontColor = UIColor( red: 82 / 255, green: 86 / 255, blue:89 / 255, alpha: 1.0 )
//进度条百分比颜色
let cellPercentColor = UIColor ( red: 224 / 255, green: 221 / 255, blue:215 / 255, alpha: 1.0 )
///背景色
let allBackground = UIColor.colorFromHex("#F5F4F2")
//完成字体颜色
let FinishedFontColor = UIColor.blackColor()
///正常字体颜色
let notFinishedFontColor = UIColor.blackColor()
///未开始字体颜色
let notBeginFontColor = UIColor.colorFromHex("#E6E4E1")
///超时字体颜色
let overTimeFontColor = UIColor ( red: 236 / 255, green: 74 / 255, blue:71 / 255, alpha: 1.0 )

///导航栏字体和颜色
let navigationTitleAttribute = [ NSForegroundColorAttributeName: navigationFontColor,
                       NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 17.0)! ]
///项目计算字体颜色
let projectCountsFontColor = UIColor ( red: 205 / 255, green: 205 / 255, blue:205 / 255, alpha: 1.0 )
///项目计算字体和颜色
let projectCountsFont = UIFont(name: "PingFangSC-Light", size: 14)
///tag字体和颜色
let tagFont = UIFont(name: "PingFangSC-Light", size: 16)
///tag字体和颜色
let tagFontinstatistics = UIFont(name: "PingFangSC-Light", size: 12)
///未开始字体颜色
let switchColor = UIColor.colorFromHex("#FE6158")
