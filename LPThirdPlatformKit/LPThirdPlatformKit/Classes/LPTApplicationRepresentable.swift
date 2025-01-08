//
//  LPTApplicationRepresentable.swift
//  LPThirdPlatformKit
//
//  Created by gl on 2023/6/28.
//

import Foundation

// MARK: 包装 UIApplicationDelegate 代理的方法协议
@objc
public protocol LPTApplicationRepresentable {
    
    /// 对 UIApplicationDelegate 代理方法进行包装
    @objc optional
    func handleApplication(application: UIApplication,
                           didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?)
    /// 适当处理 身份验证过程结束后返回的URL
    @objc optional
    func handleOpenURL(application: UIApplication,
                       openURL: URL,
                       options: [AnyHashable : Any]?) -> Bool
    @objc optional
    func handleUniversalLink(application: UIApplication,
                             userActivity: Any,
                             options: [AnyHashable : Any]?) -> Bool
    
    
    @objc optional
    //注册远程通知
    func handleApplication(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data)
    @objc optional
    //注册远程通知失败
    func handleApplication(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error)
}
