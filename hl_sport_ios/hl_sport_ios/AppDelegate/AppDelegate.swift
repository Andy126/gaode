//
//  AppDelegate.swift
//  hl_sport_ios
//
//  Created by 不二 on 2022/11/15.
//
/*  Swift直接派发的形式，目前没想到好的处理方式，采用纯动态化的配置形式
 故而组装放在AppDelegate中，各个组件注册也统一在此注册
 LPModule负责注册模块，生成Impl，LPModuleService中存放各模块对外公开协议
 调用方法如下:
 
 if let mineService: LPModuleServiceRegisterType = LPModule.module.fetchModule(name: "mine") {
 let mineService = mineService as! LPMineModuleServiceType
 let callback = mineService.testForCallback()
 print("test => \(callback)")
 }
 
 LPModule提供组件标识获取组件实例，协议化对外内容，各个模块如公开业务 继承自LPModuleServiceRegisterType，再添加各自公开方法，LPXXXModuleImpl实现协议内容
 */
import UIKit
import LPThirdPlatformKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    public var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let mapView = LPMap()
        
        // 设置window的rootViewController
        window?.rootViewController = mapView
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
}

