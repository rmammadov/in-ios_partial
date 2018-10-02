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
    let background: Background?
    let backgroundTransparency: Double?
    let previousButton: ButtonInputScreen?
    let nextButton: ButtonInputScreen?
    let type: String
    let backButton: ButtonInputScreen?
    let clearButton: ButtonInputScreen?
    let tabs: [Tab]?
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
        case backButton = "back_button"
        case clearButton = "clear_button"
        case tabs = "tabs"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InputScreenKeys.self)
        let disableTextToSpeech: Bool = try container.decode(Bool.self, forKey: .disableTextToSpeech)
        let translations: [TranslationInputScreen] = try container.decode([TranslationInputScreen].self, forKey: .translations)
        let type: String = try container.decode(String.self, forKey: .type)
        
        let buttons: [ButtonInputScreen]? = try container.decodeIfPresent([ButtonInputScreen].self, forKey: .buttons)
        let background: Background? = try container.decodeIfPresent(Background.self, forKey: .background)
        let backgroundTransparency: Double? = try container.decodeIfPresent(Double.self, forKey: .backgroundTransparency)
        let previousButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .previousButton)
        let nextButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .nextButton)
        let backButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .backButton)
        let clearButton: ButtonInputScreen? = try container.decodeIfPresent(ButtonInputScreen.self, forKey: .clearButton)
        let tabs: [Tab]? = try container.decodeIfPresent([Tab].self, forKey: .tabs)
        
        self.init(disableTextToSpeech: disableTextToSpeech, translations: translations, buttons: buttons,
                  background: background, backgroundTransparency: backgroundTransparency,
                  previousButton: previousButton, nextButton: nextButton, type: type, backButton: backButton,
                  clearButton: clearButton, tabs: tabs)
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
    var icon: IconMenuItem? = nil
    var translations: [TranslationMenuItem]?
    var type: String?
    var inputScreenId: Int? = nil
    
    enum CodingKeys: String, CodingKey {
        case disableTextToSpeech = "disable_text_to_speech"
        case inputScreenId = "input_screen_id"
        case icon, translations, type
    }
}

struct Background: Decodable {
    
    var id: Int?
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url
    }
}

struct Tab: Decodable {
    let panelScreenId: Int
    
    enum CodingKeys: String, CodingKey {
        case panelScreenId = "panel_screen_id"
    }
}
