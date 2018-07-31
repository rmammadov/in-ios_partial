//
//  MenuItem.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct MenuItem: Decodable {
    
    let sub_menu_item_item_ids: Array<Int>
    let translations: [TranslationItem]
    let disable_text_to_speech: Bool
    let id: Int
    let name: String
    let icon: IconItem?
    let roles: Array<String>
}
