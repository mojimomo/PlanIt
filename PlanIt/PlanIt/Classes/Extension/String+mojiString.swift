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
    func FormatToNSDateYYYYMMMMDDHHMM() -> Date? {
        let date = DateTool.shareIntance.FormatToNSDateYYYYMMMMDDHHMM(string: self)
//        let dateFormat = DateFormatter()
//        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
//        dateFormat.locale = Locale(identifier: "zh_CN")
//        let date = dateFormat.date(from: self)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月DD日
    func FormatToNSDateYYYYMMMMDD() -> Date? {
        let date = DateTool.shareIntance.FormatToNSDateYYYYMMMMDD(string: self)
//        let dateFormat = DateFormatter()
//        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMdd")
//        dateFormat.locale = Locale(identifier: "zh_CN")
//        dateFormat.dateStyle = .long
//        let date = dateFormat.date(from: self)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月
    func FormatToNSDateYYYYMMMM() -> Date? {
        let date = DateTool.shareIntance.FormatToNSDateYYYYMMMM(string: self)
//        let dateFormat = DateFormatter()
//        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMM")
//        dateFormat.locale = Locale(identifier: "zh_CN")
//        let date = dateFormat.date(from: self)
        return date
    }
    
    ///字符串到格式化日期 YYYY年
    func FormatToNSDateYYYY() -> Date? {
        let date = DateTool.shareIntance.FormatToNSDateYYYY(string: self)
//        let dateFormat = DateFormatter()
//        dateFormat.setLocalizedDateFormatFromTemplate("yyyy")
//        dateFormat.locale = Locale(identifier: "zh_CN")
//        let date = dateFormat.date(from: self)
        return date
    }
    
    /// 判断是否是邮箱
    func validateEmail() -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    /// 判断是否是手机号
    func validateMobile() -> Bool {
        let phoneRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    /// 判断是否是座机号码
    func validatePhone() -> Bool {
        let phoneRegex: String = "^0(10|2[0-5789]|\\d{3})\\d{7,8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    /// 判断是否是Url
    func validateUrl() -> Bool {
        let urlRegex: String = "http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return urlTest.evaluate(with: self)
    }
    
    /// 判断是否是数字
    func validateNum() -> Bool {
        let numRegex: String = "[0-9]+"
        let numTest = NSPredicate(format: "SELF MATCHES %@", numRegex)
        return numTest.evaluate(with: self)
    }
}

extension Double{
    ///进位转换 返回不小于x的最小整数值
    func toIntCarry() -> Int{
        return Int(ceil(self))
    }
}
