//
//  TranslationHelper.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

extension Array where Element == Translation {
    func currentTranslation() -> Translation? {
        if let translation = first(where: { $0.locale == SettingsHelper.shared.language.rawValue }) {
            return translation
        } else if let translation = first(where: { $0.locale == "en" }) {
            return translation
        }
        return first
    }
}
