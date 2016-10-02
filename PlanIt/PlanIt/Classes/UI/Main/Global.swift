//
//  Global.swift
//  PlanIt
//
//  Created by Ken on 16/6/11.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
///判断系统是否iOS8.0以上
let IS_IOS8 = (UIDevice.current.systemVersion as NSString).doubleValue >= 8.0
///导航栏背景色
let navigationBackground = UIColor.colorFromHex("#F5F4F2")
///其他导航栏背景色
let otherNavigationBackground = UIColor.white
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
                       NSFontAttributeName: UIFont.systemFont(ofSize: 17) ]
///引导页字体和颜色
let guideTitleAttribute = [ NSForegroundColorAttributeName: UIColor.white,
                                 NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
///菜单字体和颜色
let MenuAttribute = [ NSForegroundColorAttributeName: navigationFontColor,
    NSFontAttributeName:  UIFont.systemFont(ofSize: 17) ]

///项目计算字体颜色
let projectCountsFontColor = UIColor ( red: 205 / 255, green: 205 / 255, blue:205 / 255, alpha: 1.0 )
///项目计算字体和颜色
let projectCountsFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)

///tag字体和颜色
let tagFont = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)

///tag字体和颜色
let goButtonFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)

///tag字体和颜色
let muneTableFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)

///tag字体和颜色
let tagFontinstatistics = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)

///未开始字体颜色
let switchColor = UIColor.colorFromHex("#FE6158")


