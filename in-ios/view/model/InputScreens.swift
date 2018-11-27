//
//  InputScreens.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct InputScreens {
    
    var screens: Array<InputScreen>?
}

extension InputScreens {
    
    func getInputScreen(title: String) -> InputScreen? {
        return screens?.filter{ ($0.translations.first?.label)! == title}.first
    }
    
    func getInputScreenFor(id: Int) -> InputScreen?  {
        return screens?.first(where: { $0.id == id })
    }
    
}
