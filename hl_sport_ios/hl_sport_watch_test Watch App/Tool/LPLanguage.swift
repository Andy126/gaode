//
//
//  LPLanguage.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/5/27.

import Foundation

public enum LocalLanguage: String, CaseIterable {
    /// 英文
    case english = "en-US"
    /// 繁体中文
    case chineseTraditional = "zh-TW"
    /// 简体中文
    case chineseSimplified = "zh-CN"
    /// 德文
    case german = "de-DE"
    /// 日文
    case japanese = "ja-JP"
    /// 韩语
    case korean = "ko-KR"
    /// 俄文
    case russian = "ru-RU"
    /// 葡萄牙-经典
    case portuguesePT = "pt-PT"
    /// 葡萄牙-巴西
    case portugueseBR = "pt-BR"
    /// 意大利
    case italian = "it-IT"
    /// 西班牙
    case spanish = "es-ES"
    /// 法语
    case french = "fr-FR"
    
}


extension LocalLanguage {
    public var accepetLanguage: String {
        switch self {
        case .chineseSimplified:    return "zh-CN"
        case .chineseTraditional:   return "zh-TW"
        case .english:              return "en-US"
        case .japanese:             return "ja-JP"
        case .german:               return "de-DE"
        case .portugueseBR:         return "pt-BR"
        case .portuguesePT:         return "pt-PT"
        case .korean:               return "ko-KR"
        case .russian:              return "ru-RU"
        case .italian:              return "it-IT"
        case .spanish:              return "es-ES"
        case .french:               return "fr-FR"

        }
    }
    public var lprojLanguage: String {
        switch self {
        case .chineseSimplified:    return "zh-Hans"
        case .chineseTraditional:   return "zh-Hant"
        case .english:              return "en"
        case .japanese:             return "ja"
        case .german:               return "de"
        case .portugueseBR:         return "pt-BR"
        case .portuguesePT:         return "pt-PT"
        case .korean:               return "ko"
        case .russian:              return "ru"
        case .italian:              return "it"
        case .spanish:              return "es"
        case .french:               return "fr"

        }
    }

    
    public var languageName: String {
        switch self {
        case .english:              return "English"
        case .chineseTraditional:   return "繁体中文"
        case .chineseSimplified:    return "简体中文"
        case .japanese:             return "日本語"
        case .german:               return "Deutsch"
        case .korean:               return "중국어"
        case .russian:              return "Русский"
        case .portuguesePT:         return "Português(Portugal)"
        case .portugueseBR:         return "Português(Brasil)"
        case .italian:              return "Italiano"
        case .spanish:              return "Español"
        case .french:               return "Français"

        }
    }
}

extension Notification.Name {
    struct localizable {
        public static let languageChange = Notification.Name("com.hlsport.localizable.notification.name.language")
    }
}


public class LocalizableConfig {
    private enum LanguageKey: String {
        case user = "UserLanguageKey"
        case apple = "AppleLanguageKey"
    }
    
    /// 是否显示默认文本
    public var useLocalizedDefault = false
    public var localizedDefault = "localconst.localized.default"
    /// 本地化语言文件名称
    public var tableName = "Localizable"
    
    private var languageDidChange: LanguageDidChangeClosure?
    public typealias LanguageDidChangeClosure = (_ language: LocalLanguage?) -> Void
    
    static public let share = LocalizableConfig()
    private init() {}
    
    /// 设置语言
    /// - Parameter language: 语言
    public func setLocalLanguage(_ language: LocalLanguage?) {
        guard let language = language else { return resetSystemLanguage() }
        UserDefaults.standard.set(language.accepetLanguage, forKey: LanguageKey.user.rawValue)
        UserDefaults.setInfo(language.accepetLanguage, forKey: LanguageKey.apple.rawValue)
        
        languageDidChange?(language)
        NotificationCenter.default.post(name: Notification.Name.localizable.languageChange, object: self, userInfo: ["Language": language])
    }
    
    /// 获取当前本地语言
    /// - Returns: 语言
    public func localLanguage() -> LocalLanguage {
        
        let langDescription = UserDefaults.standard.value(forKey: LanguageKey.user.rawValue)
        guard let rawValue = langDescription as? String else {
            return isChina ? .chineseSimplified : foreignLanguageType()
        }
        guard let language = LocalLanguage(rawValue: rawValue) else {
            return isChina ? .chineseSimplified : foreignLanguageType()
        }
        return language
    }
    
    func foreignLanguageType() -> LocalLanguage {
        guard let languages = UserDefaults.standard.value(forKey: "AppleLanguages") as? [String], let language = languages.first else { return .english }
        return LocalLanguage.allCases.first(where: { language.contains($0.accepetLanguage) }) ?? .english
    }
    
    /// 重置本地语言为单前系统语言
    public func resetSystemLanguage() {
        UserDefaults.standard.removeObject(forKey: LanguageKey.user.rawValue)
        UserDefaults.standard.setValue(nil, forKey: LanguageKey.apple.rawValue)
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            print("当前语言:\(preferredLanguage)")
        }
    }
    
    /// 获取本地化语言对应的包
    /// - Returns: bundle or nil
    public func languageBundle() -> Bundle? {
        
        guard let path = Bundle.main.path(forResource: localLanguage().lprojLanguage, ofType: "lproj") else { return nil }
        guard let bundle = Bundle(path: path) else { return nil }
        return bundle
    }
    
    public func languageDidChange(closure: LanguageDidChangeClosure?) {
        languageDidChange = closure
    }
    
    /// 国家码
    public var countryCode: String {
        Locale.current.currencyCode ?? "CNY"
    }
    
    /// 是否为国外
    public var isChina: Bool {
        countryCode == "CNY"
    }
    
}

class LocalString {
    static let share = LocalString()
    private init() {}
    
    public func localized(_ key: String, _ defaultValue: String? = nil) -> String {
        let config = LocalizableConfig.share
        let bundle = config.languageBundle() ?? Bundle.main
        let failValue = config.useLocalizedDefault ? config.localizedDefault : key
        return bundle.localizedString(forKey: key, value: defaultValue ?? failValue, table: config.tableName)
    }
}

public extension String {
    
    /// 多语言
    public var localized: String {
        return LocalString.share.localized(self)
    }
}
