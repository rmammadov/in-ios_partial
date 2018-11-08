//
//  MenuItem.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct MenuItem: Decodable {
    
    let subMenuItemIds: Array<Int>
    let disableTextToSpeech: Bool
    let id: Int
    let name: String
    let icon: IconMenuItem?
    let inputScreenId: Int?
    let roles: Array<String>
    let translations: [Translation]
    
    enum CodingKeys: String, CodingKey {
        case subMenuItemIds = "sub_menu_item_item_ids"
        case disableTextToSpeech = "disable_text_to_speech"
        case inputScreenId = "input_screen_id"
        case id, name, icon, roles, translations
    }
}

struct IconMenuItem: Decodable {
    
    var id: Int?
    var url: String?
}
