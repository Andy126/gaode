//
//  CacheManager.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/5/13.
//

import Foundation
import CryptoKit

struct CacheManager {
    //单例实例
    private static let instance = CacheManager()
    //共有静态属性
    static let shared = instance
    
//    private init() {
//        self.init()
//    }
    
    // 生成密钥
    let UKEY = SymmetricKey(size: .bits256)

    //用户id
//    var UID: String = {
//        if let uid = UserDefaults.standard.string(forKey: "HL_UserID") {
//            return uid
//        }
//        return ""
//    }()
    
    // 加密函数
    func encrypt(data: Data) -> Data {
//        let data = text.data(using: .utf8)!
        let sealedBox = try! AES.GCM.seal(data, using: UKEY)
        return sealedBox.combined!
    }

    // 解密函数
    func decrypt(data: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: UKEY)
            return decryptedData
        } catch {
            print(error)
        }
        return nil
//        return String(data: decryptedData, encoding: .utf8)!
    }
    
    //缓存路径
    private func getCacheUrl() -> URL {
        let UID = UserDefaults.standard.string(forKey: "HL_UserID") ?? ""
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheURL = urls.first!.appendingPathComponent("HLUser\(UID).encrypted")
        return cacheURL
    }
    
    //缓存数据
    func cacheFile(data: Data) {
        do {
            let cacheURL = getCacheUrl()
            try data.write(to: cacheURL)
            print("Data cached successfully.")
        } catch {
            print("Error caching data: \(error)")
        }
    }
    
    //读取缓存数据
    func getUserData() -> UserCacheData? {
        do {
            let cacheURL = getCacheUrl()
            if let encryptedData = try? Data(contentsOf: cacheURL) {
                //解密
//                guard let decryptedData = decrypt(data: encryptedData) else { return nil }
                //解码
                let info = try JSONDecoder().decode(UserCacheData.self, from: encryptedData)
                info.data.sort { item1, item2 in
                    item1.endTimestamp > item2.endTimestamp
                }
                return info
            } else {
                print("No encrypted data found.")
            }
        } catch {
            print("Error decrypting or parsing data: \(error)")
        }
        
        return nil
    }
    
    //查询训练数据
    func getWorkoutData() -> [MotionData] {
        if let data = getUserData() {

            return data.data
        }
        return [MotionData]()
    }
        
    //保存训练数据
    func saveWorkoutData(model: MotionData, add: Bool=true, complete:(([MotionData])->Void)?) {
        do {
            var uinfo = UserCacheData()
            //获取用户缓存数据
            if let userData = getUserData() {
                //追加用户模型数据
                uinfo = userData
                if add {
                    if !uinfo.data.contains(where: { item in
                        item.endTimestamp == model.endTimestamp
                    }) {
                        uinfo.data.insert(model, at: 0)
                    } else {
                        //已存在缓存数据
                        return
                    }
                } else {
                    //删除数据
                    uinfo.data.removeAll { item in
                        item.endTimestamp == model.endTimestamp
                    }
//                    if uinfo.data.isEmpty {
//                        //删除缓存文件
//                        delCacheFile()
//                        UserDefaults.standard.setValue(true, forKey: "Holo_SyncMotionData")
//                        complete?([MotionData]())
//                        return
//                    }
                }
            } else {
                //新建用户数据模型
//                uinfo.userId = UID
                uinfo.userId = UserDefaults.standard.string(forKey: "HL_UserID") ?? ""
                uinfo.data = [model]
            }
            
            //编码
            let data = try JSONEncoder().encode(uinfo)
            //加密
//            let encryData = encrypt(data: data)
            //缓存文件
            cacheFile(data: data)
            UserDefaults.setInfo(true, forKey: "Holo_SyncMotionData")

            complete?(uinfo.data)
        } catch {
            print(error)
        }
    }
    
    //删除训练数据
    func delCacheFile() {
        
        let fileManager = FileManager.default
        let filePath = getCacheUrl().absoluteString
        do {
            // 检查文件是否存在
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
                print("文件已成功删除: \(filePath)")
                UserDefaults.setInfo(true, forKey: "Holo_SyncMotionData")
            } else {
                print("文件不存在: \(filePath)")
            }
        } catch {
            // 处理删除文件时发生的错误
            print("删除文件时发生错误: \(error)")
        }
    }
}

extension UserDefaults {
    
    static func setInfo(_ value: Any?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
