//
//  SettingsInterfaceViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class SettingsInterfaceViewModel: BaseViewModel {
    
    var selectedLanguage: Language?
    var selectedTileSize: TileSize?
    var selectedAutoSelectDelay: AutoSelectDelay?
    var isSoundEnabled: Bool?
    
    enum TextFiledTag: Int {
        case language = 1
        case autoSelectDelay = 2
        case tileSize = 3
        case sound = 4
    }
    
    func save() {
        let settings = SettingsHelper.shared
        if let language = selectedLanguage {
            NotificationCenter.default.post(Notification(name: Notification.Name.LanguageChanged))
            settings.language = language
        }
        if let autoSelectDelay = selectedAutoSelectDelay {
            settings.autoSelectDelay = autoSelectDelay
        }
        if let tileSize = selectedTileSize {
            settings.tileSize = tileSize
        }
        if let isSoundEnabled = self.isSoundEnabled {
            settings.isSoundEnabled = isSoundEnabled
        }
    }
}
