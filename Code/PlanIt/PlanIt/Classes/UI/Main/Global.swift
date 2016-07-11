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
let navigationFontColor = UIColor.colorFromHex("#525659")
///导航栏阴影颜色
let navigationShadowsColor = UIColor.colorFromHex("#E6E4E1")
//进度条百分比颜色
let cellPercentColor = UIColor.colorFromHex("#E6E4E1")
///背景色
let allBackground = UIColor.colorFromHex("#F5F4F2")
//完成字体颜色
let FinishedFontColor = UIColor.colorFromHex("#525659")
///正常字体颜色
let notFinishedFontColor = UIColor.colorFromHex("#525659")
///未开始字体颜色
let notBeginFontColor = UIColor.colorFromHex("#E6E4E1")
///超时字体颜色
let overTimeFontColor = UIColor.colorFromHex("#EC4A4D")
///导航栏字体和颜色
let navigationTitleAttribute = [ NSForegroundColorAttributeName: navigationFontColor,
                       NSFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 17.0)! ]

///菜单字体和颜色
let MenuAttribute = [ NSForegroundColorAttributeName: navigationFontColor,
    NSFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 17.0)! ]

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



