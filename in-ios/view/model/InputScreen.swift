//
//  InputScreen.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct InputScreen: Decodable {
    
    let disableTextToSpeech: Bool
    let translations: [TranslationInputScreen]
    let buttons: [ButtonInputScreen]?
    let background: String?
    let backgroundTransparency: Double?
    let previousButton: ButtonInputScreen?
    let nextButton: ButtonInputScreen?
    let type: String
}

extension InputScreen {
    
    enum InputScreenKeys: String, CodingKey {
        case disableTextToSpeech = "disable_text_to_speech"
        case translations = "translations"
        case buttons = "buttons"
        case background = "background"
        case backgroundTransparency = "background_transparency"
        case previousButton = "previous_button"
        case nextButton = "next_button"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InputScreenKeys.self)
        let disableTextToSpeech: Bool = try container.decode(Bool.self, forKey: .disableTextToSpeech)
        let translations: [TranslationInputScreen] = try container.decode([TranslationInputScreen].self, forKey: .translations)
        let type: String = try container.decode(String.self, forKey: .type)
        
        
        var buttons: [ButtonInputScreen]?
        var background: String?
        var backgroundTransparency: Double?
        var previousButton: ButtonInputScreen?
        var nextButton: ButtonInputScreen?
        
        if type == Constant.InputScreen.TYPE_A {
            buttons = try container.decode([ButtonInputScreen].self, forKey: .buttons)
            background = try container.decode(String?.self, forKey: .background)
            backgroundTransparency = try container.decode(Double.self, forKey: .backgroundTransparency)
            previousButton = try container.decode(ButtonInputScreen?.self, forKey: .previousButton)
            nextButton = try container.decode(ButtonInputScreen?.self, forKey: .nextButton)
        }
        
        self.init(disableTextToSpeech: disableTextToSpeech, translations: translations, buttons: buttons, background: background, backgroundTransparency: backgroundTransparency, previousButton: previousButton, nextButton: nextButton, type: type)
    }
}

struct TranslationInputScreen: Decodable {
    
    var locale: String?
    var title: String?
    var titleTextToSpeech: String?
    
    enum CodingKeys: String, CodingKey {
        case titleTextToSpeech = "title_text_to_speech"
        case locale, title
    }
}

struct ButtonInputScreen: Decodable {
    
    var disableTextToSpeech: Bool?
    var icon: IconMenuItem?
    var translations: [TranslationMenuItem]?
    var type: String?
    
    enum CodingKeys: String, CodingKey {
        case disableTextToSpeech = "disable_text_to_speech"
        case icon, translations, type
    }
}
