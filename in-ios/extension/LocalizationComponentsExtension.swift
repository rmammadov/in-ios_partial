//
//  LocalizationComponentsExtension.swift
//  in-ios
//
//  Created by Piotr Soboń on 19/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension String {
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: SettingsHelper.shared.language.bundle, value: "", comment: "")
    }
}

extension UILabel {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            if let value = newValue {
                text = value.localized
            }
        }
    }
}

extension UITextField {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            if let value = newValue {
                text = value.localized
            }
        }
    }
    
    @IBInspectable var placeholderLocalizationKey: String? {
        get { return nil }
        set {
            if let value = newValue {
                placeholder = value.localized
            }
        }
    }
}

extension UIButton {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            if let value = newValue {
                setTitle(value.localized, for: .normal)
            }
        }
    }
}

extension UITextView {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            if let value = newValue {
                text = value.localized
            }
        }
    }
}
