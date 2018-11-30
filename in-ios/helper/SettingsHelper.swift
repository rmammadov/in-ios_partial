//
//  SettingsHelper.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class SettingsHelper {
    
    static let shared: SettingsHelper = SettingsHelper()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func prepareDefaultValues() {
        if defaults.string(forKey: Keys.kLanguageKey) == nil {
            let lang = Language(rawValue: Locale.current.languageCode ?? "en") ?? .english
            language = lang
        }
        if defaults.string(forKey: Keys.kSelectDelayKey) == nil {
            autoSelectDelay = .medium
        }
        if defaults.integer(forKey: Keys.kTileSizeKey) == 0 {
            tileSize = .large
        }
        
    }
    
    func setLastState(idOfView: String?) {
        defaults.set(idOfView, forKey: Keys.kLastActiveView)
    }
    
    func getLastState() -> String? {
        return defaults.string(forKey: Keys.kLastActiveView)
    }
    
    var language: Language {
        get {
            return Language(rawValue: defaults.string(forKey: Keys.kLanguageKey) ?? "en") ?? .english
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.kLanguageKey)
        }
    }
    
    var autoSelectDelay: AutoSelectDelay {
        get {
            return AutoSelectDelay(rawValue: defaults.string(forKey: Keys.kSelectDelayKey) ?? "medium") ?? .medium
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.kSelectDelayKey)
        }
    }
    
    var tileSize: TileSize {
        get {
            return TileSize(rawValue: defaults.integer(forKey: Keys.kTileSizeKey)) ?? .small
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.kTileSizeKey)
        }
    }
    
    var isSoundEnabled: Bool {
        get {
            return !defaults.bool(forKey: Keys.kSoundKey)
        }
        set {
            defaults.set(!newValue, forKey: Keys.kSoundKey)
        }
    }
    
    var lastSyncDate: Date? {
        get {
            guard let stringDate = defaults.string(forKey: Keys.kLastSyncDate) else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "mmHHddMMyyyy"
            return formatter.date(from: stringDate)
        }
        set {
            guard let date = newValue else {
                defaults.removeObject(forKey: Keys.kLastSyncDate)
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "mmHHddMMyyyy"
            defaults.set(formatter.string(from: date), forKey: Keys.kLastSyncDate)
        }
    }
    
    private struct Keys {
        static let kLastActiveView: String = "in.udf.lastActiveView.key"
        static let kLanguageKey: String = "in.udf.language.key"
        static let kSelectDelayKey: String = "in.udf.selectDelay.key"
        static let kTileSizeKey: String = "in.udf.tileSize.key"
        static let kSoundKey: String = "in.udf.sound.key"
        static let kLastSyncDate: String = "in.udf.lastSyncDate.key"
    }
}

enum Language: String {
    case english = "en"
    case french = "fr"
    case spanish = "es"
    
    var title: String {
        switch self {
        case .english:  return "languageEnglish".localized
        case .french:   return "languageFrench".localized
        case .spanish:  return "languageSpanish".localized
        }
    }
    
    var bundle: Bundle {
        let path = Bundle.main.path(forResource: self.rawValue, ofType: "lproj")
        let bundle = Bundle(path: path!)!
        return bundle
    }
    static let allValues: [Language] = [.english, .french, .spanish]
}

enum AutoSelectDelay: String {
    case short = "short"
    case medium = "medium"
    case long = "long"
    
    var seconds: Double {
        switch self {
        case .short:    return 1
        case .medium:   return 2.5
        case .long:     return 4
        }
    }
    
    var title: String {
        switch self {
        case .short:    return "selectDelayShort".localized
        case .medium:   return "selectDelayMedium".localized
        case .long:     return "selectDelayLong".localized
        }
    }
    
    static let allValues: [AutoSelectDelay] = [.short, .medium, .long]
}

enum TileSize: Int {
    case small = 1
    case large = 2

    var title: String {
        switch self {
        case .small:    return "tileSizeSmall".localized
        case .large:    return "tileSizeLarge".localized
        }
    }
    static let allValues: [TileSize] = [.small, .large]
}
