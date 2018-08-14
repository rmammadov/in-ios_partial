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
    let disable_text_to_speech: Bool
    let id: Int
    let name: String
    let icon: IconMenuItem?
    let input_screen_id: Int?
    let roles: Array<String>
    let translations: [TranslationMenuItem]
}

struct TranslationMenuItem: Decodable {
    
    var locale: String?
    var label: String?
    var label_text_to_speech: String?
}

struct IconMenuItem: Decodable {
    
    var id: Int?
    var url: String?
}
