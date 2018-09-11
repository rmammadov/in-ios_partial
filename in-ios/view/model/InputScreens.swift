//
//  InputScreens.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct InputScreens {
    
    let screens: [InputScreen]
}


extension InputScreens {
    
    func getInputScreen(title: String) -> InputScreen {
        return screens.filter{ ($0.translations.first?.title)! == title}.first!
    }
}
