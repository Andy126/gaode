//
//  SaveSwimParam.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/18.
//

import Foundation

//@objc(SaveSwimParam)
@objcMembers
class SaveSwimParam: NSObject, Codable {
    
    //用户id
    var userId: String = ""
    //UUID
    var watchId: String = ""
    //运动数据
    var dataInfo: MotionData?
//    var dataInfo: String = ""

    //转json字符串
    func toJSON() -> String {
        if let data = try? JSONEncoder().encode(self) {
            if let str = String(data: data, encoding: .utf8) {
                return str
            }
        }
        return ""
    }
    
    //转字典
    func toDic() -> [String: String]? {
        if let data = try? JSONEncoder().encode(self) {
            if let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return dic
            }
        }
        return nil
    }
}
