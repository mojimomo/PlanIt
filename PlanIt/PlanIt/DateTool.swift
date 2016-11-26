//
//  DateTool.swift
//  Markplan
//
//  Created by Ken on 16/10/4.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation
class DateTool: NSObject {
    /// let修饰常量是线程安全
    static let shareIntance : DateTool = DateTool()
    
    override init() {
        super.init()
        dateFormatYYYYMMDD.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        dateFormatYYYYMMDD.dateStyle = .long
        
        dateFormatYYYYMMDDCN.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        dateFormatYYYYMMDDCN.locale = Locale(identifier: "zh_CN")
        dateFormatYYYYMMDDCN.dateStyle = .long
        
        dateFormatMMMMDD.setLocalizedDateFormatFromTemplate("MMMMdd")

        dateFormatDD.setLocalizedDateFormatFromTemplate("dd")
        
        dateFormatYYYYMMMMDDHHMM.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
        
        dateFormatYYYYMMMMDDHHMMCN.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
        dateFormatYYYYMMMMDDHHMMCN.locale = Locale(identifier: "zh_CN")
        
        dateFormatYYYYMMMMDDHHMMSS.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmmss")
        
        dateFormatHHMM.setLocalizedDateFormatFromTemplate("HH:mm")
        
        dateFormatYYYYMM.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        
        dateFormatMMMM.setLocalizedDateFormatFromTemplate("MMMM")
        
        dateFormatYYYY.setLocalizedDateFormatFromTemplate("yyyy")
        
        dateFormatDDHHMM.setLocalizedDateFormatFromTemplate("ddhhmm")
        
    }

    var dateFormatYYYYMMDD = DateFormatter()
    
    var dateFormatYYYYMMDDCN = DateFormatter()
    
    var dateFormatMMMMDD = DateFormatter()
    
    var dateFormatDD = DateFormatter()
    
    var dateFormatHHMM = DateFormatter()
    
    var dateFormatYYYYMMMMDDHHMM = DateFormatter()
    
    var dateFormatYYYYMMMMDDHHMMCN = DateFormatter()
    
    var dateFormatYYYYMMMMDDHHMMSS = DateFormatter()
    
    var dateFormatYYYYMM = DateFormatter()
    
    var dateFormatMMMM = DateFormatter()
    
    var dateFormatYYYY = DateFormatter()
    
    var dateFormatDDHHMM = DateFormatter()
    
    ///格式化日期到字符串 YYYY年MM月DD日
    func FormatToStringYYYYMMDD(date: Date) -> String{
        let strDate = dateFormatYYYYMMDD.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日
    func FormatToStringYYYYMMDDCN(date: Date) -> String{
        let strDate = dateFormatYYYYMMDDCN.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 MM月DD日
    func FormatToStringMMMMDD(date: Date) -> String{
        let strDate = dateFormatMMMMDD.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 DD日
    func FormatToStringDD(date: Date) -> String{
        let strDate = dateFormatDD.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟
    func FormatToStringYYYYMMMMDDHHMM(date: Date) -> String{
        let strDate = dateFormatYYYYMMMMDDHHMM.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟ss秒
    func FormatToStringYYYYMMMMDDHHMMSS(date: Date) -> String{
        let strDate = dateFormatYYYYMMMMDDHHMMSS.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 HH小时MM分钟
    func FormatToStringHHMM(date: Date) -> String{
        let strDate = dateFormatHHMM.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月
    func FormatToStringYYYYMM(date: Date) -> String{
        let strDate = dateFormatYYYYMM.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 MM月
    func FormatToStringMMMM(date: Date) -> String{
        let strDate = dateFormatMMMM.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年
    func FormatToStringYYYY(date: Date) -> String{
        let strDate = dateFormatYYYY.string(from: date)
        return strDate
    }
    
    ///格式化日期到字符串 DD日HH小时MM分钟
    func FormatToStringDDHHMM(date: Date) -> String{
        let strDate = dateFormatDDHHMM.string(from: date)
        return strDate
    }
    
    ///字符串到格式化日期 YYYY年MM月DD日HH小时MM分钟
    func FormatToNSDateYYYYMMMMDDHHMM(string: String) -> Date? {
        let date = dateFormatYYYYMMMMDDHHMM.date(from: string)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月DD日HH小时MM分钟
    func FormatToNSDateYYYYMMMMDDHHMMCN(string: String) -> Date? {
        let date = dateFormatYYYYMMMMDDHHMMCN.date(from: string)
        return date
    }

    ///字符串到格式化日期 YYYY年MM月DD日
    func FormatToNSDateYYYYMMMMDD(string: String) -> Date? {
        let date = dateFormatYYYYMMDD.date(from: string)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月DD日
    func FormatToNSDateYYYYMMMMDDCN(string: String) -> Date? {
        let date = dateFormatYYYYMMDDCN.date(from: string)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月
    func FormatToNSDateYYYYMMMM(string: String) -> Date? {
        let date = dateFormatYYYYMM.date(from: string)
        return date
    }
    
    ///字符串到格式化日期 YYYY年MM月
    func FormatToNSDateHHMM(string: String) -> Date? {
        let date = dateFormatHHMM.date(from: string)
        return date
    }
    
    ///字符串到格式化日期 YYYY年
    func FormatToNSDateYYYY(string: String) -> Date? {
        let date = dateFormatYYYY.date(from: string)
        return date
    }
}

