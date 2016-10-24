//
//  UserDefaultTool.swift
//  Markplan
//
//  Created by Ken on 16/10/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation
class UserDefaultTool: NSObject {
    /// let修饰常量是线程安全
    static let shareIntance : UserDefaultTool = UserDefaultTool()

    override init() {
        super.init()
    }
    
    //几天后推送
    var daysLocalNotifiication : Int{
        get{
            if UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int! == 0{
                UserDefaults.standard.set( 3 , forKey: "daysLocalNotifiication")
            }
            return UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "daysLocalNotifiication")
        }
    }
    //几条推送
    var numsLocalNotifiication : Int{
        get{
            if UserDefaults.standard.integer(forKey: "numsLocalNotifiication") as Int! == 0{
                UserDefaults.standard.set( 0 , forKey: "numsLocalNotifiication")
            }
            return UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "numsLocalNotifiication")
        }
    }
    
    //打开次数
    var numsOfOpenTimes : Int{
        get{
            if UserDefaults.standard.integer(forKey: "numsOfOpenTimes") as Int! == 0{
                UserDefaults.standard.set( 0 , forKey: "numsOfOpenTimes")
            }
            return UserDefaults.standard.integer(forKey: "numsOfOpenTimes") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "numsOfOpenTimes")
        }
    }
}
