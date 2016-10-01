//
//  NSDate+mojiDate.swift
//  PlanIt
//
//  Created by Ken on 16/7/2.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

extension Date{
    ///计算此时间和结束百分比
    func percentFromCurrentTime(_ endDate: Date) -> Double{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let currentDate = Date()
        let timecurrent = currentDate.timeIntervalSince1970
        let percent = (timecurrent - timeBegin)/(timeEnd - timeBegin)
        return percent
    }
    
    ///计算此时间与结束时间相差几天
    func daysToEndDate(_ endDate: Date) -> Int{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let days = (timeEnd - timeBegin)/( 60 * 60 * 24)
        return days.toIntCarry()
    }
    
    ///计算此时间与结束时间相差几周
    func weeksToEndDate(_ endDate: Date) -> Int{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let days = (timeEnd - timeBegin)/( 60 * 60 * 24 * 7)
        return days.toIntCarry()
    }
    
    ///与现在时间比较
    func compareCurrentTime() -> String{
        var timeInterval = self.timeIntervalSinceNow
        var result = ""
        var tmp = 0
        
        //判断是否是负
        if timeInterval < 0{
            timeInterval = -timeInterval
        }
        
        //判断时间
        if timeInterval < 60{
            result += "1 分"
        }else if timeInterval / 60 < 60 {
            tmp = (timeInterval / 60 ).toIntCarry()
            result += "\(tmp) 分"
        }else if timeInterval / 60 / 60 < 24 {
            tmp = (timeInterval / 60 / 60).toIntCarry()
            result += "\(tmp) 小时"
        }else {
            tmp = (timeInterval / 60 / 60 / 24 ).toIntCarry()
            result += "\(tmp) 天"
//        }else if timeInterval / 60 / 60 / 24 / 30 < 12 {
//            tmp = (timeInterval / 60 / 60 / 24 / 30 ).toIntCarry()
//            result += "\(tmp) 月"
//        }else{
//            tmp = (timeInterval / 60 / 60 / 24 / 30 / 12).toIntCarry()
//            result += "\(tmp) 年"
        }
        return result
    }
    
    ///增加一天
    func increase1Day() -> Date? {
        let day = 1.0
        let nextDate = self.addingTimeInterval(day * 24 * 60 * 60)
        return nextDate
        
    }
    
    ///增加几天
    func increaseDays(_ day: Double) -> Date? {
        let nextDate = self.addingTimeInterval(day * 24 * 60 * 60)
        return nextDate
    }
    
    ///增加一月
    func increase1Month() -> Date? {
        var newDateComponents = DateComponents()
        newDateComponents.month = 1
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: self, options: NSCalendar.Options.init(rawValue: 0))
        return calculatedDate
    }    
    
    ///增加几月
    func increaseMonths(_ month: Int) -> Date? {
        var newDateComponents = DateComponents()
        newDateComponents.month = month
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: self, options: NSCalendar.Options.init(rawValue: 0))
        return calculatedDate
    }
    
    ///增加一年
    func increase1Year() -> Date? {
        var newDateComponents = DateComponents()
        newDateComponents.year = 1
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: self, options: NSCalendar.Options.init(rawValue: 0))
        return calculatedDate
    }
    
    ///增加几年
    func increaseYears(_ year: Int) -> Date? {
        var newDateComponents = DateComponents()
        newDateComponents.year = year
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: newDateComponents, to: self, options: NSCalendar.Options.init(rawValue: 0))
        return calculatedDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日
    func FormatToStringYYYYMMDD() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        dateFormat.locale = Locale(identifier: "zh_CN")
        dateFormat.dateStyle = .long
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 MM月DD日
    func FormatToStringMMMMDD() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("MMMMdd")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 DD日
    func FormatToStringDD() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("dd")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟
    func FormatToStringYYYYMMMMDDHHMM() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟ss秒
    func FormatToStringYYYYMMMMDDHHMMSS() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmmss")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
     ///格式化日期到字符串 YYYY年MM月
    func FormatToStringYYYYMM() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 MM月
    func FormatToStringMMMM() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("MMMM")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年
    func FormatToStringYYYY() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyy")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///格式化日期到字符串 DD日HH小时MM分钟
    func FormatToStringDDHHMM() -> String{
        let dateFormat = DateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("ddhhmm")
        dateFormat.locale = Locale(identifier: "zh_CN")
        let strDate = dateFormat.string(from: self)
        return strDate
    }
    
    ///获取这是这个月的第几周
    func getWeekOfMonth() -> Int{
        let calendar:Calendar = Calendar.current
        let dateComp:DateComponents = (calendar as NSCalendar).components( .weekOfMonth, from: self)
        return dateComp.weekOfMonth!
    }
    
    ///获取这是这个年的第几月
    func getMonthkOfYear() -> Int{
        let calendar:Calendar = Calendar.current
        let dateComp:DateComponents = (calendar as NSCalendar).components( .month, from: self)
        return dateComp.month!
    }
    
    ///获取这是这个年的第几月
    func getWeekOfYear() -> Int{
        let calendar:Calendar = Calendar.current
        let dateComp:DateComponents = (calendar as NSCalendar).components( .weekOfYear, from: self)
        return dateComp.weekOfYear!
    }
    
    ///获取这个月的第一天和最后一天
    func getMonthBeginAndEnd() -> (firstDay: Date?, lastDay: Date?){        
        let calendar:Calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: components)!
        components.month = 1
        components.day = -1
        let endOfMonth =  calendar.date(byAdding:components,
                                        to: startOfMonth)!
        return (startOfMonth, endOfMonth)
    }
    
    ///获取这个年的第一月和最后一月
    func getYearBeginAndEnd() -> (firstDay: Date?, lastDay: Date?){
        let calendar:Calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: self)
        let startOfYear = calendar.date(from: components)!
        components.year = 1
        components.day = -1
        let endOfYear =  calendar.date(byAdding:components,
                                        to: startOfYear)!
        return (startOfYear, endOfYear)
    }
 }
