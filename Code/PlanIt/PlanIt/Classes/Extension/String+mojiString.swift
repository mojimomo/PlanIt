//
//  String+mojiString.swift
//  PlanIt
//
//  Created by Ken on 16/7/2.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

extension String{
    ///字符串到格式化日期 YYYY年MM月DD日HH小时MM分钟
    func FormatToNSDateYYYYMMMMDDHHMM() -> NSDate? {
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let date = dateFormat.dateFromString(self)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月DD日
    func FormatToNSDateYYYYMMMMDD() -> NSDate? {
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMdd")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        dateFormat.dateStyle = .LongStyle
        let date = dateFormat.dateFromString(self)
        return date
    }
    
    /// 判断是否是邮箱
    func validateEmail() -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(self)
    }
    
    /// 判断是否是手机号
    func validateMobile() -> Bool {
        let phoneRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluateWithObject(self)
    }
}
