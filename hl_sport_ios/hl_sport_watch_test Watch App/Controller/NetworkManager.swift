//
//  NetworkManager.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/10.
//

//import MJExtension
import Foundation

class NetworkManager: NSObject, ObservableObject {
    
    //单例实例
    private static let instance = NetworkManager()
    //共有静态属性
    static let shared = instance
    
    private var baseUrl = "http://10.0.8.12:8882/"
    
    private var UUIDStr = "9ED7289D-8D2C-45CA-B7E0-6EDC32923A9A"
//    @Published var netstatus = ""
    var userID: String = {
        if let uid = UserDefaults.standard.string(forKey: "HL_UserID"), !uid.isEmpty {
//            userID = uid
            return uid
        }
        return ""
    }()
    
    
    public enum LPWatchTargetType: String {
        // 生产target
        case product = "com.energyball.holo.sport.app-ios.watchkitapp"
        // 测试target
        case test    = "com.energyball.holo.sport.app-ios.test.watchkitapp"
    }

     

    
    //监听网络状态
    let netMonitor = NetworkMonitor.shared
    
    var countryCode: String = "CNY" {
        didSet {
            getBaseurl()
        }
    }

    struct ResponseInfo: Codable {
        var code: Int = 0
        var msg: String = ""
        var success: Bool = false
        var data: String = ""
    }
    
    private override init() {
        super.init()
        
        //唯一uuid
        UUIDStr = UUIDTool.getUUID()
//        print("-------------------")
//        print(UUIDStr)
        //判断系统语言并获取服务器地址
//        Locale.current.currencyCode
        if let identifier = Locale.current.currency?.identifier {
            countryCode = identifier
        } else {
            if let code = UserDefaults.standard.string(forKey: "HL_CountryCode") {
                countryCode = code
            }
        }
        getBaseurl()
    }
    
    //获取baseUrl
    func getBaseurl() {
        
        
        
        var targetBundleID = Bundle.main.bundleIdentifier
      //测试target
        if targetBundleID == LPWatchTargetType.test.rawValue{
            if countryCode == "CNY" {
                baseUrl = "http://cn.holoswim.com.cn/"
            } else {
                baseUrl = "http://us.holoswim.com.cn/"
            }
        }else{
            if countryCode == "CNY" {
                baseUrl = "https://cn.magicpupil.com/"
            } else {
                baseUrl = "https://us.magicpupil.com/"
            }
        }

        baseUrl += "holosport/api/"
        
//        if countryCode == "CNY" {
//            baseUrl = "http://cn.holoswim.com.cn/"
////            baseUrl = "http://cn.magicpupil.com.cn/"
//        } else {
//            baseUrl = "http://us.holoswim.com.cn/"
////            baseUrl = "https://us.magicpupil.com/"
//        }
//        baseUrl += "holosport/api/"
        print("url--------")
        print(baseUrl)
    }
    
    
    //查询第三方绑定设备信息
    func getDeviceInfo(completion: @escaping(String?, String?, [[String: Any]]?)->Void) {
        let url = "\(baseUrl)device/queryDeviceThirdBindByThird"
        let param = ["thirdType": "apple_watch","thirdValue": UUIDStr] as [String : Any]
        //        let param = ["userId": userID, "thirdType": "apple_watch", "thirdValue": UUIDStr] as [String : Any]
        post(url: url, param: param) { data in
            if let list = data?["list"] as? [[String: Any]], let item = list.first {
//                print("mac地址：\(item["deviceMac"])\n 设备Sn码：\(item["deviceSn"])")
                //缓存绑定数据
                UserDefaults.standard.setValue(list, forKey: "Holoswim_Bind_data")
                if let uid = item["userId"] as? Int {
                    self.userID = "\(uid)"
                    UserDefaults.standard.setValue(uid, forKey: "HL_UserID")
                }
                if let mac = item["deviceMac"] as? String {
                    //获取mac地址并缓存
                    UserDefaults.standard.setValue(mac, forKey: "Holoswim_mac")
                    UserDefaults.setInfo(true, forKey: "HL_PhoneConfigured")

                    completion(mac, self.userID, list)
                    return
                }
                //                deviceMac = "C4:19:D1:40:AF:10"
                //                deviceSn = C0301TC680010
            } else {
                //无数据更新
                //查询不到绑定信息更新缓存
                UserDefaults.standard.removeObject(forKey: "Holoswim_mac")
                UserDefaults.standard.setValue(false, forKey: "HL_PhoneConfigured")
                UserDefaults.standard.synchronize()

                completion(nil, nil, nil)
            }
        }
    }
    
    //上传数据
    func saveSwimData(info: MotionData, cache: Bool=false, complete: (([MotionData])->Void)?) {
        let url = "\(baseUrl)swim/saveAppleWatchSwimData"
        print(url)
        let param = SaveSwimParam()
        param.userId = userID
        param.watchId = UUIDStr
        param.dataInfo = info
        printLog("url===\(url)===param==\(param)")

        post(url: url, param: param, cache: cache) { data in
            //            if data["code"] as! Int == 200 {
            //                Toast(message: "上传成功")
            //            }
            //            if let json = String(data: data, encoding: .utf8) {
            //                print(json)
            //            }
            UserDefaults.setInfo(true, forKey: "Holo_SyncMotionData")
            
            if cache {
                //上传成功后删除缓存数据
                CacheManager.shared.saveWorkoutData(model: info, add: false, complete: complete)
            }
        }
    }
    
    func get(url: String, completion: @escaping([String: Any]) -> Void) {
        fetchData(url: url, method: "GET", param: nil) { response in
            if let code = response["code"] as? Int {
                if code == 200 {
                    if let data = response["data"] as? [String : Any] {
                        completion(data)
                    }
                }
            }
        }
    }
    
    func post(url: String, param: Any, cache: Bool=false, completion: @escaping([String: Any]?) -> Void) {
        fetchData(url: url, method: "POST", param: param, cache: cache) { response in
            if let code = response["code"] as? Int {
                if code == 200 {
                    let data = response["data"] as? [String : Any]
                    completion(data)
                } else {
                    if let msg = response["msg"] as? String {
                        print(msg)
                    }
                }
            }
        }
    }
    
    //离线时缓存运动数据
    func cacheMoDataByOffline(model: MotionData?) {
        guard let model = model else { return }
        //无网或请求失败时缓存未上传数据
        CacheManager.shared.saveWorkoutData(model: model, complete: nil)
    }
    
    func fetchData(url: String, method: String="GET", param: Any?, cache: Bool=false, completion: @escaping([String: Any]) -> Void) {
        //发起网络请求
        guard let URL = URL(string: url) else {
            print("invalid URL")
            return
        }
        //待缓存数据
        var cacheModata: MotionData?
        
        var request = URLRequest(url: URL)
        request.httpMethod = method
        if (param != nil) {
            print(param!)
            // 设置请求头
//            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.setValue("multipart/form-data;", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type") // 设置请求头，指明发送的是JSON数据
//            if param is [String: Any], let dic = param as? [String: Any] {
//                let body = NSMutableData()
//                for (key, value) in dic {
//                    let data = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!
////                    let data = "\"\(key)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!
//                    body.append(data)
//                }
//                request.httpBody = body as Data
//            }
           
            if param is SaveSwimParam, let info = param as? SaveSwimParam {
//                request.httpBody = info.mj_JSONString().data(using: .utf8)
                print("-------------------")
                print(info.toJSON())
                cacheModata = info.dataInfo
                
                do {
                    try
                    request.httpBody = JSONEncoder().encode(info)
//                        request.httpBody = JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                } catch {
                    print(error.localizedDescription)
//                    self.netstatus = error.localizedDescription
                    if !cache {
                        cacheMoDataByOffline(model: info.dataInfo) //离线缓存
                    }
                }
//                let dict = "".toJson(dic: dic).toDic()
//                request.httpBody = dic.mj_JSONString().data(using: .utf8)
            }
            
            if param is [String: Any], let info = param as? [String: Any] {
                do {
                    try
                    request.httpBody = JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
                } catch {
                    print(error.localizedDescription)
//                    self.netstatus = error.localizedDescription
                }
            }
        }
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if let error = error {
                //---请求失败
                print(error.localizedDescription)
//                self.netstatus = error.localizedDescription
                if !cache {
                    self.cacheMoDataByOffline(model: cacheModata) //离线缓存
                }

                return
            }
            if let data = data {
                print(data)
//                self.netstatus = "请求成功"
                print("请求成功------")
                do {
//                    let response = try JSONDecoder().decode(ResponseInfo.self, from: data)
//                    completion(response)
                    //转字典
                    let info = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let dic = info as? [String: Any] {
                        print(dic)
                        completion(dic)
                    }
                } catch {
                    print(error)
//                    self.netstatus = error.localizedDescription
                    //失败后重新请求
                    self.fetchData(url: url, method: method, param: param, completion: completion)
                }
            } else {
                print("No data in response")
//                self.netstatus = "No data in response"
            }
        }
        task.resume()
    }
}

import Network

class NetworkMonitor: NSObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    
    override init() {
        super.init()

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // 网络连接可用
                print("-------------网络可用--------------")
//                netstate = "satisfied"
                //上传缓存数据
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    WorkoutManager.shared.syncSwimData()
                }
            } else {
                // 网络连接不可用
                print("-------------网络不可用--------------")
//                netstate = "unsatisfied"
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
    
    func stopMonitor() {
        monitor.cancel()
    }
}
