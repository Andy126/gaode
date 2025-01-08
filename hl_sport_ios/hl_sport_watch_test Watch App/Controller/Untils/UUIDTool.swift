//
//  UUIDTool.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/5/10.
//

import Foundation

struct UUIDTool {

    static let KEYCHAIN_SERVICE: String = Bundle.main.bundleIdentifier ?? ""  // 需要项目唯一性，建议使用项目的 bundleId
    static let UUID_KEY: String = "HLSPORT513"
    
    static func createQuery() -> [String: Any] {
     
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KEYCHAIN_SERVICE, // 你的服务标识符
            kSecAttrAccount as String: UUID_KEY // 你的账户标识符
        ]
    }
    static func getUUID() -> String {
        
        // 将 UUID 保存到 Keychain
        var query = createQuery()
        query[kSecReturnData as String] = true

        //查询条目
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        var uuid: String = ""
        if status == errSecSuccess, let data = result as? Data {
            if let password = String(data: data, encoding: .utf8) {
                uuid = password
//                print("Found password: \(password)")
            } else {
                print("Password data found but could not be converted to string")
            }
        } else {
            print("No matching item found in Keychain")
            // 删除旧的条目（如果存在）
            SecItemDelete(query as CFDictionary)

            uuid = UUID().uuidString
//            query[kSecAttrGeneric as String] = uuid
            query[kSecValueData as String] = uuid.data(using: .utf8)
            // 将新的条目添加到 Keychain
            let status1 = SecItemAdd(query as CFDictionary, nil)
            
            if status1 == noErr {
                print("UUID 成功保存到 Keychain")
            } else {
                print("保存 UUID 到 Keychain 失败")
            }
        }
        
//        let keychain = Keychain(service: KEYCHAIN_SERVICE)
//        var uuid:String = ""
//        do {
//            uuid = try keychain.get(UUID_KEY) ?? ""
//        }
//        catch let error {
//            print(error)
//        }
//        print("拉取的设备： \(uuid)")
//        if uuid.isEmpty {
//            uuid = UUID().uuidString
//            do {
//                try keychain.set(uuid, key: UUID_KEY)
//            }
//            catch let error {
//                print(error)
//                uuid = ""
//            }
//        }
        return uuid
    }
}
