//
//  UserCacheData.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/5/13.
//

import UIKit

class UserCacheData: NSObject, Codable {

    //用户id
    var userId: String = ""
    //运动数据
    var data = [MotionData]()
    
}
