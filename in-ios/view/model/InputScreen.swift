//
//  InputScreen.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct InputScreen: Decodable {
    
    let disable_text_to_speech: Bool?
    let translations: [TranslationInputScreen]?
    let buttons: [ButtonInputScreen]?
    let background: String?
    let background_transparency: Int?
    let previous_button: String?
    let next_button: String?
    let type: String?
}

struct TranslationInputScreen: Decodable {
    
    var locale: String?
    var title: String?
    var title_text_to_speech: String?
}

struct ButtonInputScreen: Decodable {
    
    var disable_text_to_speech: Bool?
    var icon: IconMenuItem?
    var translations: TranslationMenuItem?
    var type: String?
}
